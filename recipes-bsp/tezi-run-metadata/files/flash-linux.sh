#!/bin/sh

DRY=${DRY-""}
SUDO=${SUDO-"sudo"}
VERBOSITY=${VERBOSITY-"2"}
ERASE_BOOT=${ERASE_BOOT-"1"}
ERASE_USER=${ERASE_USER-"1"}
UUU_ARGS=${UUU_ARGS-""}

WIC_IMG_LINK="./wic-image.lnk"
BL_IMG_LINK="./bootloader.lnk"

help() {
    cat <<EOF
Usage: flash-linux.sh [-q|-v]
                      [--erase-user|--no-erase-user]
                      [--erase-boot|--no-erase-boot]
                      --wic WIC_IMAGE --bootloader BOOTLOADER_IMAGE

Mandatory switches:
    --wic          Path to WIC image to flash.
    --bootloader   Path to bootloader image to flash.

Optional switches:
    -q|-v
                   Be quieter (-q) or more verbose (-v).
    --erase-user|--no-erase-user
                   Whether or not to erase the user data paritition
                   before flashing the WIC image into it.
    --erase-boot|--no-erase-boot
                   Whether or not to erase the boot parititions.

Examples:
    # Recommended usage when re-flashing a device:
    $ sudo ./flash-linux.sh --wic image.wic --bootloader flash.bin

    # When flashing a device for the first time, the time consuming
    # erasing of the user data partition can be avoided like this:
    $ sudo ./flash-linux.sh --wic image.wic --bootloader flash.bin --no-erase-user

EOF
}

hdr() {
    if [ -t 1 ]; then
	printf "= \033[93m$*\033[0m\n"
    else
	echo "=" "$*"
    fi
    if [ "${VERBOSITY}" -ge 2 ]; then
	echo ""
    fi
}

run_uuu() {
    if [ "${VERBOSITY}" -ge 3 ]; then
        ${DRY:+echo "WOULD RUN:"} ${SUDO} ./recovery/uuu ${UUU_ARGS} -V "$@"
    elif [ "${VERBOSITY}" -eq 2 ]; then
        ${DRY:+echo "WOULD RUN:"} ${SUDO} ./recovery/uuu ${UUU_ARGS} "$@"
    else
	if [ -z "${DRY}" ]; then
            ${SUDO} ./recovery/uuu ${UUU_ARGS} "$@" > /dev/null
	else
            echo "WOULD RUN:" ${SUDO} ./recovery/uuu ${UUU_ARGS} "$@"
	fi
    fi
}

make_links() {
    if [ ! -e "${WIC_IMG}" ]; then
        echo "WIC image '${WIC_IMG}' not found - aborting." >&2
        return 1
    fi

    if [ ! -e "${BL_IMG}" ]; then
        echo "Bootloader image '${BL_IMG}' not found - aborting." >&2
        return 1
    fi

    ln -sf "${WIC_IMG}" "${WIC_IMG_LINK}"
    ln -sf "${BL_IMG}" "${BL_IMG_LINK}"

    return 0
}

clear_links() {
    rm -f "${WIC_IMG_LINK}"
    rm -f "${BL_IMG_LINK}"
}

exit_error() {
    echo "# ERROR:" "$@" >&2
    clear_links
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --help|-h)
            help
            exit 0
            ;;
        --wic)
            WIC_IMG="$2"
            shift 2
            ;;
        --bootloader)
            BL_IMG="$2"
            shift 2
            ;;
        --erase-user)
            ERASE_USER="1"
            shift
            ;;
        --no-erase-user)
            ERASE_USER="0"
            shift
            ;;
        --erase-boot)
            ERASE_BOOT="1"
            shift
            ;;
        --no-erase-boot)
            ERASE_BOOT="0"
            shift
            ;;
        -q)
            VERBOSITY="1"
	    shift
            ;;
        -v)
            VERBOSITY="3"
	    shift
            ;;
        *)
	    help
            exit_error "Invalid option '$1'"
            ;;
    esac
done

if [ -z "${WIC_IMG}" ] || [ -z "${BL_IMG}" ]; then
    help
    echo "## ERROR: Missing arguments." >&2
    exit 1
fi

make_links || exit_error "Couldn't make symlinks to image files"

hdr "Loading bootloader and entering Fastboot mode..."
run_uuu flash/fastboot.uuu || exit_error "Couldn't enter Fastboot mode"

if [ "${ERASE_BOOT}" = "1" ]; then
    hdr "Erasing boot partitions..."
    run_uuu flash/erase-boot.uuu || exit_error "Couldn't erase boot partitions"
fi

if [ "${ERASE_USER}" = "1" ]; then
    hdr "Erasing user partition..."
    run_uuu flash/erase-user.uuu || exit_error "Couldn't erase user data partition"
fi

hdr "Flashing device..."
run_uuu flash/flash-all.uuu || exit_error "Couldn't flash images"

clear_links

hdr "Flashing was successful!"
