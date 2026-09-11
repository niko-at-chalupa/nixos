{ inputs, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  home.sessionVariables = {
    HYPRCURSOR_THEME = "BreezX-RosePine-Linux";
    HYPRCURSOR_SIZE = "24";
  };
}
