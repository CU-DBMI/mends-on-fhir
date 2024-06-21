#!/usr/bin/env bash
# stack overflow #59895
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
cd "$DIR"/..

for f in ../input-examples/omop-fhir-data/synthea-cohort-010/*; do
  f=$(realpath $f)
  if [[ -d $f ]]; then continue; fi
  distribution/bin/distribution \
    -i $f \
    -m ../whistle-mappings/synthea-w2/w2-main.wstl \
    -o output
  break
done




