#!/bin/bash
FILE="$1"
/opt/elmo/db_start.sh "$FILE"
DEST_USER="smruti123"
DEST_IP="192.168.56.102"
DEST_DIR="/opt/elmo/processed"
LOG_FILE="/opt/elmo/logs/elmo.log"
FILENAME=$(basename "$FILE")
echo "$(date '+%Y-%m-%d %H:%M:%S') - starting transfer: $FILENAME" >> "$LOG_FILE"
scp "$FILE" "$DEST_USER@$DEST_IP:$DEST_DIR/"
if [ $? -eq 0 ]; then
/opt/elmo/db_success.sh "$FILENAME"
echo "$(date '+%Y-%m-%d %H:%M:%S') - SUCCESS: $FILENAME" >> "$LOG_FILE"
rm "$FILE"
else
sudo -n mysql -e "USE elmo; UPDATE file_transfer SET status='FAILED', end_time=NOW(), error_message='SCP transfer failed' WHERE file_name='$FILENAME' AND status='STARTED' ORDER BY id DESC LIMIT 1;"
echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILED: $FILENAME" >> "$LOG_FILE"
mv "$FILE" /opt/elmo/failed/
fi
