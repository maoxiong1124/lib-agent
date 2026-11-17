from fastapi import FastAPI

from src.app.api.router import api_router

app = FastAPI(title="lib-agent")

app.include_router(router=api_router, prefix="/api/v1", tags=["api"])

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}
