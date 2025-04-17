set -ex 

cd $MAAS_DIR

echo "Installing MAAS.."
sudo add-apt-repository -y ppa:maas-committers/latest-deps
sudo apt-get update
sudo apt install -y ../build-area/*.deb
sudo maas createadmin --username maas --password maas --email maas
