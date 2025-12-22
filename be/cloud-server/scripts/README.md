## Cloud-Server Utility Scripts

### `seed_data.py`
Populate the connected database (PostgreSQL by default) with a tiny demo dataset:

```bash
python be/cloud-server/scripts/seed_data.py
```

### `export_postgres_to_sqlite.py`
Dump your live PostgreSQL database into an on-disk SQLite file so you can ship it with the submission:

```bash
python be/cloud-server/scripts/export_postgres_to_sqlite.py \
  --postgres-url postgresql://admin:admin123@localhost:5432/retail_db \
  --sqlite-path demo_data/demo.sqlite \
  --overwrite
```

Flags:

- `--postgres-url` (optional): defaults to `settings.DATABASE_URL` / `DATABASE_URL`.
- `--sqlite-path`: where the SQLite file should be written (directories are created automatically).
- `--batch-size`: tune insert batch size when copying rows (default `500`).
- `--overwrite`: remove the SQLite file if it already exists.

After running the export, point your FastAPI app (or any viewer) to `sqlite:///absolute/path/to/demo.sqlite` and the same ORM models will work without a running PostgreSQL instance.
