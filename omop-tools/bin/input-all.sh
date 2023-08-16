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

SMALL_DIR="${1:-_default}"
ROWS="${2:-500}"
CHUNK_SIZE="${3:-100}"

"${DIR}/input-condition.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-drug.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-measurement.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-observation-not-smoking.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-payer_plan_period.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-person.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-smoking.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"
"${DIR}/input-visit.sh" "$SMALL_DIR" "$ROWS" "$CHUNK_SIZE"


