from sqlalchemy.ext.asyncio import AsyncSession

from src.app.models import User
from src.app.repositories.base_repository import BaseRepository

class UserRepository(BaseRepository[User]):
    def __init__(self, db: AsyncSession):
        super().__init__(User, db)


    async def get_by_id(self, obj_id: int) -> User|None:
        return await super().get(obj_id)
