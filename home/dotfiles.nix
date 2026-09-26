{ lib, ... }:

let
  collectFiles = sourceRoot: targetRoot:
    let
      entries = builtins.readDir sourceRoot;
    in
    lib.concatMapAttrs
      (
        name: type:
        let
          source = sourceRoot + "/${name}";
          target = if targetRoot == "" then name else "${targetRoot}/${name}";
        in
        if type == "regular" then
          {
            "${target}" = {
              inherit source;
              force = true;
            };
          }
        else if type == "directory" then
          collectFiles source target
        else
          { }
      )
      entries;
in
{
  home.file =
    builtins.removeAttrs (collectFiles ../dotfiles/home "") [ ".zshrc" ".zshenv" ]
    // {
      ".p10k.zsh" = {
        source = ../dotfiles/home/.p10k.zsh;
        force = true;
      };
    }
    // collectFiles ../dotfiles/config ".config";
}
