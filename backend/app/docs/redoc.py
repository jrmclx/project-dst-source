from fastapi import APIRouter
from fastapi.openapi.docs import get_redoc_html

router = APIRouter()


@router.get("/redoc", include_in_schema=False)
async def redoc():
    return get_redoc_html(
        openapi_url="/api/v1/openapi.json",
        title="VulgarIT Project - ReDoc",
        redoc_js_url="https://cdn.jsdelivr.net/npm/redoc@2.5.2/bundles/redoc.standalone.js",
    )
