from typing import List, Optional

from pydantic import BaseModel, Extra


class SettingsDict(BaseModel):
    """
    Settings that affect how we render the OpenSCAD models.
    """

    scad_file: str  # Path to the .scad file to render
    output_name: str  # Example: "{{ brand }}_{{ color | lowercase }}_{{ material }}"


class CommonSchemaParams(BaseModel, extra="allow"):
    """
    Arbitrary fields that apply as 'common' to each item.
    (You would subclass or extend in real usage.)
    """

    pass


class ItemSchemaParams(BaseModel, extra="allow"):
    """
    Arbitrary fields for each item variation.
    (You would subclass or extend in real usage.)
    """

    pass


class ScadParametersFileSchema(BaseModel):
    """
    If the file is structured to have 'settings', 'common', 'items',
    it can be validated with this schema.
    """

    settings: SettingsDict
    common: Optional[CommonSchemaParams] = None
    items: List[ItemSchemaParams]
