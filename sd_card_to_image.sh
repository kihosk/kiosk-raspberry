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

if [ -z "$disk" ] || [ -z "$version" ] 
then
    echo "You must specify disk and version variables"
    echo "Example: ./sd_card_to_image.sh disk=2 version=0.0.9"
else
    echo "version = $version"
    echo "disk = $disk"

    cd out

    sudo dd if=/dev/rdisk$disk of=kiosk-$version.img bs=4m
    docker run --rm --privileged=true -v `pwd`:/workdir turee/pishrink-docker pishrink kiosk-$version.img kiosk-$version-shrinked.img
    sudo diskutil eject /dev/rdisk${disk}

fi



# sudo dd if=/dev/rdisk5 of=kiosk-v0.0.7.img bs=4m
# docker run --rm --privileged=true -v `pwd`:/workdir turee/pishrink-docker pishrink kiosk-v0.0.7.img kiosk-v0.0.7-shrinked.img
# sudo diskutil eject /dev/rdisk2
