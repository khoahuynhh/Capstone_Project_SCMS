"""rename recommendation face attributes

Revision ID: d1a9c6e4f2b8
Revises: c4d9f3a8b2e1
Create Date: 2026-05-07 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = "d1a9c6e4f2b8"
down_revision: Union[str, None] = "c4d9f3a8b2e1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column(
        "recommendations",
        "face_attributes",
        new_column_name="recommendation_context",
    )


def downgrade() -> None:
    op.alter_column(
        "recommendations",
        "recommendation_context",
        new_column_name="face_attributes",
    )
