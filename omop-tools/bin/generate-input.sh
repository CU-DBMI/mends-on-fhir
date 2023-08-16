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
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Setting up and activating Python virtual environment for the Python tooling
if [ -d "${DIR}/../.venv" ]; then
    source "${DIR}/../.venv/bin/activate"
else
    python3 -m venv "${DIR}/../.venv"
    source "${DIR}/../.venv/bin/activate"
    pip3 install --upgrade pip
    pip3 install -r "${DIR}/../requirements.txt"
fi



OMOP_INPUT_SOURCE=mends
OMOP_INPUT_FORMAT=python-name-array
OMOP_INPUT_SIZE=small
OMOP_INPUT_CHUNK_SIZE=100
OMOP_INPUT_ROWS=500
OMOP_INPUT_SQL_FILE=
OMOP_INPUT_DB=bigquery
OMOP_INPUT_DB_ARGS=hdcdmmends/mends


#MENDS_TEST_MOD=false

# example command: bin/mends-input --source mends --format python-name-array --size small \
#   --chunk-size 100 --rows 500 --sql-file MENDS_queries_condition_occurrence.sql --db bigquery \
#   --dbargs "hdcdmmends/mends" --dir ../input/some-source/some-format/some-size

while :;
do
    #if $1 is unset or at the end of the args
    [ -z "${1:-}" ] &&  break

    GIVEN_OPTIONS=yes

    case $1 in

        --help) 
            usage
            exit
        ;;

        --source)
            if [ -n "$2" ]
            then
                OMOP_INPUT_SOURCE=$2
                shift
            else
                printf 'ERROR: "--source" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --format)
            if [ -n "$2" ]
            then
                OMOP_INPUT_FORMAT=$2
                shift
            else
                printf 'ERROR: "--format" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --size)
            if [ -n "$2" ]
            then
                OMOP_INPUT_SIZE=$2
                shift
            else
                printf 'ERROR: "--size" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --chunk-size)
            if [ -n "$2" ]
            then
                OMOP_INPUT_CHUNK_SIZE=$2
                shift
            else
                printf 'ERROR: "--chunk-size" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --rows)
            if [ -n "$2" ]
            then
                OMOP_INPUT_ROWS=$2
                shift
            else
                printf 'ERROR: "--rows" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --sql-file)
            if [ -n "$2" ]
            then
                OMOP_INPUT_SQL_FILE=$2
                shift
            else
                printf 'ERROR: "--sql-file" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --db)
            if [ -n "$2" ]
            then
                OMOP_INPUT_DB=$2
                shift
            else
                printf 'ERROR: "--db" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --dbargs)
            if [ -n "$2" ]
            then
                OMOP_INPUT_DB_ARGS=$2
                shift
            else
                printf 'ERROR: "--dbargs" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

        --dir)
            if [ -n "$2" ]
            then
                OMOP_INPUT_DIR=$2
                shift
            else
                printf 'ERROR: "--dir" requires a non-empty argument.\n' >&2
                exit 1
            fi
        ;;

# TODO:Shahim to add a clean option.
        *)
            echo "In default options case with $1";
            exit 1
        ;;
    esac
    shift 
done

if [ -z "${OMOP_INPUT_DIR:-}" ]; then
    OMOP_INPUT_DIR="${DIR}/../input/${OMOP_INPUT_SOURCE}/${OMOP_INPUT_FORMAT}/${OMOP_INPUT_SIZE}"
fi


if [ -z "${OMOP_INPUT_SQL_FILE:-}" ]
then
    echo SQL file not provided, exiting
    exit 1
fi

if [ ! -f "${OMOP_INPUT_SQL_FILE}"  ];
then
    echo SQL file does not exist: ${OMOP_INPUT_SQL_FILE}
    exit 1
fi

mkdir -p "${OMOP_INPUT_DIR}"

OMOP_INPUT_SQL_FILE="$(realpath ${OMOP_INPUT_SQL_FILE})"
OMOP_INPUT_DIR="$(realpath ${OMOP_INPUT_DIR})"

set -x
python ${DIR}/../generate-input.py \
    --chunksize $OMOP_INPUT_CHUNK_SIZE \
    --rows $OMOP_INPUT_ROWS \
    --sqlfile="$OMOP_INPUT_SQL_FILE" \
    --database "$OMOP_INPUT_DB" \
    --dbargs "$OMOP_INPUT_DB_ARGS" \
    --localdir "$OMOP_INPUT_DIR"

