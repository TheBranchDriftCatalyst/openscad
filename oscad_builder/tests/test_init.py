import os
import pytest
from unittest.mock import patch, call
from pathlib import Path

from .. import SimpleValidationError, generate_stls_from_file

# ---------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------


@pytest.fixture
def fixture_dir() -> Path:
    """
    Returns the path to the fixtures directory.
    """
    return Path(__file__).parent / "fixtures"


@pytest.fixture
def valid_yaml_params(fixture_dir: Path) -> Path:
    """
    Path to a valid YAML parameter file.
    """
    return fixture_dir / "valid_params.yaml"


@pytest.fixture
def invalid_yaml_params(fixture_dir: Path) -> Path:
    """
    Path to an invalid YAML parameter file (missing 'settings').
    """
    return fixture_dir / "invalid_params.yaml"


@pytest.fixture
def simple_scad_file(fixture_dir: Path) -> Path:
    """
    Path to a simple SCAD file for testing.
    """
    return fixture_dir / "simple_model.scad"


# ---------------------------------------------------------------------
# Test Cases
# ---------------------------------------------------------------------


def test_generate_stls_from_file_with_valid_yaml(
    valid_yaml_params: Path, simple_scad_file: Path, tmp_path: Path
):
    """
    Test that generate_stls_from_file() properly reads a valid YAML file
    matching the ScadParametersFileSchema and calls OpenSCAD
    with the expected parameters.
    """
    output_dir = tmp_path / "stls"

    # Mock subprocess.run to prevent actual OpenSCAD execution
    with patch("subprocess.run") as mock_run:
        generate_stls_from_file(
            scad_file=str(simple_scad_file),
            param_file=str(valid_yaml_params),
            output_dir=str(output_dir),
        )

        # Ensure the output directory was created
        assert output_dir.exists(), "Output directory should be created."

        # Expected SCAD file from YAML settings
        expected_scad_file = "./assets/swatches/files/Rolodex_Filament_Swatch_V2.scad"

        # Define expected calls for each item
        expected_calls = [
            call(
                [
                    "openscad",
                    "-o",
                    os.path.join(str(output_dir), "Amolen_Burgundy Red_PLA (CF).stl"),
                    '-D font_name="Liberation Sans"',
                    '-D brand="Amolen"',
                    '-D color="Burgundy Red"',
                    '-D material="PLA (CF)"',
                    '-D temp="210-240°C"',
                    expected_scad_file,
                ],
                check=True,
            ),
            call(
                [
                    "openscad",
                    "-o",
                    os.path.join(
                        str(output_dir), "Amolen_Aquamarine Blue_PLA (CF).stl"
                    ),
                    '-D font_name="Liberation Sans"',
                    '-D brand="Amolen"',
                    '-D color="Aquamarine Blue"',
                    '-D material="PLA (CF)"',
                    '-D temp="210-240°C"',
                    expected_scad_file,
                ],
                check=True,
            ),
            call(
                [
                    "openscad",
                    "-o",
                    os.path.join(str(output_dir), "Amolen_Dark Grey_PLA (CF).stl"),
                    '-D font_name="Liberation Sans"',
                    '-D brand="Amolen"',
                    '-D color="Dark Grey"',
                    '-D material="PLA (CF)"',
                    '-D temp="210-240°C"',
                    expected_scad_file,
                ],
                check=True,
            ),
        ]

        # Assert that subprocess.run was called with expected commands
        mock_run.assert_has_calls(expected_calls, any_order=False)
        assert mock_run.call_count == 3, "Should have invoked openscad 3 times."


def test_generate_stls_from_file_with_invalid_yaml(
    invalid_yaml_params: Path, simple_scad_file: Path, tmp_path: Path
):
    """
    Test that generate_stls_from_file() properly throws a validation error
    if the YAML file does not match the ScadParametersFileSchema.
    """
    output_dir = tmp_path / "stls_fallback"

    with pytest.raises(SimpleValidationError):
        generate_stls_from_file(
            scad_file=str(simple_scad_file),
            param_file=str(invalid_yaml_params),
            output_dir=str(output_dir),
        )
