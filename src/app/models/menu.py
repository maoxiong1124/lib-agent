from sqlalchemy import String, SmallInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column
from src.app.models.base_model import DbBaseModel


class Menu(DbBaseModel):
    __tablename__ = "sys_menu"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="主键ID")
    parent_id: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="父级ID,0=根")
    name: Mapped[str] = mapped_column(String(64), nullable=False, comment="路由名")
    title: Mapped[str] = mapped_column(String(64), nullable=False, comment="显示名称")
    type: Mapped[int] = mapped_column(SmallInteger, nullable=False, comment="0目录 1菜单 2按钮 3接口(API)")
    path: Mapped[str] = mapped_column(String(128), default="", comment="前端路由路径")
    component: Mapped[str] = mapped_column(String(255), default="", comment="前端组件路径")
    icon: Mapped[str] = mapped_column(String(64), default="", comment="图标")
    perm: Mapped[str] = mapped_column(String(128), default="", comment="权限标识,如 system:user:add")
    method: Mapped[str] = mapped_column(String(8), default="", comment="type=3时: GET/POST/PUT/DELETE")
    api_path: Mapped[str] = mapped_column(String(128), default="", comment="type=3时: 后端接口路径")
    sort: Mapped[int] = mapped_column(Integer, nullable=False, default=0, comment="排序")
    visible: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=1, comment="是否可见 1可见 0隐藏")
    status: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=1, comment="状态 1启用 0禁用")