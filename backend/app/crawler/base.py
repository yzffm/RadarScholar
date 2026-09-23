"""Base abstractions for the RadarScholar curated crawler.

Defines:
- ScrapedRequirement / ScrapedBenefit — intermediate Pydantic models
- ScrapedScholarship — normalized extraction output
- BaseScraper — abstract class each curated scraper must implement
"""

from abc import ABC, abstractmethod
from datetime import datetime

from pydantic import BaseModel, Field


class ScrapedRequirement(BaseModel):
    """Intermediate model for a parsed scholarship requirement.

    Fields map directly to the existing ScholarshipRequirement DB schema
    so the pipeline can persist without translation.
    """

    requirement_type: str  # e.g. GPA, SEMESTER, DEGREE_LEVEL, ORGANIZATION
    operator: str  # e.g. GTE, EQ, IN, CONTAINS, EXISTS
    value: dict | list | str | float | int  # Structured requirement data (JSON-compatible)
    description: str  # Original human-readable text from the source


class ScrapedBenefit(BaseModel):
    """Intermediate model for a parsed scholarship benefit."""

    benefit_type: str  # e.g. TUITION_FEE, LIVING_ALLOWANCE, TRAINING
    description: str  # Human-readable benefit description


class ScrapedScholarship(BaseModel):
    """Normalized extraction output from a curated scraper.

    This is the contract between source-specific parsers and
    the pipeline's persistence layer.  Every field must map
    to an existing M3/M4 database column.
    """

    provider_name: str
    source_url: str  # Official page URL — primary dedup key
    title: str
    summary: str
    description: str
    deadline: datetime | None = None
    application_url: str
    is_active: bool = True
    requirements: list[ScrapedRequirement] = Field(default_factory=list)
    benefits: list[ScrapedBenefit] = Field(default_factory=list)


class BaseScraper(ABC):
    """Abstract base for curated scholarship scrapers.

    Each concrete scraper:
    1. Targets a single curated official source.
    2. Returns ``list[ScrapedScholarship]`` without touching the DB.
    3. Is independently unit-testable with HTML fixtures.
    """

    provider_name: str
    source_url: str

    @abstractmethod
    def scrape(self) -> list[ScrapedScholarship]:
        """Fetch and parse scholarships from the official source.

        Returns a list of normalized ScrapedScholarship objects.
        Must NOT access the database.
        """
        ...

    def parse_html(self, html: str) -> list[ScrapedScholarship]:
        """Parse raw HTML into ScrapedScholarship objects.

        Separated from ``scrape()`` so tests can call this
        directly with fixture HTML without network access.
        """
        raise NotImplementedError(
            f"{self.__class__.__name__} does not implement parse_html"
        )
