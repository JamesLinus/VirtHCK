#!/bin/sh

# Copyright (c) 2013, Daynix Computing LTD (www.daynix.com)
# All rights reserved.
#
# Maintained by oss@daynix.com
#
# This file is a part of VirtHCK, please see the wiki page
# on https://github.com/daynix/VirtHCK/wiki for more.
#
# This code is licensed under standard 3-clause BSD license.
# See file LICENSE supplied with this package for the full license text.

echo "Starting HCK studio..."

# Run the config file passed here
. $1

STUDIO_CONTROL_IFNAME=cs_${UNIQUE_ID}
STUDIO_CONTROL_MAC=56:cc:cc:ff:cc:cc
STUDIO_TRANSFER_MAC=56:aa:aa:ff:aa:aa
STUDIO_WORLD_IFNAME=ws_${UNIQUE_ID}
STUDIO_WORLD_MAC=56:${UID_FIRST}:${UID_SECOND}:${UID_FIRST}:${UID_SECOND}:dd

WORLD_NET_DEVICE="-netdev tap,id=hostnet0,script=${HCK_ROOT}/hck_world_bridge_ifup_${UNIQUE_ID}.sh,downscript=no,ifname=${STUDIO_WORLD_IFNAME}
                 -device ${WORLD_NET_DEVICE},netdev=hostnet0,mac=${STUDIO_WORLD_MAC},bus=pci.0,id=${STUDIO_WORLD_IFNAME}"

CTRL_NET_DEVICE="-netdev tap,id=hostnet1,script=${HCK_ROOT}/hck_ctrl_bridge_ifup_${UNIQUE_ID}.sh,downscript=no,ifname=${STUDIO_CONTROL_IFNAME}
                -device ${CTRL_NET_DEVICE},netdev=hostnet1,mac=${STUDIO_CONTROL_MAC},bus=pci.0,id=${STUDIO_CONTROL_IFNAME}"

if [ ${SHARE_ON_HOST} != "false" ]; then
  FILE_TRANSFER_SETUP="-netdev user,id=filenet0,net=${SHARE_ON_HOST_NET}.0/24,dhcpstart=${SHARE_ON_HOST_NET}.15,smb=${SHARE_ON_HOST},smbserver=${SHARE_ON_HOST_NET}.1,restrict=on \
                       -device ${FILE_TRANSFER_DEVICE},netdev=filenet0,mac=${STUDIO_TRANSFER_MAC}"
fi

${QEMU_BIN} \
    -drive file=${STUDIO_IMAGE},if=ide${DRIVE_CACHE_OPTION} \
    ${WORLD_NET_DEVICE} \
    ${CTRL_NET_DEVICE} \
    ${FILE_TRANSFER_SETUP} \
    -m 2G -smp 1 -enable-kvm -cpu qemu64,+x2apic,+fsgsbase -usbdevice tablet \
    -uuid 9999127c-8795-4e67-95da-8dd0a8891cd1 \
    -name HCK-Studio_${UNIQUE_ID}_`hostname`_${TITLE_POSTFIX} \
    -rtc base=localtime \
    ${GRAPHICS_STUDIO} ${MONITOR_STUDIO} ${SNAPSHOT_OPTION} ${STUDIO_EXTRA}

