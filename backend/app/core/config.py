# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # 基本信息
    PROJECT_NAME: str = "BlueTrails Backend"
    API_PREFIX: str = "/api/v1"
    ENV: str = "dev"

    # CORS 设置（前端跨域）
    # 可以配置成逗号分隔: "http://localhost:5173,https://myapp.com"
    CORS_ORIGINS: str = "*"

    # 数据库连接（以后接 Supabase / PostGIS）
    DATABASE_URL: str | None = None

    # AI 模型接口（以后接推理服务）
    MODEL_ENDPOINT: str | None = None

    # 外部 API（例如 AODN、HAB）
    AODN_API_KEY: str | None = None
    HAB_API_URL: str | None = None

    class Config:
        env_file = ".env"   # 支持从项目根目录的 .env 文件加载
        extra = "ignore"

settings = Settings()