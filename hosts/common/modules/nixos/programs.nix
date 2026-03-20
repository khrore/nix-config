{ pkgs-unstable, ... }:
{
  programs = {
    zsh.enable = true;
    fish = {
      enable = true;
      package = pkgs-unstable.fish;
    };
    localsend = {
      enable = true;
      package = pkgs-unstable.localsend;
      openFirewall = true;
    };
    throne = {
      enable = true;
      package = pkgs-unstable.throne;
      tunMode.enable = true;
    };
  };
}
