-- staging_validation.sql
-- Run this against the staging DB after restore to sanity-check critical items

-- 1) Basic row counts
SELECT 'users_count' AS check, count(*) FROM users;
SELECT 'roles_count' AS check, count(*) FROM roles;

-- 2) Sample users
SELECT id, username, email, created_at FROM users ORDER BY created_at DESC LIMIT 5;

-- 3) Foreign key constraints that reference `users` (schema-aware)
SELECT
  con.conname AS constraint_name,
  con.conrelid::regclass AS table_name,
  array_agg(att.attname) AS columns
FROM pg_constraint con
LEFT JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = ANY(con.conkey)
WHERE con.contype = 'f'
  AND con.confrelid = 'public.users'::regclass
GROUP BY con.conname, con.conrelid
ORDER BY con.conname;

-- 4) Example check: ensure no NULL user_id in user_roles (adjust table names as needed)
SELECT 'user_roles_null_user_id' AS check, count(*) FROM user_roles WHERE user_id IS NULL;

-- End of checks
