#!/bin/bash
WATCH_DIR="/opt/elmo/incoming"

inotifywait -m -e close_write,moved_to --format '%w%f' "$WATCH_DIR" |
while read FILE
do
/opt/elmo/transfer_file.sh "$FILE"
done
