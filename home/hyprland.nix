{ inputs, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  home.sessionVariables = {
    HYPRCURSOR_THEME = "BreezX-RosePine-Linux";
    HYPRCURSOR_SIZE = "24";
  };
}
