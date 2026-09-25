#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly script_dir
readonly persist_label="saffron-persist"

usage() {
  cat <<EOF
Usage: sudo $0 <TARGET_DEVICE> [ISO_PATH]

Flash Saffron Live ISO to an SD card or USB flash drive with automatic
persistent storage setup (/home/niko and /nix) optimized for flash endurance.

Arguments:
  TARGET_DEVICE    Block device to flash (e.g., /dev/sdX, /dev/mmcblk0)
  ISO_PATH         Optional path to ISO (default: result/iso/saffron-live.iso)

Examples:
  sudo $0 /dev/sdb
  sudo $0 /dev/mmcblk0 ./result/iso/saffron-live.iso
EOF
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (or with sudo)." >&2
  exit 1
fi

target_dev="$1"
iso_path="${2:-}"

if [[ -z "$iso_path" ]]; then
  iso_path=$(find "$script_dir/result/iso" -maxdepth 1 -name "*.iso" 2>/dev/null | head -n 1 || true)
fi

if [[ ! -b "$target_dev" ]]; then
  echo "Error: '$target_dev' is not a valid block device." >&2
  exit 1
fi

# Prevent accidentally flashing partitions instead of whole disks
if [[ "$target_dev" =~ [0-9]$ && ! "$target_dev" =~ mmcblk[0-9]+$ && ! "$target_dev" =~ nvme[0-9]+n[0-9]+$ ]]; then
  echo "Warning: '$target_dev' appears to be a partition, not a whole disk." >&2
  echo "Please specify the entire disk (e.g., /dev/sdb instead of /dev/sdb1)." >&2
  exit 1
fi

# Refuse to touch root drive
root_dev=$(findmnt -n -o SOURCE / || true)
if [[ -n "$root_dev" && "$root_dev" == "$target_dev"* ]]; then
  echo "Error: Target '$target_dev' contains the current running root system!" >&2
  exit 1
fi

if [[ -z "$iso_path" || ! -f "$iso_path" ]]; then
  echo "ISO not found. Attempting to build via 'nix build .#iso'..."
  (cd "$script_dir" && nix build .#iso)
  iso_path=$(find "$script_dir/result/iso" -maxdepth 1 -name "*.iso" 2>/dev/null | head -n 1 || true)
  if [[ -z "$iso_path" || ! -f "$iso_path" ]]; then
    echo "Error: Failed to find or build ISO image." >&2
    exit 1
  fi
fi

echo "=========================================================="
echo "Target Device : $target_dev ($(lsblk -no SIZE,MODEL "$target_dev" 2>/dev/null | head -n 1 | xargs))"
echo "Source ISO    : $iso_path ($(du -h "$iso_path" | cut -f1))"
echo "=========================================================="
echo "WARNING: ALL DATA ON '$target_dev' WILL BE DESTROYED!"
read -rp "Are you sure you want to continue? (type 'yes'): " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "Aborted by user."
  exit 0
fi

echo "Unmounting any mounted partitions on $target_dev..."
for part in $(lsblk -npo NAME "$target_dev" | tail -n +2); do
  if mountpoint -q "$part" 2>/dev/null || findmnt "$part" >/dev/null 2>&1; then
    umount -l "$part" 2>/dev/null || true
  fi
done

echo "Writing ISO to $target_dev (dd)..."
dd if="$iso_path" of="$target_dev" bs=4M status=progress conv=fsync

echo "Relocating GPT header to end of disk..."
partprobe "$target_dev" 2>/dev/null || true
udevadm settle || true
sgdisk -e "$target_dev" || true

echo "Creating persistence partition in remaining space..."
sgdisk -N 0 -c 0:"$persist_label" "$target_dev"
partprobe "$target_dev" 2>/dev/null || true
udevadm settle || true

persist_part=$(lsblk -rnpo NAME,PARTLABEL "$target_dev" | awk -v label="$persist_label" '$2==label {print $1; exit}')
if [[ -z "$persist_part" ]]; then
  # Fallback to the last partition
  persist_part=$(lsblk -rnpo NAME "$target_dev" | tail -n 1)
fi

echo "Formatting persistence partition ($persist_part) as ext4 with fast_commit..."
mkfs.ext4 -F -L "$persist_label" -m 1 -O fast_commit "$persist_part"
udevadm settle || true

echo "Pre-seeding directories on persistent partition..."
tmp_mount=$(mktemp -d)
mount "$persist_part" "$tmp_mount"

mkdir -p "$tmp_mount/home/niko" "$tmp_mount/nix-var" "$tmp_mount/nix-rw/store" "$tmp_mount/nix-rw/work"
chown -R 1000:100 "$tmp_mount/home/niko"
chmod 700 "$tmp_mount/home/niko"

echo "Copying NixOS repository to ~/nixos..."
mkdir -p "$tmp_mount/home/niko/nixos"
cp -a "$script_dir/." "$tmp_mount/home/niko/nixos/"
chown -R 1000:100 "$tmp_mount/home/niko/nixos"

umount "$tmp_mount"
rmdir "$tmp_mount"
sync

echo ""
echo "=========================================================="
echo " SUCCESS! Saffron Live SD/USB drive is ready to boot."
echo " - Boot live into Hyprland"
echo " - Persistent storage active for /home/niko and /nix"
echo " - Memory optimized for 4GB RAM + ZRAM Swap"
echo " - SD card endurance protections active (noatime, commit=60)"
echo "=========================================================="
