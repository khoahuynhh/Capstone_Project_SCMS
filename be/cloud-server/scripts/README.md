# Cloud Server Utility Scripts

Utility scripts for database seeding and PostgreSQL backup.

Run scripts from the repository root or from the `be/` folder. The examples below use PowerShell paths.

## `seed_data.py`

Populate the configured PostgreSQL database with demo data:

```powershell
python be\cloud-server\scripts\seed_data.py
```

The script reads `DATABASE_URL` from the environment. When running through Docker Compose, the Cloud server uses the database URL defined in `be/.env` and `docker-compose.cloud.yml`.

Default profile is `render_free`, which seeds a smaller dataset suitable for limited database storage.

Common options:

```powershell
$env:SEED_PROFILE="render_free"
python be\cloud-server\scripts\seed_data.py
```

```powershell
$env:SEED_PROFILE="compact"
$env:SEED_TRANSACTION_COUNT="150"
python be\cloud-server\scripts\seed_data.py
```

Useful environment variables:

- `SEED_PROFILE`: `render_free`, `compact`, or `full`
- `SEED_PRODUCT_LIMIT`
- `SEED_CUSTOMER_COUNT`
- `SEED_TRANSACTION_COUNT`
- `SEED_INCLUDE_PRIVACY_LOGS`
- `SEED_INCLUDE_MODELING_TABLES`
- `SEED_INCLUDE_PROMOTIONS`
- `RESET_DB`: `true` or `false`

## `export_postgres.py`

Create a PostgreSQL backup from the running `postgres-db` Docker container using `pg_dump`.

Default command:

```powershell
python be\cloud-server\scripts\export_postgres.py
```

Default behavior:

- Container: `postgres-db`
- Database: `retail_db`
- User: `admin`
- Output folder: `be/cloud-server/data/backups/`
- Format: plain SQL

Specific output file:

```powershell
python be\cloud-server\scripts\export_postgres.py --output be\cloud-server\data\backups\retail_db_backup.sql --overwrite
```

Custom PostgreSQL dump format:

```powershell
python be\cloud-server\scripts\export_postgres.py --format custom --output be\cloud-server\data\backups\retail_db_backup.dump --overwrite
```

Available flags:

- `--container`: PostgreSQL container name. Default: `postgres-db`.
- `--database`: database name. Default: `retail_db`.
- `--user`: PostgreSQL user inside the container. Default: `admin`.
- `--output`: backup file path.
- `--format`: `plain` or `custom`.
- `--clean`: include drop statements before create statements.
- `--if-exists`: use `IF EXISTS` with `--clean`.
- `--with-owner`: keep ownership statements.
- `--with-privileges`: keep grant/revoke statements.
- `--overwrite`: replace the output file if it already exists.

Restore a plain SQL backup:

```powershell
Get-Content .\be\cloud-server\data\backups\retail_db_backup.sql | docker exec -i postgres-db psql -U admin -d retail_db
```

Restore a custom-format backup:

```powershell
Get-Content .\be\cloud-server\data\backups\retail_db_backup.dump -Raw | docker exec -i postgres-db pg_restore -U admin -d retail_db --clean --if-exists
```

Do not use `docker compose down -v` before creating a backup unless you intentionally want to delete the PostgreSQL Docker volume.
