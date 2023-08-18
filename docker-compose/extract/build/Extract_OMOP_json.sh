#!/usr/bin/env bash
#set -x
set -e
set -u
set -o pipefail
set -o noclobber
#shopt -s  nullglob

cd /workdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_condition_occurrence.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_drug_exposure_drug_strength.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_measurement.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_observation_notsmoking.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_payer_plan_period.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_person_location.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
# ./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_smoking.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
./generate-input.py --sqlfile ${SQL_DIR}/MENDS_queries_visit_occurrence.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} --rmdir
