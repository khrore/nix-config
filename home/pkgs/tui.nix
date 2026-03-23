{
  lib,
  pkgs-unstable,
  mylib,
  system,
  ...
}:
let
  # NVIDIA-specific packages (only for Linux systems with NVIDIA GPU)
  nvidiaPackages =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system) [
      btop-cuda
      gpustat
      imv

      # Moved to brew
      zed-editor
    ];
  darwin =
    with pkgs-unstable;
    lib.optionals (mylib.isDarwin system) [
      btop
    ];
in
{
  home.packages =
    with pkgs-unstable;
    [
      yazi
      neovim

      # disk
      ncdu
    ]
    ++ darwin
    ++ nvidiaPackages;
}
