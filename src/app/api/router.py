from fastapi import APIRouter

from src.app.api import auth, user

api_router = APIRouter()

# ---- 认证(无业务前缀,路径即 /api/v1/auth/login) ----
api_router.include_router(router=auth.router)

# ---- 用户(无业务前缀,路径即 /api/v1/user) ----
api_router.include_router(router=user.router)

