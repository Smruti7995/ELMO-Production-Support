#!/bin/bash
INCIDENT_DIR="/opt/elmo/incidents"
LOG_FILE="/opt/elmo/logs/elmo.log"
FAILED_COUNT=$(sudo -n mysql -N -e "USE elmo; SELECT COUNT(*) FROM file_transfer WHERE status='FAILED';")
OPEN_INCIDENT=$(grep -l "Status: OPEN" "$INCIDENT_DIR"/*.txt 2>/dev/null | head -1)
if [ "$FAILED_COUNT" -gt 0 ] && [ -z "$OPEN_INCIDENT" ]; then
INCIDENT_ID="INC-$(date '+%Y%m%d%H%M%S')"
echo "Incident ID: $INCIDENT_ID" > "$INCIDENT_DIR/$INCIDENT_ID.txt"
echo "Status: OPEN" >> "$INCIDENT_DIR/$INCIDENT_ID.txt"
echo "Priority: P2" >> "$INCIDENT_DIR/$INCIDENT_ID.txt"
echo "Failed Transfers: $FAILED_COUNT" >> "$INCIDENT_DIR/$INCIDENT_ID.txt"
echo "Created: $(date '+%Y-%m-%d %H:%M:%S')" >> "$INCIDENT_DIR/$INCIDENT_ID.txt"
echo "$(date '+%Y-%m-%d %H:%M:%S') - INCIDENT CREATED: $INCIDENT_ID - FAILED TRANSFERS: $FAILED_COUNT" >> "$LOG_FILE"
fi
