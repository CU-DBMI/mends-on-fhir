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


docker compose \
  -f convert.yaml \
  -f validate.yaml \
  -f load.yaml \
  -f hapi.yaml \
  -f all.yaml \
  down --remove-orphans

bin/convert-reset.sh
bin/validate-reset.sh
bin/load-reset.sh
