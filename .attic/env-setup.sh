#!/usr/bin/env bash

# Sourcing the output of this script setups up the needed environment for this project.
# You should source the standard output, not the script itself:
#   source <$(this script's path)
# 
# 

#set -x
set -e
set -u
set -o pipefail
set -o noclobber
shopt -s  nullglob

# locate this script
# stack overflow #59895
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"


# The directory of the mends git worktree
MENDS_ROOT=${DIR}

# See that file for comments
# Source the branch specific env file, to set branch specific variables
# so that this script operates in a branch specific way. The ides is that
# we'll have "dev" and "prod" environments that are indicated by the values
# set in the "env" file in the "dev" and "proc" branches. Other feature/bug
# branches will be based on one of these two branches, and therefore will
# but considered to be in the "dev" or "prod" environment.
# TODO:Shahim, check of comments in env and consistent with above
if [ -f "${MENDS_ROOT}/env" ]; then
    source ${MENDS_ROOT}/env
fi


if [ -z "${MENDS_ENV-}" ]; then
    echo \$MENDS_ENV is not set in ./env or ./env is missing
    exit 1
fi


# Stash the branch env before sourcing possible local overrides
# in case the local file overrides MENDS_ENV, which is should not.
# MENDS_ENV should only come from the env file that is committed in git.
_MENDS_ENV=${MENDS_ENV}

# This allows or local (after a local checkout/setup to overide if needed)
# Not implemented or tested yet
# TODO:Shahim, finish or remove
# See that file for comments
if [ -f "${MENDS_ROOT}/env-local" ]; then
    source ${MENDS_ROOT}/env-local
    # A local override file has to set MENDS_ENV_LOCAL to make sure later branch switching doesn't devate from this
    if [ -z "${MENDS_ENV_LOCAL-}" ]; then
        echo \$MENDS_ENV_LOCAL is not set in ./env-local
        exit 1
    fi

    # Make sure we didn't accidentally end up with  a mix of envs due to inappropriate branch swiching
    # i.e. a checked out project should remain in the same environment if there is also a local override file
    # This is detected/enforced by detecting inconsistent valeus in _MENDS_ENV vs MENDS_ENV_LOCAL
    if [ "$_MENDS_ENV" != "${MENDS_ENV_LOCAL}" ]; then
        echo \$MENDS_ENV in ./env is $_MENDS_ENV but in ./env-local it is set to $MENDS_ENV_LOCAL
        exit 1
    fi
fi
unset _MENDS_ENV
unset MENDS_ENV_LOCAL


# import from parent or setup
# https://stackoverflow.com/questions/28039372/bash-set-u-allow-single-unbound-variable
# The idea here is to capture the original PATH before overriding it below, and to avoid repeat
# prefixing of PATH in case this is called multiple times.
# Also, having this var set (and has a value) means the environment is alreay activated and no need to do it again when needed
# PATH is only captured if MENDS_ORIGINAL_PATH is unset or empty, i.e. this is the first time this runs.
if [ -z "${MENDS_PATH_ORIGINAL-}" ]; then
    MENDS_PATH_ORIGINAL=${PATH}

    # Prefix PATH with the "mends user" bin directory. User directory name should match id
    # Then the common mends bind directory
    PATH=${MENDS_ROOT}/user/${USER}/bin:${MENDS_ROOT}/bin:${MENDS_PATH_ORIGINAL}
fi


# This is the copied Go cache for build purposes
GOPATH=${MENDS_ROOT}/resources/gocache

TMPDIR=$(realpath ${MENDS_ROOT}/../tmp)

# whistle related
# if no var set, we set to default
WHISTLE_ROOT=${WHISTLE_ROOT:-"${MENDS_ROOT}/../whistle.git"}
WHISTLE_ROOT=$(realpath "${WHISTLE_ROOT}")
# we need to make sure we have the whistle repo available.
if [ ! -d "${WHISTLE_ROOT}/.git" ]; then
    # TODO: check if we can do a shallow clone instead to at least speed up clean builds.
    git clone -b ${WHISTLE_ENV} --depth 1 -- "${WHISTLE_REPO}" "${WHISTLE_ROOT}"
fi

OOF=$(realpath "${MENDS_ROOT}/../omop-on-fhir.git")
if [ ! -d ${OOF} ]; then
    git clone https://source.developers.google.com/p/hdcekamends1/r/github_shahimessaid_omoponfhir-omopv5-r4-mapping "${OOF}"
