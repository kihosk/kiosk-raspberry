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
    echo "Example: ./sd_card_to_image.sh disk=2 version=0.0.9"
    echo "Also, disk number cannot be lower than 2"
else
    echo "version = $version"
    echo "disk = $disk"

    cd out

    sudo dd if=/dev/rdisk$disk of=kiosk-$version.img bs=4m
    docker run --rm --privileged=true -v `pwd`:/workdir turee/pishrink-docker pishrink kiosk-$version.img kiosk-$version-shrinked.img
    sudo diskutil eject /dev/rdisk$disk

fi
