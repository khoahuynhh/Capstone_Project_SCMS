"""add raw and cart association rule tables

Revision ID: c4d9f3a8b2e1
Revises: b8a12e42c9f0
Create Date: 2026-04-29 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "c4d9f3a8b2e1"
down_revision: Union[str, None] = "b8a12e42c9f0"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "association_rules_raw",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column(
            "antecedent_product_ids",
            postgresql.JSON(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column(
            "consequent_product_ids",
            postgresql.JSON(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column("antecedent_size", sa.Integer(), nullable=False),
        sa.Column("consequent_size", sa.Integer(), nullable=False),
        sa.Column("confidence", sa.Float(), nullable=False),
        sa.Column("lift", sa.Float(), nullable=True),
        sa.Column("support", sa.Float(), nullable=True),
        sa.Column("algorithm", sa.String(length=50), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("generated_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_association_rules_raw_id"), "association_rules_raw", ["id"])
    op.create_index(
        op.f("ix_association_rules_raw_antecedent_size"),
        "association_rules_raw",
        ["antecedent_size"],
    )
    op.create_index(
        op.f("ix_association_rules_raw_consequent_size"),
        "association_rules_raw",
        ["consequent_size"],
    )
    op.create_index(
        op.f("ix_association_rules_raw_is_active"),
        "association_rules_raw",
        ["is_active"],
    )
    op.create_index(
        op.f("ix_association_rules_raw_generated_at"),
        "association_rules_raw",
        ["generated_at"],
    )
    op.create_index(
        "ix_association_rules_raw_sizes",
        "association_rules_raw",
        ["antecedent_size", "consequent_size"],
    )

    op.add_column(
        "product_associations",
        sa.Column("source_rule_id", sa.Integer(), nullable=True),
    )
    op.create_index(
        op.f("ix_product_associations_source_rule_id"),
        "product_associations",
        ["source_rule_id"],
    )
    op.create_foreign_key(
        "fk_product_associations_source_rule_id",
        "product_associations",
        "association_rules_raw",
        ["source_rule_id"],
        ["id"],
        ondelete="SET NULL",
    )

    op.create_table(
        "cart_association_rules",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("source_rule_id", sa.Integer(), nullable=False),
        sa.Column(
            "antecedent_product_ids",
            postgresql.JSON(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column(
            "consequent_product_ids",
            postgresql.JSON(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column("antecedent_size", sa.Integer(), nullable=False),
        sa.Column("consequent_size", sa.Integer(), nullable=False),
        sa.Column("confidence", sa.Float(), nullable=False),
        sa.Column("lift", sa.Float(), nullable=True),
        sa.Column("support", sa.Float(), nullable=True),
        sa.ForeignKeyConstraint(
            ["source_rule_id"],
            ["association_rules_raw.id"],
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("source_rule_id"),
    )
    op.create_index(op.f("ix_cart_association_rules_id"), "cart_association_rules", ["id"])
    op.create_index(
        op.f("ix_cart_association_rules_source_rule_id"),
        "cart_association_rules",
        ["source_rule_id"],
    )
    op.create_index(
        op.f("ix_cart_association_rules_antecedent_size"),
        "cart_association_rules",
        ["antecedent_size"],
    )
    op.create_index(
        op.f("ix_cart_association_rules_consequent_size"),
        "cart_association_rules",
        ["consequent_size"],
    )
    op.create_index(
        "ix_cart_association_rules_sizes",
        "cart_association_rules",
        ["antecedent_size", "consequent_size"],
    )


def downgrade() -> None:
    op.drop_index("ix_cart_association_rules_sizes", table_name="cart_association_rules")
    op.drop_index(
        op.f("ix_cart_association_rules_consequent_size"),
        table_name="cart_association_rules",
    )
    op.drop_index(
        op.f("ix_cart_association_rules_antecedent_size"),
        table_name="cart_association_rules",
    )
    op.drop_index(
        op.f("ix_cart_association_rules_source_rule_id"),
        table_name="cart_association_rules",
    )
    op.drop_index(op.f("ix_cart_association_rules_id"), table_name="cart_association_rules")
    op.drop_table("cart_association_rules")

    op.drop_constraint(
        "fk_product_associations_source_rule_id",
        "product_associations",
        type_="foreignkey",
    )
    op.drop_index(
        op.f("ix_product_associations_source_rule_id"),
        table_name="product_associations",
    )
    op.drop_column("product_associations", "source_rule_id")

    op.drop_index("ix_association_rules_raw_sizes", table_name="association_rules_raw")
    op.drop_index(
        op.f("ix_association_rules_raw_generated_at"),
        table_name="association_rules_raw",
    )
    op.drop_index(
        op.f("ix_association_rules_raw_is_active"),
        table_name="association_rules_raw",
    )
    op.drop_index(
        op.f("ix_association_rules_raw_consequent_size"),
        table_name="association_rules_raw",
    )
    op.drop_index(
        op.f("ix_association_rules_raw_antecedent_size"),
        table_name="association_rules_raw",
    )
    op.drop_index(op.f("ix_association_rules_raw_id"), table_name="association_rules_raw")
    op.drop_table("association_rules_raw")
