for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            version) version=${VALUE} ;;
            disk) disk=${VALUE} ;;
            *)
    esac    

done

if [ -z "$disk" ] || [ -z "$version" ] || [ "$version" -lt "2" ]
then
    echo "You must specify disk and version variables"
    echo "Example: ./image_to_sd_card.sh disk=2 version=0.0.9"
    echo "Also, disk number cannot be lower than 2"
else
    echo "version = $version"
    echo "disk = $disk"

    cd out

    diskutil unmountDisk /dev/disk$disk
    sudo dd bs=1m if=kiosk-$version-shrinked.img of=/dev/rdisk$disk; sync
    sudo diskutil eject /dev/rdisk$disk

fi
