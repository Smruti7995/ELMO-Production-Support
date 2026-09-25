sudo mysql -e "USE elmo; UPDATE file_transfer SET status='SUCCESS', end_time=NOW() WHERE file_name='$1' AND status='STARTED' ORDER BY id DESC LIMIT 1;"
