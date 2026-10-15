{ lib, ... }:

# Nushell as an opt-in interactive shell (run `nu` from zsh). The login shell is
# untouched and zsh + powerlevel10k keep working exactly as before.
#
# The prompt look lives in dotfiles/config/starship.toml (picked up by
# home/dotfiles.nix, same as the other raw dotfiles), so it can be edited and
# tried without a rebuild.
{
  programs.nushell = {
    enable = true;
    extraConfig = lib.mkAfter ''
      $env.config.show_banner = false

      # p10k's POWERLEVEL9K_TRANSIENT_PROMPT=always: once a command is run, its
      # old prompt collapses to just the prompt char.
      $env.TRANSIENT_PROMPT_COMMAND = {|| $"(ansi -e '38;5;76m')❯(ansi reset) " }
      $env.TRANSIENT_PROMPT_INDICATOR = ""
      $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
      $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
      $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""
      $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }
    '';
  };

  programs.starship = {
    enable = true;
    # Nushell only: zsh keeps powerlevel10k (these default to true and would
    # otherwise add `starship init zsh` to .zshrc on top of p10k).
    enableNushellIntegration = true;
    enableZshIntegration = false;
    enableBashIntegration = false;
  };
}
