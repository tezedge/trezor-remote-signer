## Minimal requirements : ## 

* docker 
* docker-compose 
* tezos-node  

## Steps ##

 1. run remote_signer and listen 
 2. check if trezor is flashed

 3. exec tezos-client from docker 

 4. get tezos addrres from trezor 

 5. download faucet 
 6. send xtz to address

 7. import remote keys to tezos-client
 8. register delegate 

 9. start baking 

```
docker-compose up
```

```
docker exec 2502d335f68d /bin/sh -c "trezorctl list"
```

### Donload data from running node  ### 


Stop zeronet node otherwise data will be not usable

```
./zeronet.sh stop
```

Copy data from docker directory



```
/var/lib/docker/volumes/zeronet_node_data/_data/data/store
/var/lib/docker/volumes/zeronet_node_data/_data/data/context
```


Copy zeronet data from remote zeronet node to local directory
```
scp -r tezos@zeronet.simplestaking.com:/home/tezos/zeronet_node_data /home/juchuchu/.tezos-node/
```
