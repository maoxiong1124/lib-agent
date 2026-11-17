# /auth/login /auth/register /auth/me
from fastapi import APIRouter

router = APIRouter(prefix="/auth", tags=["auth"])


# /auth/login /auth/register /auth/me
@router.post(path="/login", response_model=None)
def login():


    pass



