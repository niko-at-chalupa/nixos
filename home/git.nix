{ ... }:

{
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
}
