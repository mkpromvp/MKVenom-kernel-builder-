### AnyKernel3 - spinel stable script (official AK3 style)

properties() { '
kernel.string=__KERNEL_NAME__
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=spinel
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# IMPORTANT:
# - use partition name (not manual path)
# - use slot auto-detection
BLOCK=boot;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

# active slot (kernel-only, no ramdisk unpack)
split_boot;
flash_boot;

# inactive slot
reset_ak keep;
SLOT_SELECT=inactive;
BLOCK=boot;
IS_SLOT_DEVICE=auto;
split_boot;
flash_boot;
