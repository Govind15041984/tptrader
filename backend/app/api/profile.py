print("🔥 LOADED: profile router")

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.core.database import get_db
from app.schemas.profile import ProfileCreate, ProfileUpdate, ProfileResponse
from app.services.profile_service import create_profile, get_profile, update_profile
from app.services.minio_service import generate_presigned_url
from app.schemas.profile import UpdateLogoRequest
from app.services.profile_service import update_logo_in_db

router = APIRouter(tags=["Profile"])


# ---------------------------------------------------------
# CREATE PROFILE
# ---------------------------------------------------------
@router.post("/create", response_model=ProfileResponse)
def create_profile_api(data: ProfileCreate, db: Session = Depends(get_db)):
    existing = get_profile(db, data.mobile)
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists")

    return create_profile(db, data)


# ---------------------------------------------------------
# GET PROFILE BY MOBILE
# ---------------------------------------------------------
@router.get("/{mobile}", response_model=ProfileResponse | dict)
def get_profile_api(mobile: str, db: Session = Depends(get_db)):
    profile = get_profile(db, mobile)
    return profile or {}     # return empty when not found


# ---------------------------------------------------------
# UPDATE PROFILE
# ---------------------------------------------------------
@router.put("/{mobile}", response_model=ProfileResponse)
def update_profile_api(mobile: str, data: ProfileUpdate, db: Session = Depends(get_db)):
    updated = update_profile(db, mobile, data)
    if not updated:
        raise HTTPException(status_code=404, detail="Profile not found")

    return updated

class PresignRequest(BaseModel):
    mobile: str

@router.post("/photo/presign")
def presign_photo_upload(req: PresignRequest):
    uploadUrl, finalUrl = generate_presigned_url(req.mobile)
    return {
        "uploadUrl": uploadUrl,
        "finalUrl": finalUrl
    }

@router.post("/update_logo")
def update_logo(req: UpdateLogoRequest):
    ok = update_logo_in_db(req.mobile, req.logo_url)

    if ok:
        return {"status": "ok", "message": "Logo updated"}
    else:
        return {"status": "fail", "message": "Update failed"}

