from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Eco Game API")

# Global score
score = 0

# Item rules with their corresponding points
items = {
    "plastic": 10,
    "paint": 20,
    "pollution": 30
}


# Request body model
class Action(BaseModel):
    item: str   # "plastic" | "paint" | "pollution_clean"
    place: str  # "bin" | "beach"


@app.post("/play")
def play_game(action: Action):
    global score

    if action.item not in items:
        return {"success": False, "msg": "Invalid item", "score": score}

    points = items[action.item]

    if action.place == "bin":
        score += points
        return {"success": True, "msg": f"{action.item} placed in bin ✅ +{points}", "score": score}

    elif action.place == "beach":
        score -= points
        return {"success": False, "msg": f"{action.item} thrown on beach ❌ -{points}", "score": score}

    else:
        return {"success": False, "msg": "Invalid place", "score": score}


@app.get("/score")
def get_score():
    return {"score": score}
