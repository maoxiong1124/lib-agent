from fastapi import APIRouter
from fastapi.params import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from src.app.core.database import get_db
from src.app.schemas.common import ApiResponse
from src.app.schemas.user import UserResp
from src.app.services.user_service import UserService

router = APIRouter(prefix="/user", tags=["user"])

@router.get(path="/{user_id}", response_model=ApiResponse[UserResp])
async def get_user(user_id: int, db: AsyncSession = Depends(get_db)):
    user_service = UserService(db)
    user = await user_service.get_user_id(user_id)
    return ApiResponse.success(data=UserResp.model_validate(user))
