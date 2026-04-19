"""drop legacy recommendation acceptance columns

Revision ID: b8a12e42c9f0
Revises: 7f4b2e9c1a6d
Create Date: 2026-04-20 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "b8a12e42c9f0"
down_revision: Union[str, None] = "7f4b2e9c1a6d"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column("transactions", "accepted_recommendations")
    op.drop_column("recommendations", "purchased_items")
    op.drop_column("recommendations", "accepted")
    op.drop_column("branch_metrics", "acceptance_rate")
    op.drop_column("branch_metrics", "recommendations_accepted")


def downgrade() -> None:
    op.add_column(
        "branch_metrics",
        sa.Column("recommendations_accepted", sa.Integer(), nullable=True),
    )
    op.add_column(
        "branch_metrics",
        sa.Column("acceptance_rate", sa.Float(), nullable=True),
    )
    op.add_column(
        "recommendations",
        sa.Column("accepted", sa.Boolean(), nullable=True),
    )
    op.add_column(
        "recommendations",
        sa.Column("purchased_items", postgresql.JSON(astext_type=sa.Text()), nullable=True),
    )
    op.add_column(
        "transactions",
        sa.Column("accepted_recommendations", sa.Boolean(), nullable=True),
    )
