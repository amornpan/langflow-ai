#!/bin/bash
set -e

# Initialize Langflow database with custom configurations
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create extensions
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";
    CREATE EXTENSION IF NOT EXISTS "btree_gin";
    
    -- Create indexes for better performance
    -- These will be created by Langflow migrations, but we can prepare the database
    
    -- Grant permissions
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
    
    -- Set some performance parameters
    ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
    ALTER SYSTEM SET log_statement = 'all';
    ALTER SYSTEM SET log_min_duration_statement = 1000;
    
    -- Create a schema for Langflow if needed
    CREATE SCHEMA IF NOT EXISTS langflow;
    GRANT ALL ON SCHEMA langflow TO $POSTGRES_USER;
EOSQL

echo "Database initialization completed successfully!"
