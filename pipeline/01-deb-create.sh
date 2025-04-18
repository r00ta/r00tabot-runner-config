set -x 

cd $MAAS_DIR

echo "Installing dependencies.."

sudo add-apt-repository -y ppa:maas-committers/latest-deps
sudo apt-get update
sudo apt-get -y install make

make install-dependencies

echo "Making debs.."
make package


