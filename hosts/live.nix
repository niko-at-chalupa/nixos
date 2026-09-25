{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  persistLabel = "saffron-persist";
  volumeId = "SAFFRON_LIVE";

  saffronPersistScript = pkgs.writeShellApplication {
    name = "saffron-persist";
    runtimeInputs = with pkgs; [
      util-linux
      coreutils
      gawk
      gnugrep
      gptfdisk
      parted
      e2fsprogs
    ];
    text = ''
      subcommand="''${1:-status}"

      case "$subcommand" in
        status)
          echo "=== Saffron Live Persistence Status ==="
          if mountpoint -q /persist; then
            dev=$(findmnt -n -o SOURCE /persist)
            echo "Persistent Partition : Mounted ($dev)"
            echo "Mount Options        : $(findmnt -n -o OPTIONS /persist)"
            echo "Persistence Disk     : $(df -h /persist | awk 'NR==2 {print $3 "/" $2 " used (" $5 ")"}')"
          else
            echo "Persistent Partition : NOT mounted (running in ephemeral mode)"
          fi

          if mountpoint -q /home/niko; then
            src=$(findmnt -n -o SOURCE /home/niko)
            echo "/home/niko           : Persistent ($src)"
          else
            echo "/home/niko           : Ephemeral (tmpfs in RAM)"
          fi

          if mountpoint -q /nix/var; then
            src=$(findmnt -n -o SOURCE /nix/var)
            echo "/nix/var             : Persistent ($src)"
          else
            echo "/nix/var             : Ephemeral (tmpfs in RAM)"
          fi

          echo ""
          echo "=== Memory & Swap (4GB Balance) ==="
          free -h
          echo ""
          if [[ -f /proc/swaps ]]; then
            echo "Active Swap Devices:"
            cat /proc/swaps
          fi
          ;;

        sync)
          echo "Flushing dirty buffers to disk..."
          sync
          echo "Data safely synced to storage."
          ;;

        help|--help|-h)
          echo "Usage: saffron-persist [status|sync]"
          echo "  status   Show current persistence, mount, and memory status"
          echo "  sync     Flush buffered writes to SD card / persistent media"
          ;;

        *)
          echo "Unknown subcommand: $subcommand"
          echo "Run 'saffron-persist help' for available commands."
          exit 1
          ;;
      esac
    '';
  };
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
    ../configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "saffron-live";
  image.fileName = lib.mkForce "saffron-live.iso";
  isoImage.volumeID = lib.mkForce volumeId;

  # Ensure fontconfig generates caches for Wayland/Hyprland
  fonts.fontconfig.enable = lib.mkForce true;

  # Auto login to Hyprland as niko
  services.greetd = {
    enable = true;
    settings.initial_session = {
      command = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/Hyprland";
      user = "niko";
    };
  };

  # Passwordless sudo and empty initial password for live user
  security.sudo.wheelNeedsPassword = false;
  users.users.niko.initialHashedPassword = "";

  # Home Manager setup for niko in live environment
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.niko = import ../home.nix;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
  };

  # Provide configuration flake inside /etc/nixos
  environment.etc."nixos".source = ./..;

  # ----------------------------------------------------
  # Memory Balancing for 4GB RAM
  # ----------------------------------------------------
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # 2GB compressed RAM swap
    priority = 100;
  };

  # Cap ephemeral /tmp to 512MB RAM
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "512M";

  # ----------------------------------------------------
  # SD Card Endurance Optimizations
  # ----------------------------------------------------
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  # ----------------------------------------------------
  # Persistent Filesystems Setup
  # ----------------------------------------------------
  fileSystems = lib.mkForce (
    config.lib.isoFileSystems
    // {
      "/persist" = {
        device = "/dev/disk/by-label/${persistLabel}";
        fsType = "ext4";
        options = [
          "noatime"
          "nodiratime"
          "commit=60"
          "nofail"
          "x-systemd.device-timeout=3s"
        ];
      };
      "/home/niko" = {
        device = "/persist/home/niko";
        fsType = "none";
        options = [
          "bind"
          "nofail"
        ];
        depends = [ "/persist" ];
      };
      "/nix/var" = {
        device = "/persist/nix-var";
        fsType = "none";
        options = [
          "bind"
          "nofail"
        ];
        depends = [ "/persist" ];
      };
    }
  );

  # Automatically partition remaining SD space if saffron-persist partition is missing
  systemd.services.saffron-persist-init = {
    description = "Auto-initialize persistent partition on boot media";
    wantedBy = [ "persist.mount" "local-fs.target" ];
    before = [ "persist.mount" "local-fs.target" ];
    after = [ "systemd-udev-settle.service" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutSec = 90;
    };
    path = with pkgs; [
      gptfdisk
      parted
      e2fsprogs
      util-linux
      systemd
      coreutils
      gawk
      gnugrep
    ];
    script = ''
      set -euo pipefail

      if blkid -L "${persistLabel}" >/dev/null 2>&1; then
        echo "Persistence partition '${persistLabel}' already exists. Skipping partitioning."
        exit 0
      fi

      iso_mount="/iso"
      if ! mountpoint -q "$iso_mount"; then
        echo "Live ISO mountpoint $iso_mount not found. Skipping auto-partitioning."
        exit 0
      fi

      iso_dev=$(findmnt -n -o SOURCE "$iso_mount" || true)
      if [[ -z "$iso_dev" || ! -b "$iso_dev" ]]; then
        echo "Cannot locate block device for $iso_mount. Skipping."
        exit 0
      fi

      parent_disk=$(lsblk -no PKNAME "$iso_dev" 2>/dev/null || true)
      if [[ -z "$parent_disk" ]]; then
        echo "Could not find parent disk for $iso_dev. Skipping."
        exit 0
      fi

      parent_dev="/dev/$parent_disk"
      if [[ ! -b "$parent_dev" ]]; then
        echo "Parent device $parent_dev does not exist. Skipping."
        exit 0
      fi

      # Check if device is read-only (e.g. CD-ROM)
      if [[ -f "/sys/block/$parent_disk/ro" ]] && [[ "$(<"/sys/block/$parent_disk/ro")" -eq 1 ]]; then
        echo "Boot device $parent_dev is read-only. Skipping."
        exit 0
      fi

      echo "Attempting to create persistence partition on $parent_dev..."

      # Move secondary GPT header to end of disk if GPT
      sgdisk -e "$parent_dev" || true

      # Add new partition using remaining space
      if sgdisk -N 0 -c 0:"${persistLabel}" "$parent_dev"; then
        echo "New partition created successfully on $parent_dev."
        partprobe "$parent_dev" || true
        udevadm settle || true

        # Identify newly created partition
        new_part=$(lsblk -rnpo NAME,PARTLABEL "$parent_dev" | awk -v label="${persistLabel}" '$2==label {print $1; exit}')
        if [[ -z "$new_part" ]]; then
          # Fallback: select last partition on parent disk
          new_part=$(lsblk -rnpo NAME "$parent_dev" | tail -n 1)
        fi

        if [[ -n "$new_part" && -b "$new_part" ]]; then
          echo "Formatting $new_part with ext4..."
          mkfs.ext4 -F -L "${persistLabel}" -m 1 -O fast_commit "$new_part"
          udevadm trigger --name-match="$new_part" || true
          udevadm settle || true
          echo "Persistence partition formatted and ready."
        fi
      else
        echo "Failed to create partition on $parent_dev. Continuing in ephemeral mode."
      fi
    '';
  };

  # Prepare persistent directories and populate ~/nixos if needed
  systemd.services.saffron-persist-prep = {
    description = "Prepare directory structure on persistent partition";
    wantedBy = [ "home-niko.mount" "nix-var.mount" "local-fs.target" ];
    after = [ "persist.mount" ];
    before = [ "home-niko.mount" "nix-var.mount" "local-fs.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [ coreutils util-linux ];
    script = ''
      set -euo pipefail

      if mountpoint -q /persist; then
        echo "Preparing persistent directories on /persist..."
        mkdir -p /persist/home/niko /persist/nix-var /persist/nix-rw/store /persist/nix-rw/work
        chown 1000:100 /persist/home/niko
        chmod 700 /persist/home/niko

        if [[ ! -d /persist/home/niko/nixos ]]; then
          echo "Populating ~/nixos with initial configuration..."
          cp -a /etc/nixos /persist/home/niko/nixos || true
          chown -R 1000:100 /persist/home/niko/nixos || true
        fi
      fi
    '';
  };

  # Extra utilities for the live environment
  environment.systemPackages = with pkgs; [
    saffronPersistScript
    gptfdisk
    parted
    e2fsprogs
    dosfstools
  ];
}
