#!/usr/bin/env bash

set -eou pipefail

VG_GROUP=MAIN
NIXROOT=NIXROOT
NIXSWAP=NIXSWAP

read -p "This is an unecrypted installation, are you sure? Type uppercase yes: "
echo
if [[ ! $REPLY == "YES" ]]; then
    echo "Stopping execution"
    exit 2
fi

# Make sure the disk exists
DISK=/dev/disk/by-id/$1
if [ -e $DISK ]; then
    echo "$DISK found"
else
    echo "$DISK not found"
    exit 1
fi

# Make sure the script is not executed by accident
read -p "This will wipe $1, all data will be lost! Type uppercase yes: "
echo
if [[ ! $REPLY == "YES" ]]; then
    echo "Stopping execution"
    exit 2
fi

# Clear disk
wipefs -af "$DISK"
sgdisk -Zo "$DISK"

# Create GPT partition table
parted "$DISK" -- mklabel gpt

# Create boot partition
parted "$DISK" -- mkpart ESP fat32 1MiB 2048MiB
parted "$DISK" -- set 1 boot on

# Create root partition
parted "$DISK" -- mkpart primary 2048MiB 100%

# Let the system sync the changes
sleep 1

# Create physical volume
pvcreate "${DISK}-part2"

# Create volume group
vgcreate "$VG_GROUP" "${DISK}-part2"

# Create logical volumes
lvcreate -L 16GB -n "$NIXSWAP" "$VG_GROUP"
lvcreate -l 100%FREE -n "$NIXROOT" "$VG_GROUP"

# Format NIXROOT partition as ext4
mkfs.ext4 -L "$NIXROOT" "/dev/mapper/${VG_GROUP}-${NIXROOT}"

# Format NIXSWAP partition as swap
mkswap -L "$NIXSWAP" "/dev/mapper/${VG_GROUP}-${NIXSWAP}"

# Format boot partition as FAT32
mkfs.vfat -F32 -n boot "${DISK}-part1"

# Mount NIXROOT
mount -t ext4 "/dev/mapper/${VG_GROUP}-${NIXROOT}" /mnt

# Mount NIXBOOT
mkdir /mnt/boot
mount "${DISK}-part1" /mnt/boot

# Enable NIXSWAP
swapon "/dev/mapper/${VG_GROUP}-${NIXSWAP}"

# Generate initial NixOS configuration
nixos-generate-config --root /mnt
