from sqlalchemy.orm import Session
from app.models.profile import Profile
from app.schemas.profile import ProfileCreate, ProfileUpdate
from app.models.profile import Profile
from app.core.database import SessionLocal


# ---------------------------------------------------------
# Create Profile
# ---------------------------------------------------------
def create_profile(db: Session, data: ProfileCreate):
    new_profile = Profile(
        user_name=data.user_name,
        company_name=data.company_name,
        mobile=data.mobile,
        gst_number=data.gst_number,
        address=data.address,
        logo_url=data.logo_url,
    )
    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)
    return new_profile


# ---------------------------------------------------------
# Get Profile (by mobile)
# ---------------------------------------------------------
def get_profile(db: Session, mobile: str):
    return db.query(Profile).filter(Profile.mobile == mobile).first()


# ---------------------------------------------------------
# Update Profile (partial update)
# ---------------------------------------------------------
def update_profile(db: Session, mobile: str, data: ProfileUpdate):
    profile = get_profile(db, mobile)
    if not profile:
        return None

    # Update only provided fields
    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(profile, key, value)

    db.commit()
    db.refresh(profile)
    return profile

def update_logo_in_db(mobile: str, url: str):
    db = SessionLocal()
    try:
        profile = db.query(Profile).filter(Profile.mobile == mobile).first()
        if not profile:
            return False

        profile.logo_url = url
        db.commit()
        return True

    except Exception as e:
        print("Error updating logo:", e)
        return False

    finally:
        db.close()
