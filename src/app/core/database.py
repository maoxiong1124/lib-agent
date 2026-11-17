from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from src.app.core.config import settings

engine = create_async_engine(
    settings.db.async_url,
    echo=settings.db.DB_ECHO,
    pool_size=settings.db.DB_POOL_SIZE,
    max_overflow=settings.db.DB_MAX_OVERFLOW,
    pool_pre_ping=True,
    pool_recycle=3600
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False
)

async def get_db()->AsyncGenerator[AsyncSession, None]:
    """FastAPI 依赖: async def xxx(db: AsyncSession = Depends(get_db))"""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
