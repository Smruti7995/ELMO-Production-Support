#!/bin/bash
FAILED_DIR="/opt/elmo/failed"
LOG_FILE="/opt/elmo/logs/elmo.log"
for FILE in "$FAILED_DIR"/*
do
[ -f "$FILE" ] || continue
FILENAME=$(basename "$FILE")
sudo -n mysql -e "USE elmo; UPDATE file_transfer SET retry_count = retry_count + 1 WHERE file_name='$FILENAME' AND status='FAILED' ORDER BY id DESC LIMIT 1;"
echo "$(date '+%Y-%m-%d %H:%M:%S') - RETRY: $FILENAME" >> "$LOG_FILE"
/opt/elmo/transfer_file.sh "$FILE"
done
