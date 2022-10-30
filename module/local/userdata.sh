#!/bin/bash
set -e

# ======================
#  Install Dependencies
# ======================
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

cd /tmp
curl -s https://my-netdata.io/kickstart-static64.sh > kickstart-static64.sh
bash kickstart-static64.sh --dont-wait

# ===========
#  Setup EBS
# ===========
echo "================"
echo " Setting up EBS"
echo "================"
file -s /dev/nvme1n1
mkfs -t xfs /dev/nvme1n1
mkdir /data
mount /dev/nvme1n1 /data

# ============
#  Setup user
# ============
useradd -m ${username}
chown ${username}:${username} /data
su - ${username} -c "mkdir -p /data/zomboid"
su - ${username} -c "mkdir -p /home/${username}/Zomboid/backups"
su - ${username} -c "mkdir -p /home/${username}/Zomboid/backups/startup"
su - ${username} -c "mkdir -p /home/${username}/Zomboid/backups/version"

# ===================
#  Install SteamCMD
# ===================
echo "======================"
echo " Installing steam cmd"
echo "======================"
mkdir -p /data/steam && cd /data/steam || exit
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# ===================
#  Install PZ Server
# ===================
echo "==========================="
echo " Installing zomboid server"
echo "==========================="
/data/steam/steamcmd.sh +force_install_dir /data/zomboid +login anonymous +app_update 380870 validate +quit

aws s3 cp s3://${bucket}/zomboid.service /data/zomboid/zomboid.service
aws s3 cp s3://${bucket}/ProjectZomboid64.json /data/zomboid/ProjectZomboid64.json
aws s3 cp s3://${bucket}/servertest.ini /home/${username}/Zomboid/Server/servertest.ini
chown ${username}:${username} /data/zomboid/zomboid.service
chown ${username}:${username} /data/zomboid/ProjectZomboid64.json
chown ${username}:${username} /home/${username}/Zomboid/Server/servertest.ini

cp /data/zomboid/zomboid.service /etc/systemd/system

# ===============
#  Start Service
# ===============
systemctl daemon-reload
systemctl enable zomboid.service
systemctl restart zomboid
