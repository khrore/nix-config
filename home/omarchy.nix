{
  config,
  lib,
  mylib,
  pkgs,
  system,
  ...
}:
let
  isLinux = mylib.isLinux system;
  homeDir = config.home.homeDirectory;
  defaultTheme = "gruvbox";
  bashPath = lib.getExe pkgs.bash;

  repoDiscovery = ''
    find_repo_root_from_dir() {
      local start_dir current_dir

      start_dir="$1"
      [ -n "$start_dir" ] || return 1
      [ -d "$start_dir" ] || return 1

      current_dir="$(cd "$start_dir" && pwd)"

      while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/omarchy" ] && [ -f "$current_dir/flake.nix" ]; then
          printf '%s\n' "$current_dir"
          return 0
        fi
        current_dir="$(dirname "$current_dir")"
      done

      return 1
    }

    find_repo_root() {
      local candidate

      for candidate in \
        "''${NIXOS_CONFIG_ROOT:-}" \
        "''${PWD:-}" \
        "''${XDG_CONFIG_HOME:-${homeDir}/.config}" \
        "${homeDir}"
      do
        if candidate="$(find_repo_root_from_dir "$candidate" 2>/dev/null)"; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done

      while IFS= read -r candidate; do
        candidate="$(dirname "$candidate")"
        if [ -d "$candidate/omarchy" ] && [ -f "$candidate/flake.nix" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done < <(find "${homeDir}" -maxdepth 3 -name flake.nix -type f 2>/dev/null)

      return 1
    }
  '';
in
lib.mkIf isLinux {
  home.sessionVariables.OMARCHY_PATH = "${homeDir}/.local/share/omarchy";
  home.sessionPath = [
    "${homeDir}/.local/share/omarchy-wrappers/bin"
    "${homeDir}/.local/share/omarchy/bin"
  ];

  home.activation.linkOmarchyBase = {
    after = [ "linkGeneration" ];
    before = [ "linkDotfiles" ];
    data = ''
            ${repoDiscovery}

            repo_root="$(find_repo_root || true)"
            if [ -z "$repo_root" ] || [ ! -d "$repo_root/omarchy" ]; then
              echo "Omarchy submodule not found, skipping Omarchy base link."
            else
              mkdir -p "$HOME/.local/share"

              if [ -e "$HOME/.local/share/omarchy" ] && [ ! -L "$HOME/.local/share/omarchy" ]; then
                backup_path="$HOME/.local/share/omarchy.pre-link-backup"
                rm -rf "$backup_path"
                mv "$HOME/.local/share/omarchy" "$backup_path"
              fi

              ln -snf "$repo_root/omarchy" "$HOME/.local/share/omarchy"

              mkdir -p "$HOME/.local/bin"
              mkdir -p "$HOME/.local/share/omarchy-wrappers/bin"
              find "$HOME/.local/share/omarchy-wrappers/bin" -mindepth 1 -maxdepth 1 -type f -delete
              while IFS= read -r script; do
                name="$(basename "$script")"
                cat >"$HOME/.local/share/omarchy-wrappers/bin/$name" <<'EOF'
      #!${bashPath}
      exec ${bashPath} "$HOME/.local/share/omarchy/bin/$(basename "$0")" "$@"
      EOF
                chmod +x "$HOME/.local/share/omarchy-wrappers/bin/$name"
                if [ ! -e "$HOME/.local/bin/$name" ] || [ -L "$HOME/.local/bin/$name" ]; then
                  ln -snf "$HOME/.local/share/omarchy-wrappers/bin/$name" "$HOME/.local/bin/$name"
                fi
              done < <(find "$repo_root/omarchy/bin" -maxdepth 1 -type f | LC_ALL=C sort)

              mkdir -p \
                "$HOME/.config/omarchy/current" \
                "$HOME/.config/omarchy/themes" \
                "$HOME/.config/omarchy/themed" \
                "$HOME/.local/state/omarchy"
            fi
    '';
  };

  home.activation.initOmarchyTheme = {
    after = [ "linkDotfiles" ];
    before = [ ];
    data = ''
      ${repoDiscovery}

      repo_root="$(find_repo_root || true)"
      omarchy_path="$HOME/.local/share/omarchy"
      current_dir="$HOME/.config/omarchy/current"
      current_theme_dir="$current_dir/theme"
      next_theme_dir="$current_dir/next-theme"
      current_theme_name="$current_dir/theme.name"
      theme_name="${defaultTheme}"

      if [ -z "$repo_root" ] || [ ! -d "$omarchy_path/themes/$theme_name" ]; then
        echo "Omarchy theme assets not found, skipping theme initialization."
      elif [ -d "$current_theme_dir" ] && [ -f "$current_theme_name" ]; then
        :
      else
        rm -rf "$next_theme_dir"
        mkdir -p "$next_theme_dir"
        cp -r "$omarchy_path/themes/$theme_name/"* "$next_theme_dir/" 2>/dev/null || true

        colors_file="$next_theme_dir/colors.toml"
        if [ -f "$colors_file" ]; then
          sed_script="$(mktemp)"

          hex_to_rgb() {
            local hex="''${1#\#}"
            printf "%d,%d,%d" "0x''${hex:0:2}" "0x''${hex:2:2}" "0x''${hex:4:2}"
          }

          while IFS='=' read -r key value; do
            key="''${key//[\"\' ]/}"
            [ -n "$key" ] || continue
            case "$key" in
              \#*) continue ;;
            esac

            value="''${value#*[\"\']}"
            value="''${value%%[\"\']*}"

            printf 's|{{ %s }}|%s|g\n' "$key" "$value" >>"$sed_script"
            printf 's|{{ %s_strip }}|%s|g\n' "$key" "''${value#\#}" >>"$sed_script"
            case "$value" in
              \#*)
                rgb="$(hex_to_rgb "$value")"
                printf 's|{{ %s_rgb }}|%s|g\n' "$key" "$rgb" >>"$sed_script"
                ;;
            esac
          done <"$colors_file"

          for tpl in "$HOME/.config/omarchy/themed"/*.tpl "$omarchy_path/default/themed"/*.tpl; do
            [ -f "$tpl" ] || continue
            filename="$(basename "$tpl" .tpl)"
            output_path="$next_theme_dir/$filename"
            if [ ! -f "$output_path" ]; then
              sed -f "$sed_script" "$tpl" >"$output_path"
            fi
          done

          rm -f "$sed_script"
        fi

        rm -rf "$current_theme_dir"
        mv "$next_theme_dir" "$current_theme_dir"
        printf '%s\n' "$theme_name" >"$current_theme_name"

        if [ -d "$current_theme_dir/backgrounds" ]; then
          first_background="$(
            find "$current_theme_dir/backgrounds" -maxdepth 1 -type f | LC_ALL=C sort | head -n 1
          )"
          if [ -n "$first_background" ]; then
            ln -snf "$first_background" "$current_dir/background"
          fi
        fi

        if [ ! -e "$HOME/.config/btop/themes/current.theme" ] && [ -f "$current_theme_dir/btop.theme" ]; then
          mkdir -p "$HOME/.config/btop/themes"
          ln -snf "$current_theme_dir/btop.theme" "$HOME/.config/btop/themes/current.theme"
        fi

        if [ ! -e "$HOME/.config/mako/config" ] && [ -f "$current_theme_dir/mako.ini" ]; then
          mkdir -p "$HOME/.config/mako"
          ln -snf "$current_theme_dir/mako.ini" "$HOME/.config/mako/config"
        fi
      fi
    '';
  };
}
