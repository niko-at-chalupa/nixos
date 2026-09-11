{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };

  home.file = {
    ".p10k.zsh".text = ''
      typeset -g POWERLEVEL9K_MODE=nerdfont-v3
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs newline prompt_char)
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs nix_shell virtualenv node_version rust_version time newline)
      typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='·'
      typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='╱'
      typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='╱'
      typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
      typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
      typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
      typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
      typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
    '';
    ".zshenv".text = ''
      export PATH="$HOME/.local/bin:$PATH"
      source "$HOME/.rokit/env"
    '';
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.cargo/bin"
  ];
  home.sessionVariables.EDITOR = "nvim";
}
