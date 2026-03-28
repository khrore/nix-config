{
  lib,
  pkgs-unstable,
  mylib,
  system,
  inputs,
  ...
}:
let
  # Linux-specific utilities
  linuxUtils = lib.optionals (mylib.isLinux system) [
    # Wayland-specific
    pkgs-unstable.cliphist
    pkgs-unstable.grimblast
    pkgs-unstable.wl-clipboard
    pkgs-unstable.showmethekey
    pkgs-unstable.wtype

    pkgs-unstable.brightnessctl
    pkgs-unstable.playerctl
    pkgs-unstable.libsForQt5.qt5ct
    pkgs-unstable.libsForQt5.qt5.qtwayland
    pkgs-unstable.libxkbcommon
    pkgs-unstable.rofimoji
    pkgs-unstable.nwg-look
    pkgs-unstable.alsa-lib
    pkgs-unstable.catppuccin-cursors.mochaDark
  ];

  # Cross-platform utilities
  sharedUtils = [
    # Git
    pkgs-unstable.git
    pkgs-unstable.gh

    # Media tools
    pkgs-unstable.ffmpeg

    # CLI utilities
    pkgs-unstable.nh
    # pkgs-unstable.yt-dlp
    pkgs-unstable.file
    pkgs-unstable.jd-diff-patch
    pkgs-unstable.libnotify
    pkgs-unstable.jq

    # Networking
    pkgs-unstable.sing-box
    pkgs-unstable.wget
    pkgs-unstable.mtr
    pkgs-unstable.iperf3
    pkgs-unstable.socat
    pkgs-unstable.nmap
    pkgs-unstable.ipcalc
    pkgs-unstable.openssl
    pkgs-unstable.prettyping

    # Filesystem
    pkgs-unstable.fuse
    pkgs-unstable.smbclient-ng

    # Encription
    pkgs-unstable.gnupg

    # Archives
    pkgs-unstable.zip
    pkgs-unstable.unzip
    pkgs-unstable.xz
    pkgs-unstable.p7zip

    # Docs
    pkgs-unstable.pandoc
    pkgs-unstable.texliveSmall

    inputs.agenix.packages.${system}.default
  ];
in
{
  home.packages = sharedUtils ++ linuxUtils;
}
