SRC_URI:append = " \
    file://flash-linux.sh \
    file://flash-linux.README \
    file://flash-windows.bat \
    file://flash-windows.README \
    file://flash/fastboot.uuu \
    file://flash/erase-boot.uuu \
    file://flash/erase-user.uuu \
    file://flash/flash-all.uuu \
    file://flash/flash-spl.uuu \
"

do_deploy:append:tezi-raw-flashing() {
    install -d ${TEZI_RUN_DEPLOYDIR}/flash
    install -m 755 ${WORKDIR}/flash-linux.sh ${TEZI_RUN_DEPLOYDIR}
    install -m 644 ${WORKDIR}/flash-linux.README ${TEZI_RUN_DEPLOYDIR}
    install -m 644 ${WORKDIR}/flash-windows.bat ${TEZI_RUN_DEPLOYDIR}
    install -m 644 ${WORKDIR}/flash-windows.README ${TEZI_RUN_DEPLOYDIR}

    # Sanity checks:
    if ! head -n 1 ${WORKDIR}/recovery/uuu.auto | grep -q "uuu_version"; then
        bbfatal "uuu_version string not found in the first line of uuu.auto"
    fi
    cfglinenum="$(grep -n '^CFG: *FB:' ${WORKDIR}/recovery/uuu.auto | cut -f1 -d':')"
    if [ -z "${cfglinenum}" ]; then
        bbfatal "Could not find CFG: FB: line in uuu.auto"
    fi

    install -m 644 /dev/null ${TEZI_RUN_DEPLOYDIR}/flash/fastboot.uuu
    {
        head -n ${cfglinenum} ${WORKDIR}/recovery/uuu.auto
        cat ${WORKDIR}/flash/fastboot.uuu
    } >> ${TEZI_RUN_DEPLOYDIR}/flash/fastboot.uuu

    for fname in "erase-boot.uuu" "erase-user.uuu" "flash-all.uuu" "flash-spl.uuu"; do
        install -m 644 /dev/null ${TEZI_RUN_DEPLOYDIR}/flash/${fname}
        {
            sed -n -e "1p" -e "${cfglinenum}p" ${WORKDIR}/recovery/uuu.auto
            cat ${WORKDIR}/flash/${fname}
        } >> ${TEZI_RUN_DEPLOYDIR}/flash/${fname}
    done
}
