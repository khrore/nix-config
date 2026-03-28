sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root "$HOME/.local/share/linux-desktop/default/systemd/system-sleep/unmount-fuse" /usr/lib/systemd/system-sleep/
