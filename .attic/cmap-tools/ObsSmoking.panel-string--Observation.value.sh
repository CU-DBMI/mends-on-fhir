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

# Adjust this to the file name
ID=ObsSmoking.panel-string--Observation.value

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
  --cm_group_target "http://snomed.info/sct" \
  --cm_group_target_version "01-Mar 2021" \

  #  --cm_group_source "https://www.healthdatacompass.org/fhir/mends/CodeSystem/source" \