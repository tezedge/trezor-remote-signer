## Minimal requirements : 

* docker 
* docker-compose 
* tezos-node  

## Steps


```
Usage:
run.sh [OPTION]

Set of tools for baking on Tezos with Trezor T support

 -u,  --upload-firmware   upload firmware with Tezos baking support onto your Trezor T
 -i,  --initialize        activate faucets accounts, register as a baker & import baker address to remote signer
 -s,  --start             start baking and endorsing
 -d,  --debug           debug mode suited for development
 -h,  --help              display this set of tools again
```


## Faster Tezos node sync

Download data from running node

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
