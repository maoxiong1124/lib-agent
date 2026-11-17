from typing import TypeVar, Generic

from pydantic import BaseModel

# 定义泛型类型变量
T = TypeVar("T")

"""
统一返回结构，所有接口都用它包一层
"""
class ApiResponse(BaseModel, Generic[T]):
    """统一返回结构，所有接口都用它包一层"""
    code: int = 0
    message: str = "success"
    data: T | None = None

    @classmethod
    def success(cls, data: T | None = None, message: str = "success") -> "ApiResponse[T]":
        return cls(data=data, message=message)

    @classmethod
    def error(cls, code: int, message: str) -> "ApiResponse[T]":
        return cls(code=code, message=message)

class PageResult(BaseModel, Generic[T]):
    """统一分页结构，作为 ApiResponse.data 使用"""
    total: int
    page: int
    size: int
    items: list[T] | None = []

    @classmethod
    def create(cls, total: int, page: int, size: int, items: list[T]) -> "PageResult[T]":
        return cls(total=total, page=page, size=size, items=items)
