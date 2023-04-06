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

# if environment hasn't been activated, activate dev by default for this script
if [ -z "${MENDS_PATH_ORIGINAL-}" ]; then
    echo Activating environment for this script
    source <(${DIR}/../env-setup.sh)
fi

SMALL_DIR="${1:-_default}"
ROWS="${2:-500}"
CHUNK_SIZE="${3:-100}"


# Needed boilerplate code finished. The following is the only relevant part.

"${MENDS_ROOT}/omop-config/input-condition.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${MENDS_ROOT}/omop-config/input-drug.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"

"${MENDS_ROOT}/omop-config/input-measurement.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${MENDS_ROOT}/omop-config/input-observation-not-smoking.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"

"${MENDS_ROOT}/omop-config/input-payer_plan_period.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${MENDS_ROOT}/omop-config/input-person.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"

"${MENDS_ROOT}/omop-config/input-smoking.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${MENDS_ROOT}/omop-config/input-visit.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"


