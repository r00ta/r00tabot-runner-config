# Start the container first because it might take some seconds to be active. In the meantime we build the snap

cd $MAAS_DIR

make snap-tree
snap install --dangerous dev-snap/maas.snap
utilities/connect-snap-interfaces

sudo snap install maas-test-db

maas init region+rack --database-uri maas-test-db:///  --maas-url http://10.0.1.1:5240/MAAS
maas createadmin --username maas --password maas --email maas
