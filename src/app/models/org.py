from sqlalchemy import String, SmallInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column
from src.app.models.base_model import DbBaseModel


class Org(DbBaseModel):
    __tablename__ = "sys_org"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    parent_id: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="父组织ID,0=根")
    ancestors: Mapped[str] = mapped_column(String(500), nullable=False, default="", comment="祖级路径,如 0,1,2")
    name: Mapped[str] = mapped_column(String(64), nullable=False, comment="组织名称")
    code: Mapped[str] = mapped_column(String(32), default="", comment="组织编码")
    type: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=2, comment="1公司 2部门 3小组")
    leader_id: Mapped[int] = mapped_column(Integer, comment="负责人用户ID")
    phone: Mapped[str] = mapped_column(String(20), default="", comment="联系电话")
    email: Mapped[str] = mapped_column(String(64), default="", comment="邮箱")
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="排序")
    status: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=1, comment="状态 1启用 0禁用")
    deleted: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0, comment="是否删除")


class Post(DbBaseModel):
    __tablename__ = "sys_post"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    code: Mapped[str] = mapped_column(String(32), unique=True, nullable=False, comment="岗位编码")
    name: Mapped[str] = mapped_column(String(32), nullable=False, comment="岗位名称")
    level: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="职级,数字越小越高")
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="排序")
    status: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=1, comment="状态 1启用 0禁用")