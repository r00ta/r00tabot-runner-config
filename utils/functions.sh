#! /bin/bash 

get_mac() {
	printf '02:00:00:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
	return 0
}

get_random() {
	python3 -c "import random; print(random.randint(1, 254))"
}
