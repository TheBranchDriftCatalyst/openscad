# __init__.py

import json
import re
import subprocess
import os
from typing import Optional, List, Dict, Any
from concurrent.futures import ProcessPoolExecutor, as_completed

from pydantic import ValidationError
import yaml
from jinja2 import Environment
from rich.progress import (
    Progress,
    TextColumn,
    SpinnerColumn,
    TimeElapsedColumn,
)
import logging

from oscad_builder.schemas import ScadParametersFileSchema

# ---------------------------------------------------------------------
# CONFIGURE LOGGING
# ---------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()],
)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------
# UTILITY FUNCTIONS
# ---------------------------------------------------------------------
def load_params(file_path: str) -> Any:
    """
    Load parameter data from either JSON or YAML.
    Chooses parser by file extension: .yaml or .yml => YAML, otherwise JSON.
    """
    logger.debug(f"Loading parameters from file: {file_path}")
    _, ext = os.path.splitext(file_path)
    ext = ext.lower()

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            if ext in [".yaml", ".yml"]:
                data = yaml.safe_load(f)
                logger.debug("Loaded YAML parameters.")
            else:
                data = json.load(f)
                logger.debug("Loaded JSON parameters.")
        return data
    except Exception as e:
        logger.error(f"Failed to load parameters from {file_path}: {e}")
        raise


def render_template(template_str: str, context: Dict[str, Any]) -> str:
    """
    Render the provided template string (e.g. '{{ brand }}_{{ color | lowercase }}')
    using Jinja2, with custom filters for 'lowercase' and 'sluggify'.
    """
    logger.debug("Rendering template.")

    # Initialize the Jinja2 environment
    env = Environment()

    # Add custom 'lowercase' filter
    env.filters["lowercase"] = lambda value: (
        value.lower() if isinstance(value, str) else value
    )

    # Add custom 'sluggify' filter
    env.filters["sluggify"] = lambda value: (
        re.sub(r"[\s-]", "_", value.lower()) if isinstance(value, str) else value
    )

    # Create the template from the environment
    tmpl = env.from_string(template_str)

    # Render the template with the provided context
    rendered = tmpl.render(**context)

    logger.debug(f"Rendered template: {rendered}")
    return rendered


class SimpleValidationError(Exception):
    """
    Simple exception to raise when a validation error occurs.
    """

    def __init__(self, message: str):
        self.message = message
        super().__init__(message)


