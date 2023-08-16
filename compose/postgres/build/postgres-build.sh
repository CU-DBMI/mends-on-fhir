#!/usr/bin/env bash
set -x
set -e
set -u
set -o pipefail
set -o noclobber
shopt -s  nullglob

# stack overflow #59895
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
. "${DIR}"/../../bin/.init
cd "$DIR"/../..

# docker build --tag mgkahn/compose-postgres postgres/build

docker compose --progress plain \
    -f postgres.yaml \
    build

docker compose -f postgres.yaml push
