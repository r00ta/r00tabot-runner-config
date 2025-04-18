# Start the container first because it might take some seconds to be active. In the meantime we build the snap

cd $MAAS_DIR

make snap-tree
