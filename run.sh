#!/bin/sh

# upload firmwate with Tesos baking support to Trezor T device 
upload_firmware(){

        # swith Trezor T to bootloader mode
        # ask for confirmation device will be wiped out
        
        echo "Please turn on bootloader mode on your Trezor T : "
        echo "    1. disconnect Trezor."
        echo "    2. hold your Trezor with your finger already on the screen at the bottom."
        echo "    3. plug the cable in."
        echo "    4. slide the finger up.\n"

        echo "After 5+ minutes you will be requested to confirm new firmware on you Trezor T.\n"

        echo "\033[1;33mWARNING:\e[0m Device will be completly ereased. Please backup your mnemonic."
        read -p "Are you sure that you want to upload new firmware ? [Y/n] " RESPONSE
        if ! [ "$RESPONSE" = "y" ] && ! [ "$RESPONSE" = "" ]; then
            exit 0
        fi
        
        # get Trezor T usb path    
        TREZOR_BOOTLOADER="$(lsusb -d 1209:53c0 | awk '{print $2,$4}' | tr ' ' '/' | tr -d ':')"
        TREZOR_BOOTLOADER_USB_PATH="/dev/bus/usb/${TREZOR_BOOTLOADER}"
     
        # check if Trezor T is in bootloader mode and connected to pc
        if [ -z $TREZOR_BOOTLOADER ]; then
            echo "[-][ERROR] Please turn on bootloader mode and connect Trezor T"
            exit 0;
        fi

        # check if path to USB exists
        if ! [ -e $TREZOR_BOOTLOADER_USB_PATH ]; then
            echo "[-][ERROR] Path $TREZOR_BOOTLOADER_USB_PATH to USB device not found."
            echo "[-][ERROR] Please change TREZOR_BOOTLOADER_USB_PATH so it reflect your OS.\n"
            exit 0;
        fi

        # export variable for docker-compose
        export TREZOR_BOOTLOADER_USB_PATH
        # launch docker-compose
        docker-compose -f docker-compose.firmware.yml up
}


initialize() {
    # launch docker-compose
    docker-compose -f docker-compose.initialize.yml up
}

start_baking() {
    # launch docker-compose
    docker-compose -f docker-compose.baking.yml up
}


#  cli
while :; do
  case $1 in

    -u|--upload-firmware)
        echo "\033[1;37mUpload firmware to Trezor T with support for Tezos baking\e[0m\n";
        upload_firmware
        ;;

    -i|--initialize)
        echo "\033[1;37mInitialize baking on Tezos\e[0m\n";
        initialize
        ;;

    -s|--start)
        echo "Start banking & endorsing\n";
        start_baking
        ;;

    -h|--help)
        echo "Usage:"
        echo "run.sh [OPTION]\n"
        echo "Set of tools for baking on Tezos with Trezor T support \n"
        echo " -u,  --upload-firmware   upload firmware with support for Tezos baking on Trezor T"
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

