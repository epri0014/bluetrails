# app/schemas.py
from pydantic import BaseModel

class StateOut(BaseModel):
    st_code: str
    st_desc: str | None = None
    latitude: float | None = None
    longitude: float | None = None

    class Config: from_attributes = True

class RegionOut(BaseModel):
    reg_code: str
    reg_name: str | None = None
    reg_desc: str | None = None
    st_code:  str

    class Config: from_attributes = True

class BeachOut(BaseModel):
    bc_code: str
    bc_name: str | None = None
    bc_address: str | None = None
    reg_code: str
    latitude: float | None = None
    longitude: float | None = None

    class Config: from_attributes = True
