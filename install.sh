#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly flake_name="saffron"

usage() {
  cat <<EOF
Usage: $0 [--live] [--target MOUNTPOINT]

Install this flake on the current NixOS system, or from a NixOS live USB.

Options:
  --live             Install into a mounted target (default target: /mnt).
  --target PATH      Use PATH as the mounted target in --live mode.
  -h, --help         Show this help.
EOF
}

live_install=false
target=/mnt

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
  [[ -d "$target" ]] || { echo "Target does not exist: $target" >&2; exit 1; }
  mountpoint -q "$target" || {
    echo "$target is not a mountpoint. Mount the target root and /boot first." >&2
    exit 1
  }
  mountpoint -q "$target/boot" || {
    echo "$target/boot is not a mountpoint. Mount the target EFI or /boot filesystem first." >&2
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
  nixos-install --root "$target" --flake "$target_repo#$flake_name"
  echo "Installation complete. Reboot after unmounting the target filesystems."
else
  require_command nixos-rebuild
  nixos-rebuild switch --flake "$script_dir#$flake_name"
fi