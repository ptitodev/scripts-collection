#!/usr/bin/env bash
screen -dmS gdrive-rclone01 rclone sync --bwlimit 3M --progress --checksum --no-update-modtime --transfers 8 --checkers 16 --update -v /mnt/pool0/pool0-dataset0-smb gdrive-rclone01:/backup/pool0-dataset0-smb