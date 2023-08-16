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

"${DIR}/generate-input.sh" \
    --size "$SMALL_DIR" \
    --chunk-size "$CHUNK_SIZE" \
    --rows "$ROWS" \
    --sql-file "${MENDS_ROOT}/omop-config/sql/test/MENDS_queries_labs_only.sql" \
    
    # The following are not specified since they are defaulted as shown
    #--source mends \
    #--format python-name-array \
    #--db bigquery \
    #--dbargs "hdcdmmends/mends" \
    #--dir "${MENDS_ROOT}/../input/mends/python-name-array/$SMALL_DIR"


