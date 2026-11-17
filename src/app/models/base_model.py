from datetime import datetime

from sqlalchemy import DateTime, Integer
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class DbBaseModel(DeclarativeBase):
    """
    The base model for all database models.
    """
    create_time: Mapped[datetime] = mapped_column(DateTime, default=datetime.now(), comment="创建时间")
    update_time: Mapped[datetime] = mapped_column(DateTime, default=datetime.now(), onupdate=datetime.now(), comment="更新时间")
    creator: Mapped[int] = mapped_column(Integer, comment="创建人")
    update_by: Mapped[int] = mapped_column(Integer, comment="更新人")
