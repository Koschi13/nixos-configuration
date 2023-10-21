#!/usr/bin/env sh

# Make sure the disk exists
DISK=/dev/disk/by-id/$1
if [ -e $DISK ]
then
    echo yes
else
    echo "$DISK not found"
    exit 1
fi

# Make sure the script is not executed by accident
read -p "This will wipe $1, all data will be lost! Type uppercase yes: "
echo
if [[ ! $REPLY == "YES" ]]
then
    echo "Stopping execution"
    exit 2
fi

# Clear disk
wipefs -af $DISK
sgdisk -Zo $DISK

# Create GPT partition table
parted $DISK -- mklabel gpt

# Create boot partition
parted $DISK -- mkpart ESP fat32 1MiB 2048MiB
parted $DISK -- set 1 boot on

# Create root partition
parted $DISK -- mkpart primary 2048MiB 100%

# Create LUKS container
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random $DISK-part2

# Open LUKS container
cryptsetup open $DISK-part2 luksroot

# Create physical volume
pvcreate /dev/mapper/luksroot

# Create volume group
vgcreate main /dev/mapper/luksroot

# Create logical volumes
lvcreate -L 16GB -n NIXSWAP main
lvcreate -l 100%FREE -n NIXROOT main

# Format NIXROOT partition as ext4
mkfs.ext4 -L NIXROOT /dev/mapper/main-NIXROOT

# Format NIXSWAP partition as swap
mkswap -L NIXSWAP /dev/mapper/main-NIXSWAP

# Format boot partition as FAT32
mkfs.vfat -F32 -n boot $DISK-part1

# Mount NIXROOT
mount -t ext4 /dev/mapper/man-NIXROOT /mnt

# Mount NIXBOOT
mkdir /mnt/boot
mount $DISK-pat1 /mnt/boot

# Enable NIXSWAP
swapon /dev/mapper/main-NIXSWAP

# Generate initial NixOS configuration
nixos-generate-config --root /mnt
