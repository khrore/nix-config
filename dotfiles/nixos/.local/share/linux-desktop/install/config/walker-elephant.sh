#!/bin/bash

# Ensure Walker service is started automatically on boot
mkdir -p ~/.config/autostart/
cp $HOME/.local/share/linux-desktop/default/walker/walker.desktop ~/.config/autostart/

# And is restarted if it crashes or is killed
mkdir -p ~/.config/systemd/user/app-walker@autostart.service.d/
cp $HOME/.local/share/linux-desktop/default/walker/restart.conf ~/.config/systemd/user/app-walker@autostart.service.d/restart.conf

# Create pacman hook to restart walker after updates
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/walker-restart.hook > /dev/null << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = walker
Target = walker-debug
Target = elephant*

[Action]
Description = Restarting Walker services after system update
When = PostTransaction
Exec = $HOME/.local/share/linux-desktop/bin/omarchy-restart-walker
EOF

# Link the visual theme menu config
mkdir -p ~/.config/elephant/menus
ln -snf $HOME/.local/share/linux-desktop/default/elephant/omarchy_themes.lua ~/.config/elephant/menus/omarchy_themes.lua
ln -snf $HOME/.local/share/linux-desktop/default/elephant/omarchy_background_selector.lua ~/.config/elephant/menus/omarchy_background_selector.lua
