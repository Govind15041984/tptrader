from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.models.profile import Profile
from app.core.database import get_db

router = APIRouter()

STATIC_OTP = "1234"

class LoginRequest(BaseModel):
    mobile: str
    otp: str

@router.post("/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):

    # 1. Validate OTP
    if payload.otp != STATIC_OTP:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid OTP"
        )

    # 2. Check if user exists in PROFILES table
    profile = db.query(Profile).filter(Profile.mobile == payload.mobile).first()

    if profile:
        # Existing user: profile already created earlier
        return {
            "login_ok": True,
            "profile_needed": False,
            "profile": {
                "user_id": profile.user_id,
                "name": profile.user_name,
                "company": profile.company_name,
                "mobile": profile.mobile,
                "gst_number": profile.gst_number,
                "address": profile.address,
                "logo_url": profile.logo_url
            }
        }

    # 3. New user: needs to create profile
    return {
        "login_ok": True,
        "profile_needed": True
    }

