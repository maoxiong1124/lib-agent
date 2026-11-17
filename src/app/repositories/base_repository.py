# 通用异步查询基础类
from typing import Generic, Any
from typing import TypeVar
from sqlalchemy import select, Sequence, Select
from sqlalchemy.ext.asyncio import AsyncSession
from src.app.models import DbBaseModel

ModelType = TypeVar("ModelType", bound=DbBaseModel)

class BaseRepository(Generic[ModelType]):
    """
       MySQL 异步查询基础类，所有表 Repository 继承并指定模型类型:

           class UserRepository(BaseRepository[User]):
               def __init__(self, db: AsyncSession):
                   super().__init__(User, db)
       """
    def __init__(self, model: ModelType, db: AsyncSession):
        """
        :param model: 模型类
        :param db: 数据库会话
        """
        self.model = model
        self.db = db

    # 查询语句
    async def get(self, obj_id: int) -> ModelType|None:
        """
        按主键查询
        """
        return await self.db.get(self.model, obj_id)

    async def get_by(self, **kwargs) -> ModelType|None:
        """
        按条件查询单个
        """
        result = await self.db.execute(select(self.model).filter_by(**kwargs).limit(1))
        return result.scalar_one_or_none()

    async def list(self,
                   *conditions: Any,
                   offset: int = 0,
                   limit: int = 100,
                   order_by: Any = None) -> Sequence[ModelType]:
        """
        查询列表
        """
        stmt: Select = select(self.model).where(*conditions)
        stmt = self._apply_order_by(stmt, order_by=order_by)
        result = await self.db.execute(stmt.offset(offset).limit(limit))
        return result.scalars().all()

    @staticmethod
    def _apply_order_by(stmt: Select, order_by: Any) -> Select:
        """
        应用排序
        """
        if order_by is None:
            return stmt.order_by("id")
        return stmt.order_by(*(order_by if isinstance(order_by, (list, tuple)) else [order_by]))



