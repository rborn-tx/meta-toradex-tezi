FASTBOOT_DEVICE_FRAG ?= ""
FASTBOOT_DEVICE_FRAG:verdin-imx8mm ?= "file://fb-dev0.cfg"
FASTBOOT_DEVICE_FRAG:verdin-imx8mp ?= "file://fb-dev2.cfg"

FASTBOOT_PATCHES_UPSTREAM = " \
    file://0001-verdin-imx8mm-add-fastboot-env-variables-upstream.patch \
    file://0001-verdin-imx8mp-add-fastboot-env-variables-upstream.patch \
"
FASTBOOT_PATCHES_DOWNSTREAM = ""
FASTBOOT_PATCHES_DOWNSTREAM_K3 = ""

FASTBOOT_PATCHES = "${FASTBOOT_PATCHES_UPSTREAM}"
FASTBOOT_PATCHES:apalis-imx8 = "${FASTBOOT_PATCHES_DOWNSTREAM}"
FASTBOOT_PATCHES:colibri-imx8x = "${FASTBOOT_PATCHES_DOWNSTREAM}"
FASTBOOT_PATCHES:toradex-smarc-imx95 = "${FASTBOOT_PATCHES_DOWNSTREAM}"
FASTBOOT_PATCHES:verdin-imx95 = "${FASTBOOT_PATCHES_DOWNSTREAM}"
FASTBOOT_PATCHES:k3 = "${FASTBOOT_PATCHES_DOWNSTREAM_K3}"
FASTBOOT_PATCHES:k3r5 = ""

SRC_URI:append = " \
    ${FASTBOOT_DEVICE_FRAG} \
    ${FASTBOOT_PATCHES} \
"

SRC_URI:append:imx-generic-bsp = " \
    file://fb-malloc.cfg \
"

RAW_FLASHING_SUPPORTED ?= "0"
RAW_FLASHING_SUPPORTED:verdin-imx8mm ?= "1"
RAW_FLASHING_SUPPORTED:verdin-imx8mp ?= "1"

do_compile:prepend () {
    if [ "${RAW_FLASHING_SUPPORTED}" != "1" ]; then
        bbfatal 'RAW/WIC flashing is not supported on the current machine' \
                '(make RAW_FLASHING_SUPPORTED="1" to bypass this error check).'
    fi
}
