-- Create the Datadog user with a specified password
CREATE USER datadog WITH PASSWORD 'datadog';

-- Enable the pg_stat_statements extension globally
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Grant the Datadog user read-only access to necessary system views
GRANT USAGE ON SCHEMA pg_catalog TO datadog;
GRANT SELECT ON pg_stat_activity TO datadog;
GRANT SELECT ON pg_stat_statements TO datadog;

-- Additional permissions for Datadog to access database-wide stats
GRANT SELECT ON pg_stat_database TO datadog;

-- Optional: Create a schema for Datadog (if you plan to use custom metrics or need additional isolation)
CREATE SCHEMA IF NOT EXISTS datadog;
GRANT USAGE ON SCHEMA datadog TO datadog;

-- Create or replace functions to expose pg_stat_activity and pg_stat_statements
-- Note: These are basic versions and might need adjustments based on your security requirements

-- Function to expose pg_stat_activity
CREATE OR REPLACE FUNCTION datadog.pg_stat_activity() RETURNS SETOF pg_stat_activity AS
$$
SELECT * FROM pg_catalog.pg_stat_activity;
$$
LANGUAGE sql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION datadog.pg_stat_activity() TO datadog;

-- Function to expose pg_stat_statements
CREATE OR REPLACE FUNCTION datadog.pg_stat_statements() RETURNS SETOF pg_stat_statements AS
$$
SELECT * FROM public.pg_stat_statements;
$$
LANGUAGE sql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION datadog.pg_stat_statements() TO datadog;

-- Ensure the Datadog user cannot access sensitive data
REVOKE ALL ON SCHEMA public FROM datadog;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM datadog;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM datadog;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM datadog;

-- Apply the changes
COMMIT;
