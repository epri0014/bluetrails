from pydantic import BaseModel

class WSAvatarOut(BaseModel):
    avatar_id: int
    name: str
    species: str
    intro: str
    image_neutral_url: str
    site_short_name: str  # join from EPA site

    class Config:
        from_attributes = True
