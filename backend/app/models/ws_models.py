from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import Text, ForeignKey, Integer
from ..database import Base

class WSAvatar(Base):
    __tablename__ = "ws_avatar"
    avatar_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    species: Mapped[str] = mapped_column(Text, nullable=False)
    intro: Mapped[str] = mapped_column(Text, nullable=False)
    image_neutral_url: Mapped[str] = mapped_column(Text)
    image_happy_url: Mapped[str] = mapped_column(Text)
    image_sad_url: Mapped[str] = mapped_column(Text)

class WSAvatarSite(Base):
    __tablename__ = "ws_avatar_site"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    avatar_id: Mapped[int] = mapped_column(ForeignKey("ws_avatar.avatar_id"))
    site_id: Mapped[str] = mapped_column(Text, ForeignKey("epa_site.site_id"))

class WSClassType(Base):
    __tablename__ = "ws_class_type"
    class_type_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    description: Mapped[str] = mapped_column(Text)


class WSWaterFactor(Base):
    __tablename__ = "ws_water_factor"
    factor_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(Text)
    icon: Mapped[str] = mapped_column(Text)


class WSTrafficLightStatus(Base):
    __tablename__ = "ws_traffic_light_status"
    status_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    factor_id: Mapped[int] = mapped_column(Integer, ForeignKey("ws_water_factor.factor_id"))
    class_type_id: Mapped[int] = mapped_column(Integer, ForeignKey("ws_class_type.class_type_id"))
    label: Mapped[str] = mapped_column(Text)


class WSFactorStory(Base):
    __tablename__ = "ws_factor_story"
    story_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    avatar_id: Mapped[int] = mapped_column(Integer, ForeignKey("ws_avatar.avatar_id"))
    status_id: Mapped[int] = mapped_column(Integer, ForeignKey("ws_traffic_light_status.status_id"))
    explanation: Mapped[str] = mapped_column(Text)
    causes_justification: Mapped[str] = mapped_column(Text)


class WSPollutionCause(Base):
    __tablename__ = "ws_pollution_cause"
    cause_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    status_id: Mapped[int] = mapped_column(Integer, ForeignKey("ws_traffic_light_status.status_id"))
    icon: Mapped[str] = mapped_column(Text)
    title: Mapped[str] = mapped_column(Text)
    description: Mapped[str] = mapped_column(Text)

class WSFunFact(Base):
    __tablename__ = "ws_fun_fact"
    fact_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    avatar_id: Mapped[int] = mapped_column(Integer, ForeignKey("ws_avatar.avatar_id"))
    fact_text: Mapped[str] = mapped_column(Text)

class WSEcoAction(Base):
    __tablename__ = "ws_eco_action"
    action_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    action_text: Mapped[str] = mapped_column(Text)
