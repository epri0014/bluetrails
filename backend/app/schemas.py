# app/schemas.py
from typing import Optional
from pydantic import BaseModel, field_serializer, ConfigDict
from geoalchemy2.elements import WKBElement
from geoalchemy2.shape import to_shape


# ---- 通用几何序列化混入：把 WKBElement -> WKT 字符串 ----
class _GeomAsWKT(BaseModel):
    # Pydantic v2 写法：启用 ORM 模式（支持 from ORM/SQLAlchemy 映射）
    model_config = ConfigDict(from_attributes=True)

    # 注意：这些字段定义在子类里，因此需要 check_fields=False
    @field_serializer("geom_point", "geom_polygon", "geom_geom", check_fields=False)
    def _serialize_geom(self, v: Optional[WKBElement], _info):
        if v is None:
            return None
        try:
            # to_shape -> shapely geometry，再输出为 WKT
            return to_shape(v).wkt
        except Exception:
            # 异常时返回 None（也可以改为抛出）
            return None


# ---------- States ----------
class StateOut(_GeomAsWKT):
    st_code: str
    st_desc: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    # 可选的附加字段，与 models.py 对齐
    feature_type: Optional[str] = None
    area_bbox: Optional[str] = None
    area_geojson: Optional[dict] = None

    # 几何字段（输出为 WKT 字符串）
    geom_point: Optional[str] = None
    geom_polygon: Optional[str] = None


# ---------- Regions ----------
class RegionOut(_GeomAsWKT):
    reg_code: str
    reg_name: Optional[str] = None
    reg_desc: Optional[str] = None
    st_code: str

    # 对齐 models.py 的其它列
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    feature_type: Optional[str] = None
    area_bbox: Optional[str] = None
    area_geojson: Optional[dict] = None

    # 几何字段
    geom_point: Optional[str] = None
    geom_geom: Optional[str] = None   # 混合几何类型，统一按 WKT 字符串输出


# ---------- Beaches ----------
class BeachOut(_GeomAsWKT):
    bc_code: str
    bc_name: Optional[str] = None
    bc_address: Optional[str] = None
    reg_code: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    # 对齐 models.py 的其它列
    feature_type: Optional[str] = None
    area_bbox: Optional[str] = None
    area_geojson: Optional[dict] = None

    # 几何字段
    geom_point: Optional[str] = None
    geom_geom: Optional[str] = None
