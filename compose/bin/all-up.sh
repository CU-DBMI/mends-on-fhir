#!/usr/bin/env bash
# stack overflow #59895
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
. "${DIR}"/.init
cd "$DIR"/..

bin/synthea-1-example-data-update.sh

docker compose \
  -f convert.yaml \
  -f validate-all.yaml \
  -f load-all.yaml \
  -f hapi.yaml \
  up
