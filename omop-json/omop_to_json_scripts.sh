# Bigquery test
./omop_to_json.py --nrows 3 --chunksize 1 --db_type bigquery --sqlfile ./test.sql --stdout --localdir ./output

# Postgres test
./omop_to_json.py --nrows 3 --chunksize 1 --db_type postgresql --sqlfile ./test.sql --stdout --localdir ./output

# MS SQL in Docker test
./omop_to_json.py --nrows 3 --chunksize 1 --db_type sqlserver --sqlfile ./test.sql --stdout --localdir ./output

