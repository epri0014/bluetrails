from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import Text, Float, Date, Integer, ForeignKey
from ..database import Base

class EPASite(Base):
    __tablename__ = "epa_site"
    site_id: Mapped[str] = mapped_column(Text, primary_key=True)
    site_name_short: Mapped[str] = mapped_column(Text)
    site_name_long: Mapped[str] = mapped_column(Text)
    water_body: Mapped[str] = mapped_column(Text)
    latitude: Mapped[float]
    longitude: Mapped[float]
    st_code: Mapped[str]

class EPAParameter(Base):
    __tablename__ = "epa_parameter"
    parameter: Mapped[str] = mapped_column(Text, primary_key=True)
    method_name: Mapped[str] = mapped_column(Text)
    parameter_name: Mapped[str] = mapped_column(Text)
    units: Mapped[str] = mapped_column(Text)

class EPAData(Base):
    __tablename__ = "epa_data"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    site_id: Mapped[str] = mapped_column(ForeignKey("epa_site.site_id"))
    date: Mapped[str] = mapped_column(Date)        # date of measurement
    type: Mapped[str] = mapped_column(Text)        # surface / bottom etc
    parameter: Mapped[str] = mapped_column(ForeignKey("epa_parameter.parameter"))
    param_value: Mapped[float | None] = mapped_column(Float, nullable=True)
