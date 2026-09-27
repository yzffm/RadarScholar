"""Add explicit scholarship data provenance."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


revision: str = "a8b7c6d5e4f3"
down_revision: Union[str, Sequence[str], None] = "7fdda7f7aa30"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "scholarships",
        sa.Column(
            "data_origin",
            sa.String(),
            nullable=False,
            server_default="CRAWLER",
        ),
    )
    op.alter_column("scholarships", "data_origin", server_default=None)


def downgrade() -> None:
    op.drop_column("scholarships", "data_origin")
