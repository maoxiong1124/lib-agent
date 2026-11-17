from sqlalchemy.ext.asyncio import AsyncSession

from src.app.models import User
from src.app.repositories.user_repository import UserRepository

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.user_repo = UserRepository(db)

    async def get_user_id(self, user_id: int) -> User|None:
        return await self.user_repo.get_by_id(user_id)
