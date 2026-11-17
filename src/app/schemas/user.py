from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field, field_serializer

class UserResp(BaseModel):
    model_config = ConfigDict(from_attributes=True) # 支持 ORM 对象直接 .model_validate()

    id: int = Field(description="用户ID")
    username: str = Field(description="用户名")
    nickname: str = Field(description="昵称")
    email: str = Field(description="邮箱")
    phone: str = Field(description="手机")
    avatar: str = Field(description="头像")
    gender: int = Field(description="性别")
    org_id: int = Field(description="组织ID", validation_alias="org_id", serialization_alias="orgId")
    status: int = Field(description="状态")
    is_super: int = Field(description="是否超管", validation_alias="is_super", serialization_alias="isSuper")
    last_login: datetime|None = Field(description="最后登录时间", default=None, validation_alias="last_login", serialization_alias="lastLogin")
    create_time: datetime = Field(description="创建时间", validation_alias="create_time", serialization_alias="createTime")

    @field_serializer("last_login", "create_time")
    def serialize_datetime(self, v: datetime | None) -> str | None:
        return v.strftime("%Y-%m-%d %H:%M:%S") if v else None
