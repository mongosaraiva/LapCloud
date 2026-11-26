#!/usr/bin/env bash
# Creates the "peertube" user and database in the shared Postgres.
# Run once, after core/postgres is healthy and media/peertube/.env exists.
set -euo pipefail

cd "$(dirname "$0")"

# Read values from the .env files without printing them
PT_PASS=$(grep '^PEERTUBE_DB_PASSWORD=' .env | cut -d= -f2-)
PG_USER=$(grep '^POSTGRES_USER=' ../../core/postgres/.env | cut -d= -f2-)
PG_DB=$(grep '^POSTGRES_DB=' ../../core/postgres/.env | cut -d= -f2-)

docker exec -i lapcloud-postgres psql -U "$PG_USER" -d "$PG_DB" \
  -v ON_ERROR_STOP=1 -v pw="$PT_PASS" <<'SQL'
CREATE USER peertube WITH PASSWORD :'pw';
CREATE DATABASE peertube OWNER peertube ENCODING 'UTF8' TEMPLATE template0;
SQL

# PeerTube needs these two extensions
docker exec -i lapcloud-postgres psql -U "$PG_USER" -d peertube -v ON_ERROR_STOP=1 <<'SQL'
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
SQL

echo "Database 'peertube' created."
