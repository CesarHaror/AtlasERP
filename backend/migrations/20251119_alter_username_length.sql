-- Migration: Increase users.username length to 100
-- Run as: psql -d erp_carniceria -f 20251119_alter_username_length.sql

BEGIN;

-- Increase username column length from 50 -> 100 (idempotent in many PG versions)
ALTER TABLE IF EXISTS public.users
  ALTER COLUMN username TYPE VARCHAR(100);

COMMIT;

-- Down (revert) -- CAREFUL: truncation may occur if usernames exceed 50 chars
-- ALTER TABLE public.users ALTER COLUMN username TYPE VARCHAR(50);
