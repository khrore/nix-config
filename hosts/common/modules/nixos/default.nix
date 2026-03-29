{ isDisplay, ... }:
{
  imports = [
    ./audio.nix
    ./boot.nix
    ./compat.nix
    ./fonts.nix
    ./location.nix
    ./nix-ld.nix
    ./programs.nix
    ./services.nix
  ]
  ++ (if isDisplay then [ ./hyprland.nix ] else [ ]);
}
