#!/bin/bash
PATH="$PATH:/usr/bin"

# Copy service config
aws s3 cp s3://${bucket}/${server_name}/zomboid.service /home/${username}/zomboid/zomboid.service
aws s3 cp s3://${bucket}/${server_name}/ProjectZomboid64.json /home/${username}/zomboid/ProjectZomboid64.json

# Copy game config
aws s3 cp s3://${bucket}/${server_name}/${server_name}.ini /home/${username}/Zomboid/Server/${server_name}.ini
aws s3 cp s3://${bucket}/${server_name}/${server_name}_SandboxVars.lua /home/${username}/Zomboid/Server/${server_name}_SandboxVars.lua

# Copy backup
aws s3 cp --recursive s3://${bucket}/${server_name}/db /home/${username}/Zomboid/db
aws s3 cp s3://${bucket}/${server_name}/backup.tar.gz /home/${username}/zomboid/backup.tar.gz
mkdir -p /home/${username}/Zomboid/Saves/Multiplayer/${server_name}
mkdir -p /home/${username}/Zomboid/db
tar -zxf /home/${username}/zomboid/backup.tar.gz --directory /home/${username}/Zomboid/Saves/Multiplayer/${server_name}
