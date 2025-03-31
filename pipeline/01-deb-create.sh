set -x 

cd $MAAS_DIR

echo "Installing dependencies.."
sudo apt-get -y install make
make install-dependencies

echo "Making debs.."
make package

echo "Installing MAAS.."
sudo add-apt-repository -y ppa:maas-committers/latest-deps
sudo apt-get update
sudo apt install -y ../build-area/*.deb
maas createadmin --username maas --password maas --email maas

