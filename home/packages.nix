{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kdeconnect-kde
    yaak
    copyq
    arrpc
    brightnessctl
    fuzzel
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium
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
    zsh-powerlevel10k
    lutris
    protontricks
    hyprpicker
  ];
}
