import json
from typing import TypeVar

from pydantic import BaseModel
from groq import AsyncGroq

from app.core.config import settings
from app.ai.base import AIProvider

T = TypeVar("T", bound=BaseModel)

class GroqProvider(AIProvider):
    def __init__(self):
        if not settings.GROQ_API_KEY:
            raise ValueError("GROQ_API_KEY is not set.")
        self.client = AsyncGroq(api_key=settings.GROQ_API_KEY)
        self.model = settings.GROQ_MODEL

    async def generate(self, prompt: str) -> str:
        response = await self.client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model=self.model,
        )
        return response.choices[0].message.content or ""

    async def generate_structured(self, prompt: str, schema: type[T]) -> T:
        # Note: Groq supports JSON mode, but for structured outputs we often
        # need to instruct the model to follow a specific JSON schema.
        # Alternatively, we can use instructor or just prompt engineering + json response_format.
        
        system_prompt = (
            "You are an API that outputs strictly in JSON format. "
            f"You must adhere exactly to the following JSON schema:\n{schema.model_json_schema()}"
        )
        
        response = await self.client.chat.completions.create(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ],
            model=self.model,
            response_format={"type": "json_object"}
        )
        content = response.choices[0].message.content or "{}"
        return schema.model_validate_json(content)
