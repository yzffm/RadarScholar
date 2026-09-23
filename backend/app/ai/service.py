import logging
from typing import TypeVar, cast

from pydantic import BaseModel

from app.core.config import settings
from app.ai.base import AIProvider
from app.ai.providers.gemini import GeminiProvider
from app.ai.providers.groq import GroqProvider

logger = logging.getLogger(__name__)

T = TypeVar("T", bound=BaseModel)

class AIUnavailableError(Exception):
    """Raised when all configured AI providers fail or are unavailable."""
    pass

class AIService:
    def __init__(self):
        self.providers: list[AIProvider] = []
        
        if not settings.AI_ENABLED:
            logger.info("AI features are disabled via configuration.")
            return

        # Initialize providers based on priority
        primary = settings.AI_PRIMARY_PROVIDER.lower()
        
        try:
            gemini = GeminiProvider()
        except ValueError as e:
            logger.warning(f"GeminiProvider initialization skipped: {e}")
            gemini = None
            
        try:
            groq = GroqProvider()
        except ValueError as e:
            logger.warning(f"GroqProvider initialization skipped: {e}")
            groq = None

        if primary == "gemini":
            if gemini: self.providers.append(gemini)
            if groq: self.providers.append(groq)
        elif primary == "groq":
            if groq: self.providers.append(groq)
            if gemini: self.providers.append(gemini)
        else:
            if gemini: self.providers.append(gemini)
            if groq: self.providers.append(groq)

    async def generate_structured(self, prompt: str, schema: type[T]) -> T:
        if not settings.AI_ENABLED or not self.providers:
            raise AIUnavailableError("AI service is disabled or no providers are configured.")

        last_error = None
        for provider in self.providers:
            provider_name = provider.__class__.__name__
            try:
                # Add bounded timeout logic in production if needed
                logger.debug(f"Attempting structured generation with {provider_name}")
                result = await provider.generate_structured(prompt, schema)
                return result
            except Exception as e:
                logger.warning(f"{provider_name} failed: {str(e)}")
                last_error = e

        logger.error("All AI providers failed.")
        raise AIUnavailableError("All AI providers are currently unavailable.") from last_error
