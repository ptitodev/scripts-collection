rclone sync --bwlimit 6M --progress --checksum --transfers 8 --checkers 8 --tpslimit 8 --tpslimit-burst 8 --update --filter-from $HOME/.config/rclone/filter-file-movies.txt --drive-acknowledge-abuse --drive-use-trash=true --log-level INFO --delete-during --log-file $HOME/.config/rclone/log/upload-gcrypt-usmba.log /mnt/pool0/p0ds0smb/media gcrypt-usmba:/p0ds0smb
