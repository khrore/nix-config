OMARCHY_MIGRATIONS_STATE_PATH=~/.local/state/linux-desktop/migrations
mkdir -p $OMARCHY_MIGRATIONS_STATE_PATH

for file in ~/.local/share/linux-desktop/migrations/*.sh; do
  touch "$OMARCHY_MIGRATIONS_STATE_PATH/$(basename "$file")"
done
