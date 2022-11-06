#!/bin/bash
PATH="$PATH:/usr/bin"
set -e
echo "Backing up Server data"
touch backup.tar.gz
tar czf backup.tar.gz --directory=/home/${username}/Zomboid/Saves/Multiplayer/${server_name} .
aws s3 cp --recursive /home/${username}/Zomboid/db s3://${bucket}/${server_name}/db/
aws s3 cp backup.tar.gz s3://${bucket}/${server_name}/backup.tar.gz


