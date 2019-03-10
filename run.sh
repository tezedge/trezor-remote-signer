#!/bin/sh


while :; do
  case $1 in

    -u|--upload-firmware)
        echo "Upload firmware\n";
        ;;

    -i|--initialize)
        echo "Initialize baking on Tezos";
        ;;

    -s|--start)
        echo "Start banking & endorsing\n";
        ;;

    -h|--help)
        echo "Usage:"
        echo "run.sh [OPTION]\n"
        echo "Set of tools for baking on Tezos with Trezor T support \n"
        echo " -u,  --upload-firmware   upload firmware with support for 'baking mode' on Trezor T"
        echo " -i,  --initialize        activate faucets accounts, register delegate & import delegator address to remote signer"
        echo " -s,  --start             start baking and endorsing"
        echo " -h,  --help              display this message"
        exit 0
        ;;
    
    --)              
        shift
        break   
        ;;

    -?*)
        printf 'Unknown option: %s\n' "$1" >&2
        echo "(run $0 -h for help)\n"
        ;;
  
    ?*)
        echo "Missing option"
        echo "(run $0 -h for help)\n"
        ;;
  
    *)
        break
    
    esac

    shift
done
