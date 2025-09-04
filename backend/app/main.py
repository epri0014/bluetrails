# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import CORS_ORIGINS
from .routers import ws_routes, core_routes

app = FastAPI(title="Beaches + Water Story API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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