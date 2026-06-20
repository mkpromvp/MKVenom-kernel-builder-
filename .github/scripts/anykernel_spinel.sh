#!/sbin/sh
# AnyKernel3 smart direct flash for spinel (no ramdisk unpack)

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

BLOCK=auto;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

LOGFILE=/tmp/ak3_spinel_flash.log
: > "$LOGFILE"

logp() {
  ui_print "$1"
  echo "$1" >> "$LOGFILE"
}

flash_node() {
  NODE="$1"
  [ -b "$NODE" ] || return 1
  logp "- flashing $NODE"
  dd if=Image of="$NODE" bs=4096 conv=fsync >>"$LOGFILE" 2>&1 || return 1
  return 0
}

SLOT="$(getprop ro.boot.slot_suffix 2>/dev/null)"
[ -n "$SLOT" ] || SLOT="_a"
if [ "$SLOT" = "_a" ]; then
  OTHER="_b"
else
  OTHER="_a"
fi

logp "- device: $(getprop ro.product.device 2>/dev/null)"
logp "- active slot: $SLOT"

ACTIVE_OK=0
INACTIVE_OK=0

for PART in boot init_boot vendor_boot; do
  if flash_node "/dev/block/by-name/${PART}${SLOT}"; then
    ACTIVE_OK=1
    break
  fi
done

for PART in boot init_boot vendor_boot; do
  if flash_node "/dev/block/by-name/${PART}${OTHER}"; then
    INACTIVE_OK=1
    break
  fi
done

if [ "$ACTIVE_OK" -ne 1 ]; then
  logp "Aborting: failed to flash active slot on boot/init_boot/vendor_boot"
  cp -f "$LOGFILE" /sdcard/Download/ak3_spinel_flash.log 2>/dev/null || true
  cp -f "$LOGFILE" /data/local/tmp/ak3_spinel_flash.log 2>/dev/null || true
  abort
fi

logp "- flash success on active slot; inactive=$INACTIVE_OK"
cp -f "$LOGFILE" /sdcard/Download/ak3_spinel_flash.log 2>/dev/null || true
cp -f "$LOGFILE" /data/local/tmp/ak3_spinel_flash.log 2>/dev/null || true
