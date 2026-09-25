#!/bin/bash
FILENAME=$(basename "$1"); sudo -n mysql -e "USE elmo; INSERT INTO file_transfer (file_name,status,start_time) VALUES ('$FILENAME','STARTED',NOW());"
