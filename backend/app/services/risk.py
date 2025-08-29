# app/services/risk.py
from math import isnan

def _clamp01(x: float) -> float:
    try:
        if x is None or isnan(x):
            return 0.5
    except Exception:
        pass
    return max(0.0, min(1.0, x))

def compute_components(lat: float, lon: float, date: str | None):
    # 先用 mock；之后替换为 AODN SST/Chl-a、HAB 警示、规则等
    sst_anomaly = 0.3
    chl_a = 0.4
    advisories = 0.2
    weights = {"sst_anomaly": 0.4, "chlorophyll_a": 0.4, "advisories": 0.2}
    comps = [
        ("sst_anomaly", sst_anomaly, weights["sst_anomaly"]),
        ("chlorophyll_a", chl_a, weights["chlorophyll_a"]),
        ("advisories", advisories, weights["advisories"]),
    ]
    return [{"name": n, "value": v, "weight": w, "normalized": _clamp01(v)} for n, v, w in comps]

def compute_overall_score(components: list[dict]) -> tuple[int, str]:
    weighted = sum(c["normalized"] * c["weight"] for c in components)
    total_w = sum(c["weight"] for c in components) or 1.0
    risk01 = _clamp01(weighted / total_w)
    safety01 = 1 - risk01
    score = round(safety01 * 100)
    level = "green" if score >= 70 else ("yellow" if score >= 40 else "red")
    return score, level
