# app/services/overlays.py
from typing import Iterable

def _mpa_features() -> Iterable[dict]:
    yield {
        "type": "Feature",
        "geometry": {"type": "Polygon",
                     "coordinates": [[[144.9,-37.9],[145.0,-37.9],[145.0,-38.0],[144.9,-38.0],[144.9,-37.9]]]},
        "properties": {"type": "MPA", "name": "Example Marine Park", "rule": "No-take"},
    }

def _hab_hotspots() -> Iterable[dict]:
    yield {
        "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [138.5, -34.9]},
        "properties": {"type": "HAB_HOTSPOT", "severity": "moderate"},
    }

def _pollution_points() -> Iterable[dict]:
    yield {
        "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [151.2, -33.8]},
        "properties": {"type": "POLLUTION", "indicator": "enterococci", "status": "watch"},
    }

def build_feature_collection(types: list[str]):
    feats = []
    if "mpa" in types: feats.extend(_mpa_features())
    if "hab" in types: feats.extend(_hab_hotspots())
    if "pollution" in types: feats.extend(_pollution_points())
    return {"type": "FeatureCollection", "features": feats}
