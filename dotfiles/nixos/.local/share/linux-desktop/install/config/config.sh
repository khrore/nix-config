# Copy over Omarchy configs
mkdir -p ~/.config
cp -R ~/.local/share/linux-desktop/config/* ~/.config/

# Use default bashrc from Omarchy
cp ~/.local/share/linux-desktop/default/bashrc ~/.bashrc
