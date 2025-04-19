set -ex


echo "Cleaning up.."
sudo DEBIAN_FRONTEND=noninteractive apt remove --purge -y 'maas*' 'postgresql*' && sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove
