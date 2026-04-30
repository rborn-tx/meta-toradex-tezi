# Inherit class to sign BSP related images (bootloader, kernel FIT image);
# the following class comes from layer meta-toradex-security:
inherit tdx-signed

TDX_AMEND_ROOT_ARGUMENT = "0"
TDX_UBOOT_HARDENING_ENABLE_CP_PROT = "1"
TDX_UBOOT_HARDENING_ENABLE_FB_PROT = "1"

# Per-machine default boot arguments:
# TODO: Set boot arguments for all machines after hardening TEZI itself.
TEZI_SECBOOT_REQUIRED_BOOTARGS_DEFAULT ?= "fake_kernel_arguments_to_prevent_execution_of_unhardened_installer"

# Users of the present class should set TEZI_SECBOOT_REQUIRED_BOOTARGS to
# override the secure boot kernel arguments (if needed).
TEZI_SECBOOT_REQUIRED_BOOTARGS ?= "${TEZI_SECBOOT_REQUIRED_BOOTARGS_DEFAULT}"
TDX_SECBOOT_REQUIRED_BOOTARGS = "${TEZI_SECBOOT_REQUIRED_BOOTARGS}"

# Extra command categories required for WIC erasing/flashing:
#
# - CMD_CAT_MMC_CONTROL is required by the "mmc partconf" command.
# - CMD_CAT_MMC_WRITE is required to allow the "mmc erase" command; unlike the
#   Fastboot erase command, it gives granular control on which areas will be
#   erased.
#
TDX_SECBOOT_WL_ALLOW_CLOSED_CATEG_DEFAULT = "CMD_CAT_ALL_SAFE CMD_CAT_MMC_CONTROL CMD_CAT_MMC_WRITE"
