
set -ex 

echo "Installing MAAS.."
sudo snap install maas-test-db
sudo snap install --dangerous dev-snap/maas.snap
utilities/connect-snap-interfaces


sudo maas init region+rack --database-uri maas-test-db:///  --maas-url http://10.0.1.1:5240/MAAS
sudo maas createadmin --username maas --password maas --email maas

printf "Waiting for MAAS to be up and running.."
sleep 15
while true; do
    status=$(curl -s -o /dev/null -w "%{http_code}" http://10.0.1.1:5240/MAAS/a/openapi.json)
    if [ "$status" -eq 200 ]; then
        echo "Server is up! (HTTP 200)"
        break
    else
        echo "Waiting... (HTTP $status)"
        sleep 2  # Wait 1 second before retrying
    fi
done
