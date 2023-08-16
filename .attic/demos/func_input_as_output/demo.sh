#!/usr/bin/env bash
#set -x
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

# if environment hasn't been activated, activate dev by default for this script
if [ -z "${MENDS_PATH_ORIGINAL-}" ]; then
    echo Activating environment for this script
    source <(${DIR}/../../env-setup.sh)
fi


whistle-main \
  -input_file_spec="${DIR}/input.json" \
  -mapping_file_spec="${DIR}/Main.wstl" \
  -lib_dir_spec="${DIR}/library" \
  -harmonize_code_dir_spec="${DIR}/mappings" \
  -output_dir="${DIR}"
