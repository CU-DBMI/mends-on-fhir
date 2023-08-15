#!/usr/bin/env bash
#set -x
set -e
set -u
set -o pipefail
set -o noclobber
#shopt -s  nullglob

# NOTE : Quote it else use array to avoid problems #
FILES="./*.sql"
for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  sed -i 's/as\ string/as\ text/gI' "$f"
  sed -i 's/ifnull/coalesce/gI' "$f"
  sed -i 's/current_date()/current_date/gI' "$f"
#  sed -i 's/"0"/\'0\\'/gI' "$f"
done
