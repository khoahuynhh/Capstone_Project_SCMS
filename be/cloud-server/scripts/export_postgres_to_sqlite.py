"""
Utility script to copy every ORM table from PostgreSQL into a SQLite file.

Example:
    python be/cloud-server/scripts/export_postgres_to_sqlite.py \
        --postgres-url postgresql://user:pass@localhost:5432/retail_db \
        --sqlite-path demo_data/demo.sqlite --overwrite
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
from typing import Iterable, List

from sqlalchemy import create_engine, select, text
from sqlalchemy.engine import Connection
from sqlalchemy.exc import SQLAlchemyError

from config import settings
from database.models import Base


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export the PostgreSQL database into a SQLite file "
        "using the ORM models."
    )
    parser.add_argument(
        "--postgres-url",
        dest="postgres_url",
        default=None,
        help="SQLAlchemy URL for the source PostgreSQL database. "
        "Defaults to settings.DATABASE_URL / env DATABASE_URL.",
    )
    parser.add_argument(
        "--sqlite-path",
        dest="sqlite_path",
        default="demo.sqlite",
        help="Path to the output SQLite file (default: demo.sqlite).",
    )
    parser.add_argument(
        "--batch-size",
        dest="batch_size",
        type=int,
        default=500,
        help="Rows to insert per batch when copying tables (default: 500).",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Remove the SQLite file if it already exists.",
    )
    return parser.parse_args()


def resolve_postgres_url(cli_url: str | None) -> str:
    if cli_url:
        return cli_url
    if settings.DATABASE_URL:
        return settings.DATABASE_URL
    env_url = os.getenv("DATABASE_URL")
    if env_url:
        return env_url
    raise SystemExit("Postgres URL missing. Provide --postgres-url or set DATABASE_URL.")


def ensure_sqlite_file(path: Path, overwrite: bool) -> None:
    if path.exists():
        if not overwrite:
            raise SystemExit(
                f"SQLite file {path} already exists. Use --overwrite to replace it."
            )
        path.unlink()
    path.parent.mkdir(parents=True, exist_ok=True)


def disable_sqlite_fk(conn: Connection, enabled: bool) -> None:
    if conn.dialect.name == "sqlite":
        conn.execute(text(f"PRAGMA foreign_keys={'ON' if enabled else 'OFF'}"))


def insert_in_batches(
    dest_conn: Connection, table, rows: Iterable[dict], batch_size: int
) -> int:
    to_insert: List[dict] = []
    inserted = 0
    for row in rows:
        to_insert.append(row)
        if len(to_insert) >= batch_size:
            dest_conn.execute(table.insert(), to_insert)
            inserted += len(to_insert)
            to_insert.clear()
    if to_insert:
        dest_conn.execute(table.insert(), to_insert)
        inserted += len(to_insert)
    return inserted


def export_database(postgres_url: str, sqlite_path: Path, batch_size: int) -> None:
    pg_engine = create_engine(postgres_url)
    sqlite_engine = create_engine(f"sqlite:///{sqlite_path}")

    Base.metadata.drop_all(bind=sqlite_engine)
    Base.metadata.create_all(bind=sqlite_engine)

    with pg_engine.connect() as pg_conn, sqlite_engine.connect() as sqlite_conn:
        disable_sqlite_fk(sqlite_conn, enabled=False)
        trans = sqlite_conn.begin()
        try:
            for table in Base.metadata.sorted_tables:
                result = pg_conn.execution_options(stream_results=True).execute(
                    select(table)
                )
                rows = (dict(row._mapping) for row in result)
                inserted = insert_in_batches(sqlite_conn, table, rows, batch_size)
                print(f"[EXPORT] {table.name}: {inserted} rows copied")
            trans.commit()
        except SQLAlchemyError as exc:
            trans.rollback()
            raise RuntimeError(f"Export failed: {exc}") from exc
        finally:
            disable_sqlite_fk(sqlite_conn, enabled=True)


def main() -> None:
    args = parse_args()
    postgres_url = resolve_postgres_url(args.postgres_url)
    sqlite_path = Path(args.sqlite_path).resolve()
    ensure_sqlite_file(sqlite_path, args.overwrite)

    print(f"Exporting from {postgres_url} -> {sqlite_path}")
    export_database(postgres_url, sqlite_path, args.batch_size)
    print("Export completed successfully.")


if __name__ == "__main__":
    main()
