-- Post-migration fix for users_roles table
-- 1. Drop old user_id column if exists (should be integer)
ALTER TABLE public.users_roles DROP COLUMN IF EXISTS user_id;
-- 2. Rename user_id_new to user_id
ALTER TABLE public.users_roles RENAME COLUMN user_id_new TO user_id;
-- 3. Recreate FK constraint
ALTER TABLE public.users_roles ADD CONSTRAINT users_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
-- 4. Create index for user_id
CREATE INDEX IF NOT EXISTS users_roles_user_id_idx ON public.users_roles(user_id);
-- 5. Show result
SELECT column_name, data_type FROM information_schema.columns WHERE table_name='users_roles';
SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'users_roles'::regclass AND contype = 'f';
SELECT * FROM public.users_roles LIMIT 10;
