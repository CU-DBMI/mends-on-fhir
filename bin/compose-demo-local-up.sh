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
    [[$SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

cd "$DIR"/..

export UID_GID="$(id -u):$(id -g)"
docker compose \
  -f compose-demo.yaml \
  --env-file .env-local \
  up \
  --force-recreate