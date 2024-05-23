git submodule update --init --recursive
make snap-tree

lxc launch ubuntu:22.04 maas-tester
lxc file push -r dev-snap/ maas-tester/home/ubuntu
lxc file push Makefile maas-tester/home/ubuntu/
lxc file push utilities/connect-snap-interfaces  maas-tester/home/ubuntu/
lxc exec maas-tester --user 0 -- apt-get update
lxc exec maas-tester --user 0 -- apt-get install make -y 
lxc exec maas-tester --user 0 --cwd /home/ubuntu/ -- snap try dev-snap/tree
lxc exec maas-tester --user 0 --cwd /home/ubuntu/ -- ./connect-snap-interfaces

lxc exec maas-tester --user 0 --cwd /home/ubuntu -- apt-get install postgresql -y 
lxc exec maas-tester --user 113 -- psql -c "CREATE USER \"maasdb\" WITH ENCRYPTED PASSWORD 'maasdb'"
lxc exec maas-tester --user 113 -- createdb -O "maasdb" "maasdb" 
lxc exec maas-tester --user 0 --cwd /home/ubuntu -- sh -c "echo 'host    maasdb   maasdb    0/0     md5' >> /etc/postgresql/14/main/pg_hba.conf"
lxc exec maas-tester --user 0 --cwd /home/ubuntu -- systemctl restart postgresql 
IP_ADDRESS=$(lxc exec maas-tester --user 0 -- sh -c "ip addr show eth0")
IP_ADDRESS=$(printf "$IP_ADDRESS" | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
lxc exec maas-tester --user 0 --cwd /home/ubuntu -- sh -c "maas init region+rack --database-uri 'postgres://maasdb:maasdb@localhost/maasdb'  --maas-url $IP_ADDRESS"
lxc exec maas-tester --user 0 --cwd /home/ubuntu -- maas createadmin --username maas --password maas --email maas 




 
