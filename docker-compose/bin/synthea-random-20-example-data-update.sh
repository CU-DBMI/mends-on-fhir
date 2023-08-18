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

cd ..

pwd

set -x
mkdir -p input-examples/synthea-random-20
#git submodule init synthea-random-20
git submodule update --init input-examples/synthea-random-20
