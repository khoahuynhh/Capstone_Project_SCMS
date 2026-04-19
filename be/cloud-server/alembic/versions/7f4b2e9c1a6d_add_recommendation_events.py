"""add recommendation events

Revision ID: 7f4b2e9c1a6d
Revises: 05d05f698d17
Create Date: 2026-04-19 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "7f4b2e9c1a6d"
down_revision: Union[str, None] = "05d05f698d17"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "recommendation_events",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("event_type", sa.String(length=32), nullable=False),
        sa.Column("product_id", sa.Integer(), nullable=False),
        sa.Column("customer_id", sa.Integer(), nullable=True),
        sa.Column("branch_id", sa.String(length=50), nullable=True),
        sa.Column("device_id", sa.String(length=50), nullable=True),
        sa.Column("surface", sa.String(length=80), nullable=False),
        sa.Column("algorithm", sa.String(length=80), nullable=True),
        sa.Column("position", sa.Integer(), nullable=True),
        sa.Column("session_id", sa.String(length=100), nullable=True),
        sa.Column("recommendation_id", sa.Integer(), nullable=True),
        sa.Column("event_metadata", postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column("timestamp", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["branch_id"], ["stores.id"]),
        sa.ForeignKeyConstraint(["customer_id"], ["customers.id"]),
        sa.ForeignKeyConstraint(["device_id"], ["edge_devices.id"]),
        sa.ForeignKeyConstraint(["product_id"], ["products.id"]),
        sa.ForeignKeyConstraint(["recommendation_id"], ["recommendations.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_recommendation_events_id"),
        "recommendation_events",
        ["id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_event_type"),
        "recommendation_events",
        ["event_type"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_product_id"),
        "recommendation_events",
        ["product_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_customer_id"),
        "recommendation_events",
        ["customer_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_branch_id"),
        "recommendation_events",
        ["branch_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_device_id"),
        "recommendation_events",
        ["device_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_surface"),
        "recommendation_events",
        ["surface"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_session_id"),
        "recommendation_events",
        ["session_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_recommendation_id"),
        "recommendation_events",
        ["recommendation_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_recommendation_events_timestamp"),
        "recommendation_events",
        ["timestamp"],
        unique=False,
    )
    op.create_index(
        "ix_recommendation_events_type_time",
        "recommendation_events",
        ["event_type", "timestamp"],
        unique=False,
    )
    op.create_index(
        "ix_recommendation_events_surface_time",
        "recommendation_events",
        ["surface", "timestamp"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(
        "ix_recommendation_events_surface_time",
        table_name="recommendation_events",
    )
    op.drop_index(
        "ix_recommendation_events_type_time",
        table_name="recommendation_events",
    )
    op.drop_index(op.f("ix_recommendation_events_timestamp"), table_name="recommendation_events")
    op.drop_index(
        op.f("ix_recommendation_events_recommendation_id"),
        table_name="recommendation_events",
    )
    op.drop_index(op.f("ix_recommendation_events_session_id"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_surface"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_device_id"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_branch_id"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_customer_id"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_product_id"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_event_type"), table_name="recommendation_events")
    op.drop_index(op.f("ix_recommendation_events_id"), table_name="recommendation_events")
    op.drop_table("recommendation_events")
