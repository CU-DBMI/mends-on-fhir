#!/usr/bin/env bash
#set -x
set -e
set -u
set -o pipefail
set -o noclobber
#shopt -s  nullglob

# stack overflow #59895
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[$SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

ID=Person.race-concept-id--Patient.x.uscore-omb

"${DIR}/csv-to-cmap-v2.py" \
  --csv "${DIR}/${ID}.csv" \
  --out "${DIR}/../whistle-config/concept-map/${ID}.json" \
  --cm_id "$ID" \
  --cm_url "https://www.healthdatacompass.org/fhir/mends/ConceptMap/${ID}" \
  --cm_version "0.0.0" \
  --cm_name "$ID" \
  --cm_title "$ID" \
  --cm_status "draft" \
  --cm_group_source "omop" \
  --cm_group_source_version "0.0.1" \
  --cm_group_target "https://www.healthdatacompass.org/fhir/mends/target" \
  --cm_group_target_version "0.0.1" \
