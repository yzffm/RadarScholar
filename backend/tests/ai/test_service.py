import pytest
from unittest.mock import patch, AsyncMock
from pydantic import BaseModel
from app.ai.service import AIService, AIUnavailableError
from app.ai.base import AIProvider

class DummySchema(BaseModel):
    result: str

class MockProvider(AIProvider):
    def __init__(self, name: str, should_fail: bool = False, result: str = "success"):
        self.name = name
        self.should_fail = should_fail
        self._result = result
        
    async def generate(self, prompt: str) -> str:
        if self.should_fail:
            raise Exception(f"{self.name} failed")
        return self._result
        
    async def generate_structured(self, prompt: str, schema: type[BaseModel]) -> BaseModel:
        if self.should_fail:
            raise Exception(f"{self.name} failed")
        return schema(result=f"{self.name} {self._result}")

@pytest.fixture
def mock_settings():
    with patch("app.ai.service.settings") as mock:
        mock.AI_ENABLED = True
        mock.AI_PRIMARY_PROVIDER = "gemini"
        yield mock

@pytest.mark.asyncio
async def test_ai_service_success(mock_settings):
    with patch("app.ai.service.GeminiProvider") as mock_gemini, \
         patch("app.ai.service.GroqProvider") as mock_groq:
        mock_gemini.return_value = MockProvider("Gemini")
        mock_groq.return_value = MockProvider("Groq")
        
        service = AIService()
        result = await service.generate_structured("test", DummySchema)
        assert result.result == "Gemini success"

@pytest.mark.asyncio
async def test_ai_service_fallback(mock_settings):
    with patch("app.ai.service.GeminiProvider") as mock_gemini, \
         patch("app.ai.service.GroqProvider") as mock_groq:
        mock_gemini.return_value = MockProvider("Gemini", should_fail=True)
        mock_groq.return_value = MockProvider("Groq")
        
        service = AIService()
        result = await service.generate_structured("test", DummySchema)
        assert result.result == "Groq success"

@pytest.mark.asyncio
async def test_ai_service_total_failure(mock_settings):
    with patch("app.ai.service.GeminiProvider") as mock_gemini, \
         patch("app.ai.service.GroqProvider") as mock_groq:
        mock_gemini.return_value = MockProvider("Gemini", should_fail=True)
        mock_groq.return_value = MockProvider("Groq", should_fail=True)
        
        service = AIService()
        with pytest.raises(AIUnavailableError):
            await service.generate_structured("test", DummySchema)
