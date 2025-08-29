# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
<<<<<<< HEAD
from .config import CORS_ORIGINS
from .routers import ws_routes, core_routes

app = FastAPI(title="Beaches + Water Story API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
=======
from app.routes import router as api_router

app = FastAPI(title="BlueTrails Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
>>>>>>> 8942bf8 (backend first-vision)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

<<<<<<< HEAD
@app.get("/")
def root():
    return {
        "message": "API is running",
        "docs": "/docs",
        "redoc": "/redoc"
    }

@app.get("/healthz")
def healthz():
    return {"status": "ok"}

# register routers
app.include_router(core_routes.router, prefix="/api")
app.include_router(ws_routes.router, prefix="/api/ws")
=======
app.include_router(api_router, prefix="/api/v1")
>>>>>>> 8942bf8 (backend first-vision)
