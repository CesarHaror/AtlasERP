# DB backup & staging restore scripts

Location: `backend/scripts/`

Files:
- `backup_and_restore_staging.sh` — Creates a custom-format pg dump from the source DB and restores it into the target staging DB. Requires the environment variables `SRC_DATABASE_URL` and `STAGING_DATABASE_URL` (complete connection URIs).
- `staging_validation.sql` — A set of quick validation queries to run against staging after restore.

Quick usage example:

```bash
SRC_DATABASE_URL=postgres://user:pass@src-host:5432/sourcedb \
STAGING_DATABASE_URL=postgres://user:pass@staging-host:5432/stagingdb \
bash backend/scripts/backup_and_restore_staging.sh

# Then validate
psql "$STAGING_DATABASE_URL" -f backend/scripts/staging_validation.sql
```

Notes and safety:
- Prefer using a `.pgpass` file or environment variables for credentials to avoid leaking passwords.
- Verify you have sufficient permissions on the staging server to restore (create/drop objects).
- If you must preserve the existing staging DB, create a new staging DB name and restore there.
