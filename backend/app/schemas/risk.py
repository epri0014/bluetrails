# app/schemas/risk.py
from pydantic import BaseModel, Field
from typing import Literal, Optional, List, Dict, Any

class RiskComponent(BaseModel):
    name: str
    value: float = Field(ge=0.0)
    weight: float = Field(ge=0.0)
    normalized: float = Field(ge=0.0, le=1.0)

class RiskScoreResponse(BaseModel):
    lat: float
    lon: float
    date: Optional[str] = None
    score: int = Field(ge=0, le=100)
    level: Literal["green", "yellow", "red"]
    components: List[RiskComponent]
    notes: Optional[str] = None
