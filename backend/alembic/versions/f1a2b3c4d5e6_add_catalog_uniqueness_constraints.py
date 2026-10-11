"""Add catalog uniqueness constraints."""

from collections.abc import Sequence

from alembic import op

revision: str = "f1a2b3c4d5e6"
down_revision: str | Sequence[str] | None = "a8b7c6d5e4f3"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_unique_constraint(
        "uq_scholarship_sources_provider_url",
        "scholarship_sources",
        ["provider_name", "source_url"],
    )
    op.create_unique_constraint(
        "uq_scholarships_source_application_url",
        "scholarships",
        ["source_id", "application_url"],
    )
    op.create_index(
        "ix_scholarships_source_id",
        "scholarships",
        ["source_id"],
    )
    op.create_index(
        "ix_scholarship_requirements_scholarship_id",
        "scholarship_requirements",
        ["scholarship_id"],
    )
    op.create_index(
        "ix_scholarship_benefits_scholarship_id",
        "scholarship_benefits",
        ["scholarship_id"],
    )


def downgrade() -> None:
    op.drop_index(
        "ix_scholarship_benefits_scholarship_id",
        table_name="scholarship_benefits",
    )
    op.drop_index(
        "ix_scholarship_requirements_scholarship_id",
        table_name="scholarship_requirements",
    )
    op.drop_index("ix_scholarships_source_id", table_name="scholarships")
    op.drop_constraint(
        "uq_scholarships_source_application_url",
        "scholarships",
        type_="unique",
    )
    op.drop_constraint(
        "uq_scholarship_sources_provider_url",
        "scholarship_sources",
        type_="unique",
    )
