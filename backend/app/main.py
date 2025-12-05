print("🔥 MAIN.PY LOADED")
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.api.health import router as health_router
from app.api.login import router as login_router
from app.api.profile import router as profile_router

app = FastAPI()

#app.include_router(health_router, prefix="/api")
app.include_router(login_router, prefix="/auth")
app.include_router(profile_router, prefix="/profile")
