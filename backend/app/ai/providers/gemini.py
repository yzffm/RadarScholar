import json
from typing import TypeVar

from pydantic import BaseModel
from google import genai
from google.genai import types

from app.core.config import settings
from app.ai.base import AIProvider

T = TypeVar("T", bound=BaseModel)

class GeminiProvider(AIProvider):
    def __init__(self):
        if not settings.GEMINI_API_KEY:
            raise ValueError("GEMINI_API_KEY is not set.")
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = settings.GEMINI_MODEL

    async def generate(self, prompt: str) -> str:
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=prompt,
        )
        return response.text

    async def generate_structured(self, prompt: str, schema: type[T]) -> T:
        # Use structured outputs capability
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=schema,
            ),
        )
        # Parse the JSON string into the Pydantic schema
        return schema.model_validate_json(response.text)
