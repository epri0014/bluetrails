# app/routers/core_routes.py
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import select, func, text
from geoalchemy2.shape import to_shape
from geoalchemy2.elements import WKBElement

from ..database import get_db
from ..models.core_models import State, Region, Beach
from ..schemas.core_schemas import StateOut, RegionOut, BeachOut

router = APIRouter(tags=["Core Data"])

# 工具：把 geometry(WKB) 转为 lng/lat
def _to_lonlat(point: WKBElement | None):
    if point is None:
        return None, None
    shp = to_shape(point)  # shapely Point
    return (shp.x, shp.y)

# ---------------- Root & Health ----------------
@router.get("/")
def root():
    return {
        "message": "Beaches API is running 🚀",
        "docs": "/docs",
        "redoc": "/redoc",
        "examples": {
            "states": "/api/states",
            "regions": "/api/regions?state=VIC",
            "beaches_search": "/api/beaches?state=VIC&search=Brighton&limit=10&offset=0",
            "beaches_nearby": "/api/beaches/nearby?lat=-37.9&lon=145.0&radius_km=10",
            "regions_within": "/api/regions/within?min_lon=144.8&min_lat=-38.0&max_lon=145.5&max_lat=-37.5",
        },
    }

@router.get("/healthz")
def healthz():
    return {"status": "ok"}

# ---------------- APIs ----------------
@router.get("/states", response_model=list[StateOut])
def list_states(db: Session = Depends(get_db)):
    rows = db.execute(select(State).order_by(State.st_code)).scalars().all()
    return rows

@router.get("/regions", response_model=list[RegionOut])
def list_regions(
    state: str = Query(..., min_length=2),
    db: Session = Depends(get_db)
):
    rows = (
        db.execute(
            select(Region).where(Region.st_code == state).order_by(Region.reg_name)
        )
        .scalars()
        .all()
    )
    return rows

@router.get("/beaches")
def list_beaches(
    state: str = Query(..., min_length=2),
    region: str | None = Query(None),
    search: str | None = Query(None, description="按名称模糊查询"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    include_geojson: bool = False,   # 是否带上 area_geojson
    include_geom: bool = False,      # 是否带上 geometry WKT
    db: Session = Depends(get_db),
):
    # 通过 region 关联 state 过滤
    regs_subq = select(Region.reg_code).where(Region.st_code == state)
    if region:
        regs_subq = regs_subq.where(Region.reg_code == region)
    regs_subq = regs_subq.subquery()

    base = select(Beach).where(Beach.reg_code.in_(select(regs_subq)))
    if search:
        base = base.where(Beach.bc_name.ilike(f"%{search}%"))

    total = db.execute(select(func.count()).select_from(base.subquery())).scalar_one()
    rows = db.execute(
        base.order_by(Beach.bc_name).limit(limit).offset(offset)
    ).scalars().all()

    items = []
    for b in rows:
        lon, lat = _to_lonlat(b.geom_point) if b.geom_point else (b.longitude, b.latitude)
        obj = {
            "bc_code": b.bc_code,
            "bc_name": b.bc_name,
            "bc_address": b.bc_address,
            "reg_code": b.reg_code,
            "longitude": lon,
            "latitude":  lat,
        }
        if include_geojson:
            obj["area_geojson"] = b.area_geojson
        if include_geom and b.geom_point is not None:
            # 以 WKT 返回；也可改成 GeoJSON：ST_AsGeoJSON
            wkt = db.scalar(select(func.ST_AsText(b.geom_point)).where(Beach.bc_code == b.bc_code))
            obj["geom_point_wkt"] = wkt
        items.append(obj)

    return {"total": total, "limit": limit, "offset": offset, "items": items}

@router.get("/beaches/nearby")
def beaches_nearby(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    radius_km: float = Query(10, gt=0, le=200),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
):
    # 用球面距离（米）
    stmt = text("""
        SELECT bc_code, bc_name, bc_address, reg_code,
               ST_X(geom_point)::float8 AS lon,
               ST_Y(geom_point)::float8 AS lat,
               ST_DistanceSphere(geom_point, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)) AS dist_m
        FROM beach
        WHERE geom_point IS NOT NULL
          AND ST_DWithin(geom_point, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), :radius_m)
        ORDER BY dist_m
        LIMIT :limit
    """)
    rows = db.execute(stmt, {"lon": lon, "lat": lat, "radius_m": radius_km * 1000, "limit": limit}).mappings().all()
    for r in rows:
        r["distance_km"] = round(r["dist_m"] / 1000, 3)
        del r["dist_m"]
    return {"items": rows, "center": {"lat": lat, "lon": lon}, "radius_km": radius_km}

@router.get("/regions/within")
def regions_within_bbox(
    min_lon: float, min_lat: float, max_lon: float, max_lat: float,
    db: Session = Depends(get_db),
):
    # bbox 过滤区域
    stmt = text("""
        SELECT reg_code, reg_name, st_code
        FROM region
        WHERE geom_geom IS NOT NULL
          AND ST_Intersects(
              geom_geom,
              ST_SetSRID(ST_MakeEnvelope(:min_lon,:min_lat,:max_lon,:max_lat), 4326)
          )
        ORDER BY reg_name
    """)
    rows = db.execute(stmt, {"min_lon": min_lon, "min_lat": min_lat, "max_lon": max_lon, "max_lat": max_lat}).mappings().all()
    return {"items": rows, "bbox": [min_lon, min_lat, max_lon, max_lat]}
