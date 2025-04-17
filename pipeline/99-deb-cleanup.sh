set -ex


echo "Cleaning up.."
sudo apt-get purge maas ; sudo apt-get autoremove

echo "Cleaning db.."
sudo -u postgres psql -c "DROP DATABASE maas;"
