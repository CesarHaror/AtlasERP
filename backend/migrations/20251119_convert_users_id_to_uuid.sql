-- Migration: Convert users.id (integer serial) to UUID
-- WARNING: This migration is non-trivial and destructive if applied without testing and backups.
-- Run in staging first and have a full backup before applying to production.
-- This script assumes a simple schema; adjust table names and constraints for your DB.

-- 1) Enable pgcrypto (provides gen_random_uuid)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

BEGIN;

-- 2) Add new uuid column with default generator
ALTER TABLE public.users ADD COLUMN id_new uuid DEFAULT gen_random_uuid();

-- 3) Populate `id_new` for existing rows (for safety) - default applies to new rows only
UPDATE public.users SET id_new = gen_random_uuid() WHERE id_new IS NULL;

-- 4) For every table that references users(id) (example: user_roles), add a new UUID FK column
-- Replace `user_roles` below with each referencing table in your DB.

ALTER TABLE public.user_roles ADD COLUMN user_id_new uuid;

-- 5) Copy over FK values by joining on the old integer id
UPDATE public.user_roles ur
SET user_id_new = u.id_new
FROM public.users u
WHERE ur.user_id = u.id;

-- 6) Validate the copy (manual check recommended)
-- SELECT COUNT(*) FROM public.user_roles WHERE user_id_new IS NULL; -- should be 0

-- 7) Drop constraints that reference the old integer PK (you must find their names)
-- Example: DROP CONSTRAINT if exists user_roles_user_id_fkey;
-- You can discover FK names with:
-- SELECT conname FROM pg_constraint WHERE conrelid = 'user_roles'::regclass AND contype = 'f';

-- 8) Replace old FK column with the new one (after dropping constraints)
-- Example sequence for user_roles:
ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE public.user_roles DROP COLUMN user_id;
ALTER TABLE public.user_roles RENAME COLUMN user_id_new TO user_id;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_new);

-- 9) After updating all referencing tables, swap the PK on users
-- Drop primary key constraint on old integer column (name usually users_pkey)
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_pkey;

-- Remove old integer id column
ALTER TABLE public.users DROP COLUMN IF EXISTS id;

-- Rename id_new -> id and set as primary key
ALTER TABLE public.users RENAME COLUMN id_new TO id;
ALTER TABLE public.users ALTER COLUMN id SET NOT NULL;
ALTER TABLE public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);

-- 10) Finally, make sure all new FKs reference public.users(id)
-- Example (update the constraint added before):
ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

COMMIT;

-- NOTES & SAFETY CHECKS:
-- - This script contains examples; you MUST locate and update every table that references users.id.
-- - If your DB uses cascading FK constraints, you must preserve them when recreating constraints.
-- - If your app uses sequences or depends on integer IDs elsewhere (external integrations), coordinate the change.
-- - Consider creating new columns and updating application code to accept both `id` and `id_new` during a migration window, then perform a cutover.

-- Rollback (manual): If something goes wrong, restore from backup. Automated rollback of this operation is risky.
