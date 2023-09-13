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

# Make all assignments in .env into environment vars
set -o allexport ; source .env ; set +o allexport

cd "${HOST_MENDS_HOME}"

docker run -it --rm \
    -p 8888:8888 \
    --user root \
    -e NB_USER=mends \
    -e NB_UID="$(id -u)" \
    -e NB_GID="$(id -g)"  \
    -e CHOWN_HOME=yes \
    -e CHOWN_HOME_OPTS="-R" \
    -e GRANT_SUDO=yes \
    -w "/home/mends" \
    -v "${PWD}":/home/mends/mends-on-fhir \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --privileged \
    jupyter/minimal-notebook start-notebook.sh --IdentityProvider.token=''

