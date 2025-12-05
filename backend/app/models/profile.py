from sqlalchemy import Column, Integer, String, Text
from app.models.base import Base
    
class Profile(Base):
    __tablename__ = "profiles"

    user_id = Column(Integer, primary_key=True, index=True)
    user_name = Column(String(100), nullable=False)
    company_name = Column(String(100), nullable=False)
    mobile = Column(String(15), unique=True, nullable=False, index=True)

    # New fields
    gst_number = Column(String(20), nullable=True)
    address = Column(Text, nullable=True)
    logo_url = Column(String(255), nullable=True)
