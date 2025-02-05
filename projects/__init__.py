import os
import subprocess
from pathlib import Path
from typing import Optional, List

import logging
from tqdm import tqdm


# ---------------------------------------------------------------------
# CONFIGURE LOGGING
# ---------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------
# 1) VALIDATION FUNCTIONS
# ---------------------------------------------------------------------
def is_valid_project_dir(project_path: Path) -> bool:
    """
    Check if the given project directory is valid.
    A valid project directory must contain:
        - assets/ directory
        - schema.py file
        - At least one *.3mf file
        - params.yaml or params.json file
    """
    logger.debug(f"Validating project directory: {project_path}")

    # Check for assets/ directory
    assets_dir = project_path / "assets"
    if not assets_dir.is_dir():
        logger.debug(f"Missing assets/ directory in {project_path}")
        return False

    # Check for schema.py file
    schema_file = project_path / "schema.py"
    if not schema_file.is_file():
        logger.debug(f"Missing schema.py in {project_path}")
        return False

    # Check for at least one *.3mf file
    m3mf_files = list(project_path.glob("*.3mf"))
    if not m3mf_files:
        logger.debug(f"No *.3mf files found in {project_path}")
        return False

    # Check for params.yaml or params.json file
    params_yaml = project_path / "params.yaml"
    params_json = project_path / "params.json"
    if not (params_yaml.is_file() or params_json.is_file()):
        logger.debug(f"Missing params.yaml or params.json in {project_path}")
        return False

    logger.debug(f"Project directory {project_path} is valid.")
    return True


# ---------------------------------------------------------------------
# 2) MAIN FUNCTION
# ---------------------------------------------------------------------
def validate_project_directory(root_dir: str) -> None:
    """
    This method checks the given root directory to see if it contains valid project directories.
    A valid project directory has the following files:
        assets/
        schema.py
        *.3mf
        params.(yaml|json)

    If a project directory is valid, it builds each project by calling generate_stls_from_file.
    
    Args:
        root_dir (str): Path to the root directory containing project subdirectories.
    """
    root_path = Path(root_dir)
    if not root_path.is_dir():
        logger.error(f"The provided root directory does not exist or is not a directory: {root_dir}")
        raise NotADirectoryError(f"The provided root directory does not exist or is not a directory: {root_dir}")

    # Iterate over each subdirectory in the root directory
    project_dirs = [d for d in root_path.iterdir() if d.is_dir()]
    if not project_dirs:
        logger.warning(f"No subdirectories found in the root directory: {root_dir}")
        return

    logger.info(f"Found {len(project_dirs)} subdirectories in {root_dir}. Starting validation...")

    # Initialize progress bar
    with tqdm(total=len(project_dirs), desc="Validating Projects") as pbar:
        for project_dir in project_dirs:
            if is_valid_project_dir(project_dir):
                logger.info(f"Valid project directory found: {project_dir.name}")

                # Determine param_file
                param_file_yaml = project_dir / "params.yaml"
                param_file_json = project_dir / "params.json"
                if param_file_yaml.is_file():
                    param_file = str(param_file_yaml)
                elif param_file_json.is_file():
                    param_file = str(param_file_json)
                else:
                    logger.error(f"No params.yaml or params.json found in {project_dir}. Skipping.")
                    pbar.update(1)
                    continue  # This should not happen due to prior validation

                # Determine output_dir (current project directory)
                output_dir = str(project_dir)

                # Determine scad_file from params or use default
                # Assuming generate_stls_from_file can handle scad_file being None
                scad_file = None  # Let generate_stls_from_file handle it based on params

                try:
                    generate_stls_from_file(
                        scad_file=scad_file,
                        param_file=param_file,
                        output_dir=output_dir
                    )
                    logger.info(f"Successfully generated STL files for project: {project_dir.name}")
                except Exception as e:
                    logger.error(f"Failed to generate STL files for project {project_dir.name}: {e}")
            else:
                logger.warning(f"Invalid project directory: {project_dir.name}")
            pbar.update(1)

    logger.info("Project validation and STL generation completed.")


# ---------------------------------------------------------------------
# 3) CLI INTERFACE
# ---------------------------------------------------------------------
def main():
    import argparse

    parser = argparse.ArgumentParser(description="Validate project directories and generate STL files.")
    parser.add_argument(
        "root_dir",
        type=str,
        help="Path to the root directory containing project subdirectories."
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable debug logging."
    )

    args = parser.parse_args()

    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logger.debug("Debug logging enabled.")

    try:
        validate_project_directory(args.root_dir)
    except Exception as e:
        logger.critical(f"An unexpected error occurred: {e}")
        exit(1)


if __name__ == "__main__":
    main()
