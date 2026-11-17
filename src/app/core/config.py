import os
from pathlib import Path
from functools import lru_cache
from pydantic import computed_field, Field
from pydantic_settings import BaseSettings, SettingsConfigDict

APP_ENV = os.getenv("APP_ENV", "dev")
BASE_DIR = Path(__file__).resolve().parents[3] # 项目根目录
ENV_FILES = (BASE_DIR/".env", BASE_DIR/f".env.{APP_ENV}")

print("BASE_DIR:", BASE_DIR)

class DbSettings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="DB_",
                                      env_file=ENV_FILES,
                                      env_file_encoding="utf-8",
                                      extra="ignore")
    print("model_config", model_config)
    MYSQL_HOST: str = "127.0.0.1"
    MYSQL_PORT: int = 3306
    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str = ""
    MYSQL_DATABASE: str = "lib_agent"
    DB_ECHO: bool = False
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 20

    @computed_field
    @property
    def async_url(self) -> str:
        return (f"mysql+aiomysql://{self.MYSQL_USER}:{self.MYSQL_PASSWORD}"
                f"@{self.MYSQL_HOST}:{self.MYSQL_PORT}/{self.MYSQL_DATABASE}?charset=utf8mb4")



class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        # 元组形式: 后加载的覆盖先加载的
        # 优先级(低→高): .env < .env.{阶段} < 系统环境变量 < 代码传
        env_file=ENV_FILES,
        env_file_encoding="utf-8",
        extra="ignore")
    app_name: str = "lib_agent"
    app_env: str = APP_ENV
    debug: bool = False
    api_v1_prefix: str = "/api/v1"

    # 数据库配置
    db: DbSettings = Field(default_factory=DbSettings)

    @property
    def is_prod(self) -> bool:
        return self.app_env == "prod"

@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

