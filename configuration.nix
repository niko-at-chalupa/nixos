# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "saffron"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = false;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.niko = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    helix # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    zsh
    jq
    ghostty
    obs-studio
    kdePackages.breeze
    kdePackages.qqc2-desktop-style
    kdePackages.kirigami
    kdePackages.breeze-icons
    kdePackages.kservice
    wl-clipboard
    cliphist
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    rustup
    rustc
    cargo
    rustPlatform.rustcSrc
    rust-analyzer
    rustfmt
    clippy
    gcc 
    pkg-config 
    openssl
    file
  ];

  fonts.packages = with pkgs; [
    meslo-lgs-nf
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics.enable = true;

  services.flatpak.enable = true;
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.at-spi2-core.enable = true;
  security.polkit.enable = true;

  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "KDE PolicyKit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = "1";
      TimeoutStopSec = 12;
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.udisks2.") === 0 && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.variables = {
    QML_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    QML2_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    QT_PLUGIN_PATH = "/run/current-system/sw/lib/qt-6/plugins";
    /*
	LD_LIBRARY_PATH = lib.mkForce (lib.concatStringsSep ":" [
      "/etc/sane-libs"
      (lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ])
    ]);
	*/
  };

  security.soteria.enable = true;
  services.input-remapper.enable = true;

  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  xdg.mime.enable = true;
  xdg.menus.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.printing = {
    drivers = [ pkgs.epson-escpr ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.epsonscan2 ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
    config.hyprland.default = [ "hyprland" "gtk" ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "niko-at-chalupa";
        email = "nikolekrescendo@protonmail.com";
      };
      init = {
        defaultBranch = "main";
      };
      safe = {
        directory = "/etc/nixos"; # Prevents "dubious ownership" errors when managing your system config
      };
    };
  };

  security.pam.services.niko.kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  programs.steam = {
    enable = true;
  };
  services.power-profiles-daemon.enable = true;

  services.upower.enable = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_2; # exact attr name may differ, check output above
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib   # libstdc++.so.6
    libxkbcommon        # libxkbcommon.so.0
    udev                # libudev.so.1 — actually provided by `systemd` on NixOS
    libinput             # libinput.so.10
    libgbm                 # libgbm.so.1
    fontconfig          # libfontconfig.so.1
    freetype             # libfreetype.so.6
    ncurses5             # libncurses.so.5 and libtinfo.so.5 for older Lua tools
  ];
}
