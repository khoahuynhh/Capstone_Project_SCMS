"""
Backup the PostgreSQL database used by the cloud server.

The file name is kept for compatibility with the old workflow, but this script
now creates a real PostgreSQL dump with pg_dump instead of exporting to SQLite.

Examples:
    python be/cloud-server/scripts/export_postgres.py

    python be/cloud-server/scripts/export_postgres.py \
        --output be/data/backups/retail_db_backup.sql

    python be/cloud-server/scripts/export_postgres.py \
        --format custom --output be/backups/retail_db_backup.dump
"""

from __future__ import annotations

import argparse
import subprocess
from datetime import datetime
from pathlib import Path


DEFAULT_CONTAINER = "postgres-db"
DEFAULT_DB = "retail_db"
DEFAULT_USER = "admin"


def default_output_path(dump_format: str) -> Path:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    extension = "dump" if dump_format == "custom" else "sql"
    be_dir = Path(__file__).resolve().parents[2]
    return be_dir / "data" / "backups" / f"{DEFAULT_DB}_backup_{timestamp}.{extension}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Backup PostgreSQL from the running Docker container using pg_dump. "
            "Default target: container postgres-db, database retail_db."
        )
    )
    parser.add_argument(
        "--container",
        default=DEFAULT_CONTAINER,
        help=f"PostgreSQL container name (default: {DEFAULT_CONTAINER}).",
    )
    parser.add_argument(
        "--database",
        "-d",
        default=DEFAULT_DB,
        help=f"Database name to backup (default: {DEFAULT_DB}).",
    )
    parser.add_argument(
        "--user",
        "-U",
        default=DEFAULT_USER,
        help=f"PostgreSQL user inside the container (default: {DEFAULT_USER}).",
    )
    parser.add_argument(
        "--output",
        "-o",
        default=None,
        help=(
            "Backup file path. Defaults to "
            "be/cloud-server/data/backups/<database>_backup_<timestamp>.sql."
        ),
    )
    parser.add_argument(
        "--format",
        choices=("plain", "custom"),
        default="plain",
        help="Dump format: plain SQL or PostgreSQL custom format (default: plain).",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Include SQL commands to drop database objects before recreating them.",
    )
    parser.add_argument(
        "--if-exists",
        action="store_true",
        help="Use IF EXISTS with --clean to avoid errors while restoring.",
    )
    parser.add_argument(
        "--with-owner",
        action="store_true",
        help="Keep ownership statements in the dump. By default they are removed.",
    )
    parser.add_argument(
        "--with-privileges",
        action="store_true",
        help="Keep grant/revoke statements in the dump. By default they are removed.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Allow replacing the output file if it already exists.",
    )
    return parser.parse_args()


def build_pg_dump_command(args: argparse.Namespace) -> list[str]:
    command = [
        "docker",
        "exec",
        args.container,
        "pg_dump",
        "-U",
        args.user,
        "-d",
        args.database,
        f"--format={'c' if args.format == 'custom' else 'p'}",
    ]

    if args.clean:
        command.append("--clean")
    if args.if_exists:
        command.append("--if-exists")
    if not args.with_owner:
        command.append("--no-owner")
    if not args.with_privileges:
        command.append("--no-privileges")

    return command


def ensure_output_path(path: Path, overwrite: bool) -> None:
    if path.exists() and not overwrite:
        raise SystemExit(
            f"Backup file already exists: {path}. Use --overwrite to replace it."
        )
    path.parent.mkdir(parents=True, exist_ok=True)


def run_backup(command: list[str], output_path: Path) -> None:
    with output_path.open("wb") as output:
        result = subprocess.run(command, stdout=output, stderr=subprocess.PIPE)

    if result.returncode != 0:
        output_path.unlink(missing_ok=True)
        stderr = result.stderr.decode("utf-8", errors="replace").strip()
        raise SystemExit(
            f"pg_dump failed with exit code {result.returncode}:\n{stderr}"
        )


def main() -> None:
    args = parse_args()
    output_path = (
        Path(args.output).resolve() if args.output else default_output_path(args.format)
    )
    ensure_output_path(output_path, args.overwrite)

    command = build_pg_dump_command(args)
    print(
        f"Backing up PostgreSQL container '{args.container}' database '{args.database}'"
    )
    print(f"Output: {output_path}")
    run_backup(command, output_path)
    print("Backup completed successfully.")


if __name__ == "__main__":
    main()
