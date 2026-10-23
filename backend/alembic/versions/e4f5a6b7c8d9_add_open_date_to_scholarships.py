"""Add open_date column to scholarships."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "e4f5a6b7c8d9"
down_revision: str | Sequence[str] | None = "c3d4e5f6a7b8"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "scholarships",
        sa.Column("open_date", sa.DateTime(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("scholarships", "open_date")

