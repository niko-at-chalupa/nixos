{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.noctalia.homeModules.default
  ];
  home.username = "niko";
  home.homeDirectory = "/home/niko";
  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      gpg.format = "ssh";
    };
  };
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kdeconnect-kde
    copyq
    arrpc
    brightnessctl
    fuzzel
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprshot
    vscode
    nodejs
    pnpm
    yarn
    python3
    uv
    ripgrep
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    nixfmt
    ouch
    unzip
    ffmpeg
    deno
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = "BreezX-RosePine-Linux";
    HYPRCURSOR_SIZE = "24";
    UV_PYTHON = "${pkgs.python3}/bin/python3";
    UV_PYTHON_PREFERENCE = "only-system";
    LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.file ];
  };

  programs.noctalia = {
    enable = true;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      wallpaper = {
        enabled = true;
        default.path = "/home/niko/Pictures/Backgrounds/1/";
      };
    };
  };
}
