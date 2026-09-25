#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly script_dir
readonly flake_name="saffron"
readonly default_hostname="saffron"

usage() {
  cat <<EOF
Usage: $0 [--live] [--target MOUNTPOINT] [--hostname NAME]

Install this flake on the current NixOS system, or from a NixOS live USB.

Options:
  --live             Install into a mounted target (default target: /mnt).
  --target PATH      Use PATH as the mounted target in --live mode.
  --hostname NAME    Set the installed machine hostname (default: saffron).
  -h, --help         Show this help.
EOF
}

live_install=false
target=/mnt
hostname=$default_hostname
hostname_was_set=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --live)
      live_install=true
      shift
      ;;
    --target)
      [[ $# -ge 2 ]] || { echo "--target requires a path" >&2; exit 2; }
      target=$2
      shift 2
      ;;
    --hostname)
      [[ $# -ge 2 ]] || { echo "--hostname requires a name" >&2; exit 2; }
      hostname=$2
      hostname_was_set=true
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
  echo "Invalid hostname: $hostname" >&2
  echo "Use letters, numbers, and single hyphens; do not start or end with a hyphen." >&2
  exit 2
fi

if [[ "$hostname_was_set" == true && "$live_install" != true ]]; then
  echo "--hostname can only be used with --live." >&2
  exit 2
fi

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1" >&2
    exit 1
  }
}

if [[ "$live_install" == true ]]; then
  [[ $EUID -eq 0 ]] || {
    echo "Run live installation as root from the NixOS ISO." >&2
    exit 1
  }
  require_command nixos-generate-config
  require_command nixos-install
  require_command mountpoint
  require_command install
  require_command cp
  [[ -d "$target" ]] || { echo "Target does not exist: $target" >&2; exit 1; }
  mountpoint -q "$target" || {
    echo "$target is not a mountpoint. Mount the target root and /boot first." >&2
    exit 1
  }
  mountpoint -q "$target/boot" || {
    echo "$target/boot is not a mountpoint. Mount the target EFI or /boot filesystem first." >&2
    exit 1
  }

  [[ -w "$target" ]] || {
    echo "Target is not writable: $target" >&2
    exit 1
  }

  target_repo="$target/etc/nixos"
  [[ "$script_dir" != "$target_repo" ]] || {
    echo "Run this script from outside the target's /etc/nixos directory." >&2
    exit 1
  }

  install -d "$target_repo"
  cp -a "$script_dir/." "$target_repo/"
  nixos-generate-config --root "$target" --show-hardware-config > "$target_repo/hardware-configuration.nix"
  NIXOS_HOSTNAME="$hostname" nixos-install --impure --root "$target" --flake "$target_repo#$flake_name"
  echo "Installation complete. Reboot after unmounting the target filesystems."
else
  require_command nixos-rebuild
  nixos-rebuild switch --flake "$script_dir#$flake_name"
fi