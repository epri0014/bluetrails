from fastapi import FastAPI, APIRouter
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

app = FastAPI(title="Eco Game API")

# CORS (dev only: allow all; tighten for prod)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- API (prefix=/api) ----------
api = APIRouter(prefix="/api")

score = 0
items = {
    "plastic": 10,
    "paint": 20,
    "pollution_clean": 30,
}

class Action(BaseModel):
    item: str   # "plastic" | "paint" | "pollution_clean"
    place: str  # "bin" | "beach"

@api.post("/play")
def play_game(action: Action):
    global score
    if action.item not in items:
        return {"success": False, "msg": "Invalid item", "score": score}

    points = items[action.item]
    if action.place == "bin":
        score += points
        return {"success": True, "msg": f"{action.item} placed in bin ✅ +{points}", "score": score}
    if action.place == "beach":
        score -= points
        return {"success": False, "msg": f"{action.item} thrown on beach ❌ -{points}", "score": score}
    return {"success": False, "msg": "Invalid place", "score": score}

@api.get("/score")
def get_score():
    return {"score": score}

@api.post("/reset")
def reset_score():
    global score
    score = 0
    return {"success": True, "msg": "Score reset to 0", "score": score}

# Register API routes — before static mounting!
app.include_router(api)

# ---------- Static site at "/" ----------
# This must be LAST so it doesn't shadow /api/*
app.mount("/", StaticFiles(directory="Game", html=True), name="static")
