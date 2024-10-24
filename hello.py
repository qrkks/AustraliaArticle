from fastapi import FastAPI, APIRouter, Request
from fastapi.responses import HTMLResponse
import pandas as pd
from fastapi.templating import Jinja2Templates
import pygwalker as pyg

# 创建 FastAPI 主应用实例
app = FastAPI()

router = APIRouter(prefix="/api")
# 指定模板文件夹
templates = Jinja2Templates(directory="templates")


@app.get("/")
async def read_root(request: Request):
    # 返回一个使用 Jinja2 渲染的 HTML 页面
    return templates.TemplateResponse("index.html", {"request": request, "title": "Welcome to FastAPI"})


@app.get('/table', response_class=HTMLResponse)
async def table():
    data = pd.read_csv('db/data.csv')
    return data.to_html()


@app.get("/data")
def data():
    data = pd.read_csv('db/data.csv')
    return data.fillna("").to_dict(orient="records")

@app.get("/pw", response_class=HTMLResponse)
async def pw(request: Request):
    # 读取 CSV 文件中的数据
    data = pd.read_csv('db/data.csv')
    # 使用 Pygwalker 生成交互式数据可视化的 HTML 组件
    walker_html = pyg.walk(data, return_html=True)

    # 返回模板，并将 walker_html 传入模板上下文
    return templates.TemplateResponse("walker.html", {"request": request, "walker_html": walker_html})



# router


@router.get("/")
async def main_router():
    return {"message": "hello world from router /"}


@router.get('')
async def main_router():
    return {"message": "hello world from router "}


@router.get("/hello")
async def hello():
    return {"message": "hello world from router /hello"}

app.include_router(router)


# 使用 uvicorn 启动应用
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("hello:app", host="127.0.0.1", port=8000, reload=True)
