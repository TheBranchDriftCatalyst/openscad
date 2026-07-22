#!/usr/bin/env python3
import os
import sys
from oscad_builder import generate_stls_from_file, logger, logging


class DirectoryContext:
    def __init__(self, directory: str):
        if not os.path.isdir(directory):
            raise ValueError(f"Error: {directory} is not a valid directory.")

        self.directory = directory
        self.previous_directory = os.getcwd()

    def __enter__(self):
        os.chdir(self.directory)

    def __exit__(self, exc_type, exc_value, traceback):
        os.chdir(self.previous_directory)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Generate STL files from OpenSCAD parameters."
    )

    parser.add_argument(
        "directory",
        type=str,
        help="Directory containing the SCAD project.",
    )

    parser.add_argument(
        "--scad-file",
        type=str,
        default="model.scad",
        help="Path to the main SCAD file.",
    )
    
    parser.add_argument(
        "--param-file",
        type=str,
        default="params.yml",
        help="Path to the parameter file (JSON or YAML).",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="output",
        help="Directory to output the generated STL files.",
    )

    parser.add_argument("--verbose", action="store_true", help="Enable debug logging.")
    parser.add_argument("--rebuild", action="store_true", help="Rebuild all STLs.")

    args = parser.parse_args()

    if args.verbose:
        logger.setLevel(logging.DEBUG)

    try:
        # get from first positional
        with DirectoryContext(args.directory):
            generate_stls_from_file(
                scad_file=args.scad_file,
                param_file=args.param_file,
                output_dir=args.output_dir,
                rebuild=args.rebuild,
            )
    except Exception as e:
        logger.critical(f"STL generation failed: {e}")
        exit(1)
