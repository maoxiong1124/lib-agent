from sqlalchemy import String, SmallInteger, Integer, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from src.app.models.base_model import DbBaseModel


class Role(DbBaseModel):
    __tablename__ = "sys_role"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    code: Mapped[str] = mapped_column(String(32), unique=True, nullable=False, comment="角色编码")
    name: Mapped[str] = mapped_column(String(32), nullable=False, comment="角色名称")
    data_scope: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=4, comment="数据范围 1全部 2本部门及以下 3本部门 4仅本人 5自定义")
    description: Mapped[str] = mapped_column(String(200), default="", comment="角色描述")
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="排序")
    status: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=1, comment="状态 1启用 0禁用")

class RoleOrg(DbBaseModel):
    __tablename__ = "sys_role_org"
    __table_args__ = (UniqueConstraint("role_id", "org_id", name="uk_role_org"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    role_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="角色ID")
    org_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="组织ID")

class RoleMenu(DbBaseModel):
    __tablename__ = "sys_role_menu"
    __table_args__ = (UniqueConstraint("role_id", "menu_id", name="uk_role_menu"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    role_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="角色ID")
    menu_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="菜单/权限ID")