{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./home/dotfiles.nix
    ./home/hyprland.nix
    ./home/packages.nix
    ./home/zsh.nix
  ];
  home.username = "niko";
  home.homeDirectory = "/home/niko";
  home.stateVersion = "25.05";
  home.sessionVariables = {
    UV_PYTHON = "${pkgs.python3}/bin/python3";
    UV_PYTHON_PREFERENCE = "only-system";
  };
}
