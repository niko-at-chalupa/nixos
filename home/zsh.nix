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

      # --- Helix Mode Color & Cursor Customizations ---
      export ZSH_HELIX_MODE_INDICATOR_NORMAL="%F{green}%B[NOR]%b%f"
      export ZSH_HELIX_MODE_INDICATOR_INSERT="%F{cyan}%B[INS]%b%f"
      export ZSH_HELIX_MODE_INDICATOR_SELECT="%F{magenta}%B[SEL]%b%f"

      export ZSH_HELIX_MODE_NORMAL_CURSOR=$'\e[2q\e]12;green\a'
      export ZSH_HELIX_MODE_INSERT_CURSOR=$'\e[6q\e]12;white\a'   # White beam cursor for edit mode
      export ZSH_HELIX_MODE_SELECT_CURSOR=$'\e[2q\e]12;magenta\a'

      # Visual selection highlight set to #9b8bc1
      zle_highlight=(region:bg=#9b8bc1,fg=black)

      # Source plugin
      source ${inputs.zsh-helix-mode.packages.${pkgs.system}.default}/share/zsh-helix-mode/zsh-helix-mode.plugin.zsh

      # Load history search widgets AFTER helix mode initializes
      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

      # Re-bind Up/Down arrows across standard keymaps
      for km in main viins vicmd; do
        bindkey -M $km '^[[A' up-line-or-beginning-search
        bindkey -M $km '^[OA' up-line-or-beginning-search
        bindkey -M $km '^[[B' down-line-or-beginning-search
        bindkey -M $km '^[OB' down-line-or-beginning-search

        [[ -n "''${terminfo[kcuu1]}" ]] && bindkey -M $km "''${terminfo[kcuu1]}" up-line-or-beginning-search
        [[ -n "''${terminfo[kcud1]}" ]] && bindkey -M $km "''${terminfo[kcud1]}" down-line-or-beginning-search
      done
    '';
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.cargo/bin"
  ];
  home.sessionVariables.EDITOR = "nvim";
}
