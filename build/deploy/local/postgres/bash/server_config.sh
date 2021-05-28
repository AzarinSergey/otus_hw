psql -U admin -d postgres -c "create user ${POSTGRES_USER_NAME} with createdb createrole PASSWORD '${POSTGRES_USER_PASSWORD}'"
psql -U admin -d postgres -c "create database ${POSTGRES_USER_DB} owner=${POSTGRES_USER_NAME}"
#
#execute sql
#
for file in /tmp/sql/*.sql; do 
	psql -U admin -d postgres -a -f "${file}" 
done
#
#madlib integration
#
#psql -U admin -d postgres -c "create extension plpythonu"