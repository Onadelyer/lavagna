-- Connect to your database using a superuser before running this script

-- Create the datadog user with a password
CREATE USER datadog WITH PASSWORD 'datadog';

-- Create the datadog schema in every database
CREATE SCHEMA IF NOT EXISTS datadog;
GRANT USAGE ON SCHEMA datadog TO datadog;
GRANT USAGE ON SCHEMA public TO datadog;

-- Grant SELECT on pg_stat_database to datadog
GRANT SELECT ON pg_stat_database TO datadog;

-- Install the pg_stat_statements extension if it doesn't exist
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Create functions in every database for the datadog agent
-- Function to access pg_stat_activity
CREATE OR REPLACE FUNCTION datadog.pg_stat_activity() RETURNS SETOF pg_stat_activity AS
$$
SELECT * FROM pg_catalog.pg_stat_activity;
$$
LANGUAGE sql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION datadog.pg_stat_activity() TO datadog;

-- Function to access pg_stat_statements
CREATE OR REPLACE FUNCTION datadog.pg_stat_statements() RETURNS SETOF pg_stat_statements AS
$$
SELECT * FROM pg_stat_statements;
$$
LANGUAGE sql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION datadog.pg_stat_statements() TO datadog;

-- Function to execute explain plans
CREATE OR REPLACE FUNCTION datadog.explain_statement(l_query TEXT, OUT explain JSON) RETURNS SETOF JSON AS
$$
DECLARE
    curs REFCURSOR;
    plan JSON;
BEGIN
    OPEN curs FOR EXECUTE pg_catalog.concat('EXPLAIN (FORMAT JSON) ', l_query);
    FETCH curs INTO plan;
    CLOSE curs;
    RETURN QUERY SELECT plan;
END;
$$
LANGUAGE 'plpgsql' VOLATILE RETURNS NULL ON NULL INPUT SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION datadog.explain_statement(TEXT) TO datadog;

-- Replace <TABLE_NAME> with actual table names and repeat the GRANT SELECT as necessary
-- Example: GRANT SELECT ON <TABLE_NAME> TO datadog;
