"""create user profiles table

Revision ID: b1c935995d61
Revises: 
Create Date: 2026-09-21 22:37:43.013388

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b1c935995d61'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'user_profiles',
        sa.Column('id', sa.UUID(as_uuid=False), primary_key=True, comment="Supabase auth user UUID"),
        sa.Column('email', sa.String(320), nullable=False, index=True),
        sa.Column('display_name', sa.String(255), nullable=True),
        sa.Column('avatar_url', sa.Text, nullable=True),
        sa.Column('university', sa.String(255), nullable=True),
        sa.Column('faculty', sa.String(255), nullable=True),
        sa.Column('major', sa.String(255), nullable=True),
        sa.Column('degree_level', sa.Enum('D3', 'D4', 'S1', 'S2', 'S3', name='degree_level_enum'), nullable=True),
        sa.Column('semester', sa.Integer, nullable=True),
        sa.Column('gpa', sa.Float, nullable=True),
        sa.Column('organizations', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('achievements', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('competitions', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('volunteering', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('internships', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('certifications', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('skills', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('career_interests', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('fields_of_interest', sa.JSON().with_variant(sa.dialects.postgresql.ARRAY(sa.Text), 'postgresql'), nullable=True, server_default='[]'),
        sa.Column('goals', sa.Text, nullable=True),
        sa.Column('created_at', sa.DateTime, nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime, nullable=False, server_default=sa.text('now()')),
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table('user_profiles')
    op.execute('DROP TYPE IF EXISTS degree_level_enum')
