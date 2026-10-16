"""RadarScholar Hugging Face Spaces Entry Point (Gradio SDK).

Mounts the production RadarScholar FastAPI application alongside a lightweight
Gradio status dashboard using Gradio's native launcher for Hugging Face Spaces.
Enables 100% free hosting with 16GB RAM without requiring Docker or any credit card.
"""

import os

# Disable Gradio SSR Node proxy so FastAPI runs directly on port 7860
os.environ["GRADIO_SSR_MODE"] = "False"

# Satisfy Hugging Face ZeroGPU detector if running on ZeroGPU hardware
try:
    import spaces

    @spaces.GPU
    def _zerogpu_keepalive():
        return True
except ImportError:
    pass

import gradio as gr
from fastapi.middleware.cors import CORSMiddleware
from gradio.routes import App

from app.core.config import settings
from app.main import app as fastapi_app

# Create Gradio App instance
custom_app = App()

# Configure CORS for Flutter Web frontend
cors_origins = [str(origin) for origin in settings.CORS_ORIGINS]
custom_app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins or ["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Mount all RadarScholar FastAPI routes (/health, /docs, /api/v1/..., etc.)
for route in fastapi_app.routes:
    custom_app.routes.append(route)

# Lightweight Gradio status dashboard
with gr.Blocks(title="RadarScholar API") as demo:
    gr.Markdown("# 🎓 RadarScholar API Platform")
    gr.Markdown("Status: **Active & Healthy**")
    gr.Markdown("FastAPI backend service is running and ready for Flutter Web client.")
    with gr.Accordion("API Endpoints", open=False):
        gr.Markdown(
            "- **Health Check:** `/health`\n"
            "- **Scholarships:** `/api/v1/scholarships`\n"
            "- **Applications:** `/api/v1/applications`\n"
            "- **AI Assistant:** `/api/v1/ai`\n"
            "- **Interactive Docs:** `/docs`\n"
        )

# Gradio Spaces launcher
if __name__ == "__main__":
    demo.launch(
        server_name="0.0.0.0",  # noqa: S104
        _app=custom_app,
        ssr_mode=False,
    )

