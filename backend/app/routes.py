# app/routes.py
from fastapi import APIRouter, Query
from app.services import risk as risk_svc
from app.services import overlays as ov_svc
from app.schemas.risk import RiskScoreResponse
from app.schemas.overlays import FeatureCollection

router = APIRouter()

# EPIC 3 — 风险/安全分
@router.get("/risk/score", response_model=RiskScoreResponse, tags=["risk"])
async def risk_score(
    lat: float = Query(...),
    lon: float = Query(...),
    date: str | None = Query(None, description="ISO date, e.g. 2025-08-29")
):
    comps = risk_svc.compute_components(lat, lon, date)
    score, level = risk_svc.compute_overall_score(comps)
    return {
        "lat": lat, "lon": lon, "date": date,
        "score": score, "level": level, "components": comps,
        "notes": "Mock components; replace with real data sources later."
    }

# EPIC 5 — 地图覆盖层
@router.get("/map/overlays", response_model=FeatureCollection, tags=["map"])
async def map_overlays(
    types: list[str] = Query(["mpa", "hab", "pollution"], description="mpa|hab|pollution"),
    bbox: str | None = Query(None, description="minLon,minLat,maxLon,maxLat (optional)")
):
    # 目前忽略 bbox；后续可在 DB/PostGIS 做空间过滤
    return ov_svc.build_feature_collection([t.lower() for t in types])
