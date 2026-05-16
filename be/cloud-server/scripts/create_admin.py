import argparse
import getpass
import os
import sys
from pathlib import Path

from passlib.context import CryptContext
from dotenv import load_dotenv
from sqlalchemy.engine import make_url


SCRIPT_DIR = Path(__file__).resolve().parent
CLOUD_SERVER_DIR = SCRIPT_DIR.parent
BACKEND_DIR = CLOUD_SERVER_DIR.parent
sys.path.insert(0, str(CLOUD_SERVER_DIR))


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def load_env_files() -> None:
    load_dotenv(BACKEND_DIR / ".env")
    load_dotenv(Path.cwd() / ".env", override=False)


def configure_database_url_for_local_run() -> None:
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        return

    if Path("/.dockerenv").exists():
        return

    url = make_url(database_url)
    if url.host != "postgres":
        return

    host_port = int(os.getenv("POSTGRES_HOST_PORT", "5433"))
    local_url = url.set(host="localhost", port=host_port)
    os.environ["DATABASE_URL"] = local_url.render_as_string(hide_password=False)
    print(
        "Using local PostgreSQL URL because script is running outside Docker: "
        f"{local_url.render_as_string(hide_password=True)}"
    )


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def normalize_email(email: str) -> str:
    return email.strip().lower()


def parse_args():
    load_env_files()
    parser = argparse.ArgumentParser(
        description="Create or promote a system admin account."
    )
    parser.add_argument(
        "--email",
        default=os.getenv("ADMIN_EMAIL"),
        help="Admin email. Can also be set with ADMIN_EMAIL.",
    )
    parser.add_argument(
        "--password",
        default=os.getenv("ADMIN_PASSWORD"),
        help="Admin password. Can also be set with ADMIN_PASSWORD.",
    )
    parser.add_argument(
        "--reset-password",
        action="store_true",
        help="Reset password when the account already exists.",
    )
    return parser.parse_args()


def read_password(args) -> str:
    if args.password:
        return args.password

    password = getpass.getpass("Admin password: ")
    confirm = getpass.getpass("Confirm admin password: ")
    if password != confirm:
        raise ValueError("Password confirmation does not match")
    return password


def validate_password(password: str) -> None:
    if len(password) < 8:
        raise ValueError("Admin password must be at least 8 characters")


def upsert_admin(email: str, password: str, reset_password: bool) -> str:
    configure_database_url_for_local_run()
    from database.db import SessionLocal, init_db
    from database.models import UserAccount

    init_db()
    db = SessionLocal()
    try:
        account = db.query(UserAccount).filter(UserAccount.email == email).first()
        if account is None:
            account = UserAccount(
                email=email,
                password_hash=hash_password(password),
                is_admin=True,
                customer_pk=None,
            )
            db.add(account)
            db.commit()
            return "created"

        account.is_admin = True
        account.customer_pk = None
        if reset_password:
            account.password_hash = hash_password(password)
        db.commit()
        return "updated"
    finally:
        db.close()


def main():
    args = parse_args()
    if not args.email:
        raise SystemExit("Missing admin email. Use --email or ADMIN_EMAIL.")

    email = normalize_email(args.email)
    password = read_password(args)
    validate_password(password)

    action = upsert_admin(email, password, args.reset_password)
    print(f"Admin account {action}: {email}")


if __name__ == "__main__":
    main()
