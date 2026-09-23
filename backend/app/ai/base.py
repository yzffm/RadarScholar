from abc import ABC, abstractmethod
from typing import TypeVar

from pydantic import BaseModel

T = TypeVar("T", bound=BaseModel)

class AIProvider(ABC):
    """Abstract base class for AI providers (Gemini, Groq, etc.)."""

    @abstractmethod
    async def generate(self, prompt: str) -> str:
        """Generate a natural language response."""
        ...

    @abstractmethod
    async def generate_structured(self, prompt: str, schema: type[T]) -> T:
        """Generate a structured response adhering to a Pydantic schema."""
        ...
