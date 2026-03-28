if [[ $(plymouth-set-default-theme) != "omarchy" ]]; then
  sudo cp -r "$HOME/.local/share/linux-desktop/default/plymouth" /usr/share/plymouth/themes/omarchy/
  sudo plymouth-set-default-theme omarchy
fi
