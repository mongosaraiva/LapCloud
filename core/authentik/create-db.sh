#!/usr/bin/env bash
# Creates the "authentik" user and database in the shared Postgres.
# Run once, after core/postgres is healthy and core/authentik/.env exists.
set -euo pipefail

cd "$(dirname "$0")"

# Read the password from .env without printing it
AK_PG_PASS=$(grep '^AUTHENTIK_POSTGRESQL__PASSWORD=' .env | cut -d= -f2-)
PG_USER=$(grep '^POSTGRES_USER=' ../postgres/.env | cut -d= -f2-)
PG_DB=$(grep '^POSTGRES_DB=' ../postgres/.env | cut -d= -f2-)

docker exec -i lapcloud-postgres psql -U "$PG_USER" -d "$PG_DB" \
  -v ON_ERROR_STOP=1 -v pw="$AK_PG_PASS" <<'SQL'
CREATE USER authentik WITH PASSWORD :'pw';
CREATE DATABASE authentik OWNER authentik;
SQL

echo "Database 'authentik' created."
