#!/usr/bin/env bash
#set -x
set -e
set -u
set -o pipefail
set -o noclobber
#shopt -s  nullglob

#export MENDS_HOME=${HOME}/git/mends
export SQL_DIR=${MENDS_HOME}/omop-config/sql/postgresql
export DB=postgresql
export DBARGS=synthea/synthea10
export LOCALDIR=${HOME}/omop_json/synthea
export CHUNKSIZE=20
export NROWS=20

rm -fr ${LOCALDIR}/*.json


${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_condition_occurrence.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_drug_exposure_drug_strength.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_measurement.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_observation_notsmoking.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_payer_plan_period.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_person_location.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
# ${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_smoking.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
${MENDS_HOME}/bin/mends-input.py --sqlfile ${SQL_DIR}/MENDS_queries_visit_occurrence.sql --database ${DB} --dbargs ${DBARGS} --localdir ${LOCALDIR} --chunksize ${CHUNKSIZE} --rows ${NROWS} 
