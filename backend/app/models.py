from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import Text, Float, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB   # ← 新增
from geoalchemy2 import Geometry
from .database import Base

class State(Base):
    __tablename__ = "state"
    st_code: Mapped[str] = mapped_column(Text, primary_key=True)
    st_desc: Mapped[str | None] = mapped_column(Text)
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    feature_type: Mapped[str | None] = mapped_column(Text)
    area_bbox: Mapped[str | None] = mapped_column(Text)
    area_geojson: Mapped[dict | None] = mapped_column(JSONB)  # ← 指定 JSONB
    geom_point: Mapped[str | None] = mapped_column(Geometry("POINT", srid=4326))
    geom_polygon: Mapped[str | None] = mapped_column(Geometry("MULTIPOLYGON", srid=4326))

class Region(Base):
    __tablename__ = "region"
    reg_code: Mapped[str] = mapped_column(Text, primary_key=True)
    reg_name: Mapped[str | None] = mapped_column(Text)
    reg_desc: Mapped[str | None] = mapped_column(Text)
    st_code:  Mapped[str] = mapped_column(Text, ForeignKey("state.st_code"))
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    feature_type: Mapped[str | None] = mapped_column(Text)
    area_bbox: Mapped[str | None] = mapped_column(Text)
    area_geojson: Mapped[dict | None] = mapped_column(JSONB)  # ← 指定 JSONB
    geom_point: Mapped[str | None] = mapped_column(Geometry("POINT", srid=4326))
    geom_geom:  Mapped[str | None] = mapped_column(Geometry(geometry_type="GEOMETRY", srid=4326))

class Beach(Base):
    __tablename__ = "beach"
    bc_code: Mapped[str] = mapped_column(Text, primary_key=True)
    bc_name: Mapped[str | None] = mapped_column(Text)
    bc_address: Mapped[str | None] = mapped_column(Text)
    reg_code:  Mapped[str] = mapped_column(Text, ForeignKey("region.reg_code"))
    latitude:  Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    feature_type: Mapped[str | None] = mapped_column(Text)
    area_bbox:  Mapped[str | None] = mapped_column(Text)
    area_geojson: Mapped[dict | None] = mapped_column(JSONB)  # ← 指定 JSONB
    geom_point: Mapped[str | None] = mapped_column(Geometry("POINT", srid=4326))
    geom_geom:  Mapped[str | None] = mapped_column(Geometry(geometry_type="GEOMETRY", srid=4326))
