#!/bin/bash
set -e

echo "========================="
echo " Installing Dependencies"
echo "========================="
dpkg --add-architecture i386
apt update
apt install -y \
    awscli \
    ca-certificates \
    jq \
    lib32gcc1 \
    lib32stdc++6 \
    libjson-c-dev \
    libsdl2-2.0-0:i386 \
    libtool \
    xfsprogs \

echo "======================="
echo " Installing Monitoring"
echo "======================="
cd /tmp
curl -s https://my-netdata.io/kickstart-static64.sh > kickstart-static64.sh
bash kickstart-static64.sh --dont-wait

#echo "================"
#echo " Setting up EBS"
#echo "================"
#file -s /dev/nvme1n1
#mkfs -t xfs /dev/nvme1n1
#mkdir /home/${username}
#mount /dev/nvme1n1 /home/${username}

echo "============="
echo " Setup User"
echo "============="
useradd -m ${username}
chown ${username}:${username} /home/${username}

echo "=================="
echo " Instal SteamCMD"
echo "=================="
mkdir -p /home/${username}/steam && cd /home/${username}/steam || exit
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -


echo "==========================="
echo " Installing PZ Server"
echo "==========================="
su - ${username} -c "mkdir -p /home/${username}/zomboid"
su - ${username} -c "mkdir -p /home/${username}/Zomboid/backups"
su - ${username} -c "mkdir -p /home/${username}/Zomboid/backups/startup"
su - ${username} -c "mkdir -p /home/${username}/Zomboid/backups/version"

/home/${username}/steam/steamcmd.sh +force_install_dir /home/${username}/zomboid +login anonymous +app_update 380870 validate +quit

# Copy service config
aws s3 cp s3://${bucket}/${server_name}/zomboid.service /home/${username}/zomboid/zomboid.service
aws s3 cp s3://${bucket}/${server_name}/ProjectZomboid64.json /home/${username}/zomboid/ProjectZomboid64.json

# Copy game config
aws s3 cp s3://${bucket}/${server_name}/${server_name}.ini /home/${username}/Zomboid/Server/${server_name}.ini
aws s3 cp s3://${bucket}/${server_name}/${server_name}_SandboxVars.lua /home/${username}/Zomboid/Server/${server_name}_SandboxVars.lua

# Check if backup exists on S3
BACKUPS=$(aws s3api list-objects --bucket ${bucket} --prefix "${server_name}/Save" --max-items 1 || true > /dev/null 2>&1)
if [ -z "$${BACKUPS}" ]; then
    echo "No backups found in \"s3://${bucket}/${server_name}/\". A new world will be created."
else
    echo "Backups found, restoring..."
    aws s3 sync s3://${bucket}/${server_name}/Save/ /home/${username}/Zomboid/Saves/Multiplayer/${server_name} --delete
fi

# Fix permissions
chown -R ${username}:${username} /home/${username}/Zomboid/
chown -R ${username}:${username} /home/${username}/zomboid/

# ==========================
#  Create/Start the Service
# ==========================
cp /home/${username}/zomboid/zomboid.service /etc/systemd/system
systemctl daemon-reload
systemctl enable zomboid.service
systemctl restart zomboid