fi

O2F=$(realpath "${MENDS_ROOT}/../O2F.git")
if [ ! -d ${O2F} ]; then
    git clone https://source.developers.google.com/p/hdcekamends1/r/github_shahimessaid_o2f "${O2F}"
fi

# input related vars
MENDS_INPUT_ROOT=${MENDS_INPUT_ROOT:-"${MENDS_ROOT}/../input"}
MENDS_INPUT_ROOT=$(realpath "${MENDS_INPUT_ROOT}")

# output related vars
MENDS_OUTPUT_ROOT=${MENDS_OUTPUT_ROOT:-"${MENDS_ROOT}/../output"}
MENDS_OUTPUT_ROOT=$(realpath "${MENDS_OUTPUT_ROOT}")


mkdir -p "$TMPDIR"
mkdir -p "${MENDS_INPUT_ROOT}"
mkdir -p "${MENDS_OUTPUT_ROOT}"

cd "${MENDS_INPUT_ROOT}"
# This links any input folders from our shared home directory
# This is currently: MENDS_ENVS_SHARED=/home/share1/mends-envs from the "env" file

# first make sure we're not already in the shared environment
# TODO:Shahim, this is a little too hard coded, based on the repo folder name.
if [ "${DIR}" != "${MENDS_ENVS_SHARED}/${MENDS_ENV}/mends/bin" ]; then
    #if [ -d "${MENDS_ENVS_SHARED}/${MENDS_ENV}/input"  ]; then
        for dir in "${MENDS_ENVS_SHARED}/${MENDS_ENV}/input"/*
        do
            SOURCE_DIR=$(basename "$dir")
            if [ ! -d  "${MENDS_INPUT_ROOT}/${SOURCE_DIR}" ]; then
                #dir=$(realpath --relative-to="${MENDS_INPUT_ROOT}" "$dir")
                ln -s "$dir"
            fi
        done
    #fi
fi


# do some git config and checking to make sure we're using the tools with
# the right env and branch

git --git-dir="${MENDS_ROOT}/.git" --work-tree="${MENDS_ROOT}" config merge.ours.driver true

# This brach has to be a descendant of the main environment branch.
# This is a santiy check to make sure the active environment (from env-setup.sh) matches the 
# environment based on git branch ancestry.
# TODO:Shahim reenable this after dealing with dev having moved on, and the message being swallowed in sourcing scripts.
#if ! git --git-dir="${MENDS_ROOT}/.git"  --work-tree="${MENDS_ROOT}" merge-base --is-ancestor "origin/${MENDS_ENV}" HEAD
#then
#   echo The current mends HEAD commit is not a descendant of the ${MENDS_ENV} branch
#   exit 1
#fi

# Similar check for the whistle branch
# TODO:Shahim same
#if  [ -d "${WHISTLE_ROOT}/.git" ]; then
#   if ! git --git-dir="${WHISTLE_ROOT}/.git"  --work-tree="${WHISTLE_ROOT}" merge-base --is-ancestor origin/${WHISTLE_ENV} HEAD
#   then
#       echo The current whistle HEAD commit is not a descendant of the ${WHISTLE_ENV} branch
#       exit 1
#   fi
#fi

## echo to export the vars we want to make visible
echo "export MENDS_PATH_ORIGINAL=${MENDS_PATH_ORIGINAL}"
echo "export MENDS_ROOT=${MENDS_ROOT}"
echo "export PATH=${PATH}"
echo "export GOPATH=${GOPATH}"
echo "export TMPDIR=${TMPDIR}"
echo "export MENDS_INPUT_ROOT=${MENDS_INPUT_ROOT}"
echo "export MENDS_OUTPUT_ROOT=${MENDS_OUTPUT_ROOT}"
echo "export MENDS_ENV=${MENDS_ENV}"
echo "export MENDS_ENVS_SHARED=${MENDS_ENVS_SHARED}"

echo "export WHISTLE_ROOT=${WHISTLE_ROOT}"
echo "export WHISTLE_REPO=${WHISTLE_REPO}"
echo "export WHISTLE_ENV=${WHISTLE_ENV}"

echo "export PS1=\"[\u@\h MENDS-${MENDS_ENV} \W]\\$ \""

# If this output is not seen, it means this script exited prematurelly.
# It's just a visual hint, on standard error, not standard out, so it will not be sourced.
>&2 echo "============= MENDS project environment successfully set ====================="