# ---------------------------------------------------------------------
# MAIN RENDER FUNCTION
# ---------------------------------------------------------------------
def generate_stls_from_file(
    param_file: str,
    output_dir: str,
    scad_file: Optional[str],
    rebuild: bool = False,
    max_workers: Optional[int] = None,  # Optional parameter to control parallelism
) -> None:
    """
    Reads a param file (JSON or YAML) and generates STL files using OpenSCAD in parallel.
    """
    logger.info(
        f"Starting STL generation. Parameters file: {param_file}, Output directory: {output_dir}"
    )

    # Create the output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    logger.debug(f"Ensured output directory exists: {output_dir}")

    # Load the raw parameter data
    param_file_data = load_params(param_file)

    # Attempt to parse the param_file_data using the new schema.
    try:
        schema_obj = ScadParametersFileSchema(**param_file_data)
    except ValidationError as e:
        val_errors = []
        for error in e.errors():
            msg = f"{error['msg']} - {error['loc']}"
            val_errors.append(msg)
            logger.error(msg)
        raise SimpleValidationError(", ".join(val_errors)) from e

    scad_file = schema_obj.settings.scad_file or scad_file

    if not scad_file:
        logger.error("No SCAD file provided or found in the parameter data.")
        raise ValueError("No SCAD file provided or found in the parameter data.")

    common = schema_obj.common.model_dump() if schema_obj.common else {}

    # Merge 'common' with each item, specific overrides common
    param_sets = [{**common, **item.model_dump()} for item in schema_obj.items]
    logger.debug(f"Parameter sets after merging common parameters: {param_sets}")

    # Initialize Rich Progress with Indeterminate Progress Indicators
    progress = Progress(
        SpinnerColumn(spinner_name="dots", finished_text="[green]✔️"),
        TextColumn("[bold blue]{task.description}:", justify="left"),
        # TextColumn("[bold blue]{task.fields[output_name]}", justify="left"),
        TimeElapsedColumn(),
        transient=False,  # Automatically removes completed tasks
    )

    with progress:
        with ProcessPoolExecutor(max_workers=max_workers) as executor:
            # Dictionary to keep track of futures and their corresponding task IDs
            future_to_task = {}
            for params in param_sets:
                define_flags = _build_define_flags(params)

                # Use Jinja template for output name
                output_name = render_template(schema_obj.settings.output_name, params)
                output_stl = os.path.join(output_dir, f"{output_name}.stl")

                # Check if output STL exists and skip if it does
                if not rebuild and os.path.exists(output_stl):
                    logger.debug(f"Skipping {output_stl} as it already exists")

                    # Add a skipped task to the progress bar
                    task_id = progress.add_task(
                        description=f"[bright_black]Skipped - {output_name}",
                        output_name=output_name,
                        completed=1,
                        total=1,
                    )
                    progress.stop_task(task_id)
                    continue

                # Add a new task to the progress bar
                task_id = progress.add_task(
                    f"Rendering - {output_name}",
                    output_name=output_name,
                    total=1,  # Set total to 1 for completion
                )

                # Submit the _run_openscad function to the executor
                future = executor.submit(
                    _run_openscad,
                    scad_file,
                    output_stl,
                    define_flags,
                )
                future_to_task[future] = task_id

            # Handle results or exceptions
            for future in as_completed(future_to_task):
                task_id = future_to_task[future]
                try:
                    future.result()
                except Exception as e:
                    task_name = progress.tasks[task_id].fields.get(
                        "output_name", "Unknown"
                    )
                    logger.error(f"Task {task_name} failed: {e}")
                    progress.update(
                        task_id,
                        description=f"[red]Failed {task_name}",
                        completed=1,
                    )
                else:
                    task_name = progress.tasks[task_id].fields.get(
                        "output_name", "Unknown"
                    )
                    logger.info(f"Task {task_name} completed successfully.")
                    progress.update(
                        task_id,
                        description=f"[green]✔️ Completed {task_name}",
                        completed=1,
                    )
                finally:
                    progress.stop_task(task_id)


# ---------------------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------------------
def _run_openscad(scad_file: str, output_stl: str, define_flags: List[str]) -> None:
    """
    Executes the OpenSCAD command to generate an STL file.
    """
    try:
        # Build the OpenSCAD command
        command = ["openscad", "-o", output_stl, scad_file] + define_flags
        logger.debug(f"Running OpenSCAD command: {' '.join(command)}")

        # Execute the OpenSCAD command, capturing output
        result = subprocess.run(
            command,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        if result.stdout:
            logger.debug(f"OpenSCAD output for {output_stl}: {result.stdout}")
        if result.stderr:
            logger.debug(f"OpenSCAD errors for {output_stl}: {result.stderr}")

    except subprocess.CalledProcessError as e:
        logger.error(f"OpenSCAD failed for {output_stl}: {e.stderr}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error for {output_stl}: {e}")
        raise


def _build_define_flags(params: Dict[str, Any]) -> List[str]:
    """
    Convert a dictionary of parameters into a list of OpenSCAD -D flags.
    """
    logger.debug(f"Building define flags from parameters: {params}")
    define_flags = []
    for k, v in params.items():
        if isinstance(v, (int, float)):
            flag = f"-D {k}={v}"
        elif isinstance(v, bool):
            flag = f"-D {k}={'true' if v else 'false'}"
        else:
            # Escape quotes in string values
            escaped_value = str(v).replace('"', '\\"')
            flag = f'-D {k}="{escaped_value}"'
        define_flags.append(flag)
        logger.debug(f"Added define flag: {flag}")
    return define_flags
