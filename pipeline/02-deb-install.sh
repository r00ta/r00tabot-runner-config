set -ex 

cd $MAAS_DIR

echo "Installing MAAS.."
sudo apt install -y ../build-area/*.deb
sudo maas createadmin --username admin --password admin --email admin@example.com

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
