{ pkgs, inputs, ... }:

{
  programs.zsh = {
    enable = true;
    envExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      [[ ! -f "$HOME/.rokit/env" ]] || source "$HOME/.rokit/env"
    '';
    oh-my-zsh = {
      enable = true;
      custom = "${pkgs.zsh-powerlevel10k}/share/zsh";
      plugins = [ "git" ];
      theme = "powerlevel10k/powerlevel10k";
    };
    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      source ${inputs.zsh-helix-mode.packages.${pkgs.system}.default}/share/zsh-helix-mode/zsh-helix-mode.plugin.zsh
    '';
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.cargo/bin"
  ];
  home.sessionVariables.EDITOR = "nvim";
}
