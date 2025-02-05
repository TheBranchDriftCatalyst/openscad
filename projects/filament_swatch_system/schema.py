from pydantic import BaseModel, Field


class FilamentSwatchSchema(BaseModel):
    brand: str = Field(alias="Line_1_Text", description="The brand of the filament.")
    color: str = Field(alias="Line_2_Text", description="The color of the filament.")
    temp: str = Field(
        alias="Line_3_Text", description="The temperature range for the filament."
    )
    material: str = Field(
        alias="Line_4_Text", description="The material of the filament."
    )
