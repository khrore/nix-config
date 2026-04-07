{ pkgs-unstable, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs-unstable; [
      neovim
      zed-editor
      code-cursor
    ];
  };
}
