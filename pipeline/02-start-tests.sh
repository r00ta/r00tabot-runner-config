lxc file push -r ../tests maas-tester/home/ubuntu
lxc exec maas-tester --user 0 --cwd /home/ubuntu -- chmod +x -R /home/ubuntu/tests
lxc exec maas-tester --user 0 --cwd /tmp -- sh -c "maas apikey --username maas > api-key-file"

lxc exec maas-tester --user 1000 --cwd /home/ubuntu/tests -- sh -c "00-setup.sh" 
lxc exec maas-tester --user 1000 --cwd /home/ubuntu/tests -- sh -c "01-enlist.sh" 

