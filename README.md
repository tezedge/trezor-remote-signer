docker-compose up

docker exec 2502d335f68d /bin/sh -c "trezorctl list"

./zeronet.sh stop

/var/lib/docker/volumes/zeronet_node_data/_data/data/store
/var/lib/docker/volumes/zeronet_node_data/_data/data/context