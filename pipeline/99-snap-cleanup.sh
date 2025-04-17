set -ex 

echo "Cleaning up.."
sudo snap remove --purge maas
sudo snap remove --purge maas-test-db
