{
  lib,
  pkgs-unstable,
  mylib,
  system,
  ...
}:
let
  linuxOmarchyPkgs = lib.optionals (mylib.isLinux system) [
    # Omarchy desktop/runtime layer
    pkgs-unstable.alacritty
    pkgs-unstable.bluetui
    pkgs-unstable.elephant
    pkgs-unstable.fastfetch
    pkgs-unstable.fcitx5
    pkgs-unstable.fcitx5-gtk
    pkgs-unstable.libsForQt5.fcitx5-qt
    pkgs-unstable.gpu-screen-recorder
    pkgs-unstable.grim
    pkgs-unstable.hyprsunset
    pkgs-unstable.mako
    pkgs-unstable.mise
    pkgs-unstable.pamixer
    pkgs-unstable.polkit_gnome
    pkgs-unstable.satty
    pkgs-unstable.signal-desktop
    pkgs-unstable.slurp
    pkgs-unstable.swaybg
    pkgs-unstable.swayosd
    pkgs-unstable.uwsm
    pkgs-unstable.walker
    pkgs-unstable.wiremix
    pkgs-unstable.xdg-terminal-exec

    # Omarchy workflow tools referenced by bindings and helpers
    pkgs-unstable.imv
    pkgs-unstable.lazydocker
    pkgs-unstable.lazygit
    pkgs-unstable.netcat-openbsd
    pkgs-unstable.pam_u2f
    pkgs-unstable.xournalpp
  ];
in
{
  home.packages = linuxOmarchyPkgs;
}
