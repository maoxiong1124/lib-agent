from datetime import datetime

from sqlalchemy import String, SmallInteger, DateTime, Integer, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from src.app.models.base_model import DbBaseModel


class User(DbBaseModel):
    __tablename__ = "sys_user"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="登录名")
    username: Mapped[str] = mapped_column(String(32), unique=True, nullable=False, comment="用户名")
    password: Mapped[str] = mapped_column(String(100), nullable=False, comment="密码")
    nickname: Mapped[str] = mapped_column(String(32), comment="昵称", default="")
    email: Mapped[str] = mapped_column(String(64), comment="邮箱", default="")
    phone: Mapped[str] = mapped_column(String(20), comment="手机", default="")
    avatar: Mapped[str] = mapped_column(String(255), comment="头像", default="")
    gender: Mapped[int] = mapped_column(SmallInteger, comment="性别 0未知 1男 2女", default=0)
    org_id: Mapped[int] = mapped_column(Integer, comment="主部门ID")
    status: Mapped[int] = mapped_column(SmallInteger, nullable=False, comment="状态 1启用 0禁用")
    is_super: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0, comment="是否超管 1超级管理员(跳过一切校验)'")
    last_login: Mapped[datetime] = mapped_column(DateTime, comment="最后登录时间")
    deleted: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0, comment="是否删除")

class UserOrg(DbBaseModel):
    __tablename__ = "sys_user_org"
    __table_args__ = (UniqueConstraint("user_id", "org_id", name="uk_user_org"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    user_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="用户ID")
    org_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="部门ID")
    is_main: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0, comment="是否主部门冗余标记")

class UserPost(DbBaseModel):
    __tablename__ = "sys_user_post"
    __table_args__ = (UniqueConstraint("user_id", "post_id", name="uk_user_post"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    user_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="用户ID")
    post_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="岗位ID")


class UserRole(DbBaseModel):
    __tablename__ = "sys_user_role"
    __table_args__ = (UniqueConstraint("user_id", "role_id", name="uk_user_role"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    user_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="用户ID")
    role_id: Mapped[int] = mapped_column(Integer, nullable=False, comment="角色ID")