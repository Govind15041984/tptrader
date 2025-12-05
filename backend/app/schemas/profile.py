from pydantic import BaseModel
from typing import Optional


# ---------------------------------------------------------
# Base Schema (All common fields)
# ---------------------------------------------------------
class ProfileBase(BaseModel):
    user_name: str
    company_name: str
    mobile: str
    gst_number: Optional[str] = None
    address: Optional[str] = None
    logo_url: Optional[str] = None


# ---------------------------------------------------------
# Used when creating a profile
# ---------------------------------------------------------
class ProfileCreate(ProfileBase):
    pass


# ---------------------------------------------------------
# Used when updating profile (partial updates allowed)
# ---------------------------------------------------------
class ProfileUpdate(BaseModel):
    user_name: Optional[str] = None
    company_name: Optional[str] = None
    gst_number: Optional[str] = None
    address: Optional[str] = None
    logo_url: Optional[str] = None


# ---------------------------------------------------------
# Response Schema (adds user_id)
# ---------------------------------------------------------
class ProfileResponse(ProfileBase):
    user_id: int

    class Config:
        from_attributes = True

class UpdateLogoRequest(BaseModel):
    mobile: str
    logo_url: str
