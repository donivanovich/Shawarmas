#!/bin/bash
set -euo pipefail

if [[ -z "${API_DB_USER:-}" || -z "${API_DB_PASSWORD:-}" ]]; then
  echo "API_DB_USER and API_DB_PASSWORD must be configured to provision the restricted API account." >&2
  exit 1
fi

escaped_user=${API_DB_USER//\'/\'\'}
escaped_password=${API_DB_PASSWORD//\'/\'\'}
escaped_database=${MYSQL_DATABASE//\'/\'\'}
mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE USER IF NOT EXISTS '${escaped_user}'@'%' IDENTIFIED BY '${escaped_password}';
ALTER USER '${escaped_user}'@'%' IDENTIFIED BY '${escaped_password}';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${escaped_database}\`.* TO '${escaped_user}'@'%';
SQL
