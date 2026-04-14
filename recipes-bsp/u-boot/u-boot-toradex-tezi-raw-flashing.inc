FASTBOOT_DEVICE_FRAG ?= ""
FASTBOOT_DEVICE_FRAG:verdin-imx8mm ?= "file://fb-dev0.cfg"
FASTBOOT_DEVICE_FRAG:verdin-imx8mp ?= "file://fb-dev2.cfg"

SRC_URI:append = " \
    ${FASTBOOT_DEVICE_FRAG} \
"
