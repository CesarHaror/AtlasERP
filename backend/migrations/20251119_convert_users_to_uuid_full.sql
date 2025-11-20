-- Migration: Convert users.id (integer/serial) to UUID and update referencing FKs
-- WARNING: Run in a staging environment first. Take a full backup before applying.
-- This script attempts to handle common referencing tables automatically.
-- It will:
--  1) enable pgcrypto
--  2) add id_new uuid to users and populate
--  3) add user_id_new uuid to referencing tables (detected below) and populate
--  4) drop foreign key constraints that reference users
--  5) replace old integer id columns in referencing tables with the new uuid
--  6) swap users.id -> uuid
--  7) recreate foreign keys referencing users(id)

-- IMPORTANT: This script makes assumptions about table/column names. Review and adapt before running.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

BEGIN;

-- 1) Add new uuid column to users
ALTER TABLE IF EXISTS public.users ADD COLUMN IF NOT EXISTS id_new uuid DEFAULT gen_random_uuid();

-- 2) Populate id_new for existing rows
UPDATE public.users SET id_new = gen_random_uuid() WHERE id_new IS NULL;

-- 3) Detect referencing FK constraints dynamically, add per-column *_new uuid columns and populate them
DO $$
DECLARE
  r RECORD;
  cols text[];
  col text;
BEGIN
  FOR r IN
    SELECT con.conrelid::regclass::text AS relname,
           array_agg(att.attname ORDER BY array_position(con.conkey, att.attnum)) AS columns
    FROM pg_constraint con
    JOIN unnest(con.conkey) WITH ORDINALITY AS k(attnum, ord) ON true
    JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = k.attnum
    WHERE con.contype = 'f' AND con.confrelid = 'public.users'::regclass
    GROUP BY con.conrelid::regclass::text
  LOOP
    cols := r.columns;
    FOREACH col IN ARRAY cols LOOP
      EXECUTE format('ALTER TABLE IF EXISTS %s ADD COLUMN IF NOT EXISTS %I uuid', r.relname, col || '_new');
      EXECUTE format('UPDATE %s SET %I = u.id_new FROM public.users u WHERE %s.%I::text = u.id::text', r.relname, col || '_new', r.relname, col);
    END LOOP;
  END LOOP;
END$$;

-- 4) Validate that no null user_id_new remain (manual check recommended). Example query:
-- SELECT con.conrelid::regclass::text AS table, array_agg(att.attname) AS columns FROM pg_constraint con JOIN unnest(con.conkey) WITH ORDINALITY AS k(attnum, ord) ON true JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = k.attnum WHERE con.contype = 'f' AND con.confrelid = 'public.users'::regclass GROUP BY con.conrelid::regclass::text;

-- 5) Drop foreign key constraints that reference public.users (we will recreate them later)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT conrelid::regclass::text AS relname, conname
    FROM pg_constraint
    WHERE contype = 'f' AND confrelid = 'public.users'::regclass
  LOOP
    RAISE NOTICE 'Dropping constraint % on %', r.conname, r.relname;
    EXECUTE format('ALTER TABLE %s DROP CONSTRAINT IF EXISTS %I', r.relname, r.conname);
  END LOOP;
END$$;

-- 6) Replace old FK columns in referencing tables: drop old column(s) and rename *_new -> original name
DO $$
DECLARE
  r RECORD;
  cols text[];
  col text;
BEGIN
  FOR r IN
    SELECT con.conrelid::regclass::text AS relname,
           array_agg(att.attname ORDER BY array_position(con.conkey, att.attnum)) AS columns
    FROM pg_constraint con
    JOIN unnest(con.conkey) WITH ORDINALITY AS k(attnum, ord) ON true
    JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = k.attnum
    WHERE con.contype = 'f' AND con.confrelid = 'public.users'::regclass
    GROUP BY con.conrelid::regclass::text
  LOOP
    cols := r.columns;
    FOREACH col IN ARRAY cols LOOP
      -- drop the old integer FK column if exists
      EXECUTE format('ALTER TABLE IF EXISTS %s DROP COLUMN IF EXISTS %I', r.relname, col);
      -- rename new column to the original name (use safe block to avoid syntax unsupported in some PG versions)
      BEGIN
        EXECUTE format('ALTER TABLE %s RENAME COLUMN %I TO %I', r.relname, col || '_new', col);
      EXCEPTION WHEN undefined_column THEN
        NULL;
      END;
    END LOOP;
  END LOOP;
END$$;

-- 7) Swap users primary key: remove old integer PK, drop old id column, rename id_new to id
-- Find and drop PK constraint (usually users_pkey)
ALTER TABLE IF EXISTS public.users DROP CONSTRAINT IF EXISTS users_pkey;

-- If there are columns depending on sequences or triggers, handle them before drop
ALTER TABLE IF EXISTS public.users DROP COLUMN IF EXISTS id;
DO $$ BEGIN
  BEGIN
    EXECUTE 'ALTER TABLE public.users RENAME COLUMN id_new TO id';
  EXCEPTION WHEN undefined_column THEN
    -- id_new does not exist, skip
    NULL;
  END;
END$$;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id SET NOT NULL;
ALTER TABLE IF EXISTS public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);

-- 8) Recreate foreign key constraints for all referencing tables detected earlier
DO $$
DECLARE
  r RECORD;
  cols text[];
  col text;
BEGIN
  FOR r IN
    SELECT con.conrelid::regclass::text AS relname,
           array_agg(att.attname ORDER BY array_position(con.conkey, att.attnum)) AS columns
    FROM pg_constraint con
    JOIN unnest(con.conkey) WITH ORDINALITY AS k(attnum, ord) ON true
    JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = k.attnum
    WHERE con.contype = 'f' AND con.confrelid = 'public.users'::regclass
    GROUP BY con.conrelid::regclass::text
  LOOP
    cols := r.columns;
    FOREACH col IN ARRAY cols LOOP
      EXECUTE format('ALTER TABLE IF EXISTS %s ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES public.users(id)', r.relname, r.relname || '_' || col || '_fkey', col);
    END LOOP;
  END LOOP;
END$$;

COMMIT;

-- Post-migration manual checklist:
-- - Verify data integrity: SELECT COUNT(*) FROM <referencing_table> WHERE user_id IS NULL;
-- - Verify all FK constraints were recreated correctly and index performance (create indexes if needed).
-- - Update sequences/triggers (if you removed/renamed serial columns elsewhere).
-- - Update application configs that rely on integer IDs.

-- If your database has additional tables that reference users.id with different column names, add similar
-- ALTER TABLE / UPDATE steps above for each table before dropping constraints and swapping the PK.
