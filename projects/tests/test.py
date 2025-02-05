# tests/test_project_manager.py

import os
import pytest
from unittest.mock import patch, call
from pathlib import Path

from project_manager import validate_project_directory


# ---------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------
@pytest.fixture
def fixture_projects_dir() -> Path:
    """
    Returns the path to the projects fixtures directory.
    """
    return Path(__file__).parent / "fixtures" / "projects"


# ---------------------------------------------------------------------
# Test Cases
# ---------------------------------------------------------------------
def test_validate_project_directory_with_valid_and_invalid_projects(
    fixture_projects_dir: Path,
    tmp_path: Path
):
    """
    Test that validate_project_directory() processes valid projects and skips invalid ones.
    """
    # Assume fixture_projects_dir contains 'valid_project' and 'invalid_project'
    # Mock generate_stls_from_file to prevent actual execution
    with patch("project_manager.generate_stls_from_file") as mock_generate:
        validate_project_directory(str(fixture_projects_dir))

        # Expected to call generate_stls_from_file once for 'valid_project'
        valid_project_path = fixture_projects_dir / "valid_project"
        params_file = valid_project_path / "params.yaml"
        output_dir = str(valid_project_path)
        scad_file = None  # As per validate_project_directory logic

        mock_generate.assert_called_once_with(
            scad_file=scad_file,
            param_file=str(params_file),
            output_dir=output_dir
        )


def test_validate_project_directory_no_projects(
    tmp_path: Path
):
    """
    Test that validate_project_directory() handles a root directory with no subdirectories.
    """
    # Create an empty root directory
    empty_root = tmp_path / "empty_projects"
    empty_root.mkdir()

    with patch("project_manager.generate_stls_from_file") as mock_generate:
        validate_project_directory(str(empty_root))

        # No projects to process, generate_stls_from_file should not be called
        mock_generate.assert_not_called()


def test_validate_project_directory_invalid_root(tmp_path: Path):
    """
    Test that validate_project_directory() raises an error when the root directory is invalid.
    """
    invalid_root = tmp_path / "non_existent_dir"

    with pytest.raises(NotADirectoryError):
        validate_project_directory(str(invalid_root))


def test_validate_project_directory_generate_stls_failure(
    fixture_projects_dir: Path,
    tmp_path: Path
):
    """
    Test that validate_project_directory() logs an error when generate_stls_from_file fails.
    """
    with patch("project_manager.generate_stls_from_file") as mock_generate:
        # Configure the mock to raise an exception
        mock_generate.side_effect = Exception("OpenSCAD failed")

        with patch("project_manager.logger") as mock_logger:
            validate_project_directory(str(fixture_projects_dir))

            # Check that generate_stls_from_file was called
            valid_project_path = fixture_projects_dir / "valid_project"
            params_file = valid_project_path / "params.yaml"
            output_dir = str(valid_project_path)
            scad_file = None

            mock_generate.assert_called_once_with(
                scad_file=scad_file,
                param_file=str(params_file),
                output_dir=output_dir
            )

            # Check that an error was logged
            mock_logger.error.assert_called_with(
                f"Failed to generate STL files for project {valid_project_path.name}: OpenSCAD failed"
            )
