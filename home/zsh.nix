{ ... }:

{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "powerlevel10k/powerlevel10k";
    };
    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.cargo/bin"
  ];
  home.sessionVariables.EDITOR = "nvim";
}
