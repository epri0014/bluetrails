# app/schemas/overlays.py
from pydantic import BaseModel
from typing import Literal, Dict, Any, List

class OverlayFeature(BaseModel):
    type: Literal["Feature"] = "Feature"
    geometry: Dict[str, Any]
    properties: Dict[str, Any] = {}

class FeatureCollection(BaseModel):
    type: Literal["FeatureCollection"] = "FeatureCollection"
    features: List[OverlayFeature]
