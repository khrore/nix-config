{
  config,
  pkgs,
  lib,
  mylib,
  system,
  ...
}:

let
  platform =
    if mylib.isDarwin system then
      "darwin"
    else if mylib.isLinux system then
      "nixos"
    else
      "common";
  homeDir = config.home.homeDirectory;

  runtimeLinkingLogic = ''
    find_repo_root_from_dir() {
      local start_dir current_dir

      start_dir="$1"
      [ -n "$start_dir" ] || return 1
      [ -d "$start_dir" ] || return 1

      current_dir="$(cd "$start_dir" && pwd)"

      while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/dotfiles" ] && [ -f "$current_dir/flake.nix" ]; then
          printf '%s\n' "$current_dir"
          return 0
        fi
        current_dir="$(dirname "$current_dir")"
      done

      if [ -d "/dotfiles" ] && [ -f "/flake.nix" ]; then
        printf '/\n'
        return 0
      fi

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
        if [ -d "$candidate/dotfiles" ] && [ -f "$candidate/flake.nix" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done < <(find "${homeDir}" -maxdepth 3 -name flake.nix -type f 2>/dev/null)

      return 1
    }

    link_dotfiles_runtime() {
      local repo_root dotfiles_root common_dir platform_dir omarchy_config_dir
      local rel source target prefix source_dir target_prefix target_rel layer
      declare -A sources=()
      local -a layers=()

      repo_root="$(find_repo_root || true)"
      if [ -z "$repo_root" ]; then
        echo "Dotfiles repo not found. Set NIXOS_CONFIG_ROOT to override automatic discovery."
        return 0
      fi

      dotfiles_root="$repo_root/dotfiles"
      common_dir="$dotfiles_root/common"
      platform_dir="$dotfiles_root/${platform}"
      omarchy_config_dir="$repo_root/omarchy/config"

      if [ "${platform}" = "nixos" ] && [ -d "$omarchy_config_dir" ]; then
        layers+=("$omarchy_config_dir:.config")
      fi

      if [ -d "$common_dir" ]; then
        layers+=("$common_dir:")
      fi

      if [ -d "$platform_dir" ]; then
        layers+=("$platform_dir:")
      fi

      if [ "''${#layers[@]}" -eq 0 ]; then
        echo "No dotfiles found to link."
        return 0
      fi

      for layer in "''${layers[@]}"; do
        source_dir="''${layer%%:*}"
        target_prefix="''${layer#*:}"

        while IFS= read -r -d "" file; do
          prefix="$source_dir/"
          rel="''${file#"$prefix"}"
          if [ -n "$target_prefix" ]; then
            target_rel="$target_prefix/$rel"
          else
            target_rel="$rel"
          fi
          sources["$target_rel"]="$file"
        done < <(find "$source_dir" -type f ! -name ".gitkeep" -print0)
      done

      echo "Processing ''${#sources[@]} dotfile entries from $repo_root..."

      while IFS= read -r target_rel; do
        source="''${sources["$target_rel"]}"
        target="$HOME/$target_rel"

        mkdir -p "$(dirname "$target")"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "Warning: $target exists and is not a symlink, skipping..."
        else
          ln -snf "$source" "$target"
          echo "✓ Linked $target_rel"
        fi
      done < <(printf '%s\n' "''${!sources[@]}" | LC_ALL=C sort)
    }
  '';

  linkScript = pkgs.writeShellScriptBin "link-dotfiles" ''
    set -e

    echo "Linking dotfiles for platform: ${platform}"
    ${runtimeLinkingLogic}
    link_dotfiles_runtime

    echo "Done! Dotfiles linked successfully."
  '';
in
{
  home.packages = [ linkScript ];

  home.activation.linkDotfiles = {
    after = [ "linkGeneration" ];
    before = [ ];
    data = ''
      ${runtimeLinkingLogic}
      link_dotfiles_runtime
    '';
  };
}
