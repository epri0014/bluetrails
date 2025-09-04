# app/routers/ws_routes.py
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import select, func
from ..database import get_db
from ..models.ws_models import (
    WSAvatar,
    WSAvatarSite,
    WSClassType,
    WSWaterFactor,
    WSTrafficLightStatus,
    WSFactorStory,
    WSPollutionCause, WSFunFact, WSEcoAction
)

from ..models.epa_models import EPASite, EPAParameter, EPAData
from ..schemas.ws_schemas import WSAvatarOut

router = APIRouter(tags=["Water Story"])

@router.get("/avatars")
def get_avatars(db: Session = Depends(get_db)):
    q = (
        db.query(WSAvatar, EPASite.site_id, EPASite.site_name_short)
        .join(WSAvatarSite, WSAvatar.avatar_id == WSAvatarSite.avatar_id)
        .join(EPASite, EPASite.site_id == WSAvatarSite.site_id)
        .all()
    )

    avatars_map = {}
    for a, site_id, site_name in q:
        if a.avatar_id not in avatars_map:
            avatars_map[a.avatar_id] = {
                "avatar_id": a.avatar_id,
                "name": a.name,
                "species": a.species,
                "intro": a.intro,
                "image_neutral_url": a.image_neutral_url,
                "image_happy_url": a.image_happy_url,
                "image_sad_url": a.image_sad_url,
                "sites": []
            }
        avatars_map[a.avatar_id]["sites"].append({
            "id": site_id,
            "name": site_name
        })

    results = []
    for v in avatars_map.values():
        v["site_short_name"] = ", ".join([s["name"] for s in v["sites"]])
        results.append(v)

    return results



@router.get("/health")
def get_health(avatar_id: int, site_id: str, db: Session = Depends(get_db)):
    """
    Return latest water quality factors, traffic-light status, and avatar explanations
    using ws_* storytelling tables.
    """

    # --- Step 1: Get latest EPA data date for this site
    latest_date = db.execute(
        select(func.max(EPAData.date)).where(EPAData.site_id == site_id)
    ).scalar_one()

    # --- Step 2: Get EPA values for relevant parameters
    rows = (
        db.execute(
            select(EPAData.parameter, EPAData.param_value)
            .where(EPAData.site_id == site_id, EPAData.date == latest_date)
        )
        .all()
    )
    values = {param: val for param, val in rows}

    # --- Step 3: Define mapping from factor_id → EPA parameter(s)
    factor_param_map = {
        1: ("CHL_A",),          # Algal Bloom Risk
        2: ("TURB",),           # Water Clarity
        3: ("DO_MG",),          # Oxygen
        4: ("N_TOTAL",),        # Nutrients
        5: ("TEMP", "TEMPERATURE")  # Temperature (two possible codes)
    }

    # --- Step 4: Status classification (rules)
    def classify_factor(factor_id, val):
        if val is None:
            return 2  # Orange/Amber if missing

        if factor_id == 1:   # Algal Bloom (µg/L)
            if val < 2: return 1
            if val <= 5: return 2
            return 3

        if factor_id == 2:   # Clarity (NTU)
            if val <= 2: return 1
            if val <= 5: return 2
            return 3

        if factor_id == 3:   # Oxygen (mg/L)
            if val >= 6: return 1
            if val >= 4: return 2
            return 3

        if factor_id == 4:   # Nutrients (µg/L)
            if val < 250: return 1
            if val <= 600: return 2
            return 3

        if factor_id == 5:   # Temperature (°C)
            if val < 24: return 1
            if val <= 27: return 2
            return 3

        return 2  # fallback = Orange

    # --- Step 5: For each factor → determine class_type_id + status row
    factor_results = []
    overall_class = 1  # 1 = Green, 2 = Orange, 3 = Red

    for factor_id, params in factor_param_map.items():
        # pick first available param value
        val = None
        for p in params:
            if p in values:
                val = values[p]
                break

        class_type_id = classify_factor(factor_id, val)

        # get traffic light status (label)
        status_row = db.execute(
            select(WSTrafficLightStatus)
            .where(
                WSTrafficLightStatus.factor_id == factor_id,
                WSTrafficLightStatus.class_type_id == class_type_id
            )
        ).scalar_one()

        # get avatar-specific story (only for orange/red)
        story_row = None
        if class_type_id in (2, 3):  # Orange or Red
            story_row = db.execute(
                select(WSFactorStory)
                .where(
                    WSFactorStory.avatar_id == avatar_id,
                    WSFactorStory.status_id == status_row.status_id
                )
            ).scalar_one_or_none()

        # update overall
        if class_type_id == 3:
            overall_class = 3
        elif class_type_id == 2 and overall_class == 1:
            overall_class = 2

        factor_results.append({
            "factor_id": factor_id,
            "name": db.get(WSWaterFactor, factor_id).name,
            "icon": db.get(WSWaterFactor, factor_id).icon,
            "value": val,
            "class_type": db.get(WSClassType, class_type_id).description,
            "label": status_row.label,
            "explanation": story_row.explanation if story_row else None,
            "justification": story_row.causes_justification if story_row else None,
            "status_id": status_row.status_id if story_row else None
        })

    # get site info (lat/lon)
    site_row = db.get(EPASite, site_id)

    return {
        "site": {
            "id": site_id,
            "name": site_row.site_name_short if site_row else None,
            "lat": site_row.latitude if site_row else None,
            "lon": site_row.longitude if site_row else None,
            "date": str(latest_date)
        },
        "overall_class": db.get(WSClassType, overall_class).description,
        "factors": factor_results
    }

# --- Pollution Causes ---
@router.get("/pollution_causes")
def get_pollution_causes(
    status_id: list[int] = Query(..., description="One or more ws_traffic_light_status IDs"),
    db: Session = Depends(get_db)
):
    rows = db.execute(
        select(WSPollutionCause).where(WSPollutionCause.status_id.in_(status_id))
    ).scalars().all()

    return {"items": [
        {
            "id": r.cause_id,
            "icon": r.icon,
            "title": r.title,
            "description": r.description,
            "status_id": r.status_id
        } for r in rows
    ]}


# --- Fun Facts ---
@router.get("/fun_facts")
def get_fun_facts(
    avatar_id: int = Query(..., description="ws_avatar.avatar_id"),
    db: Session = Depends(get_db)
):
    rows = db.execute(
        select(WSFunFact).where(WSFunFact.avatar_id == avatar_id)
    ).scalars().all()

    return {"items": [
        {"id": r.fact_id, "fact_text": r.fact_text}
        for r in rows
    ]}


# --- Eco Actions ---
@router.get("/eco_actions")
def get_eco_actions(db: Session = Depends(get_db)):
    rows = db.execute(select(WSEcoAction)).scalars().all()
    return {"items": [
        {"id": r.action_id, "action_text": r.action_text}
        for r in rows
    ]}

