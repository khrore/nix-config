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
    find_repo_root() {
      local candidate

      for candidate in \
        "''${NIXOS_CONFIG_ROOT:-}" \
        "${homeDir}/nixos" \
        "${homeDir}/.config/nixos"
      do
        if [ -n "$candidate" ] && [ -d "$candidate/dotfiles" ] && [ -f "$candidate/flake.nix" ]; then
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
      local repo_root dotfiles_root common_dir platform_dir
      local rel subdir source target prefix
      declare -A sources=()

      repo_root="$(find_repo_root || true)"
      if [ -z "$repo_root" ]; then
        echo "Dotfiles repo not found. Set NIXOS_CONFIG_ROOT to override automatic discovery."
        return 0
      fi

      dotfiles_root="$repo_root/dotfiles"
      common_dir="$dotfiles_root/common"
      platform_dir="$dotfiles_root/${platform}"

      if [ -d "$common_dir" ]; then
        while IFS= read -r -d "" file; do
          prefix="$common_dir/"
          rel="''${file#"$prefix"}"
          sources["$rel"]="common"
        done < <(find "$common_dir" -type f ! -name ".gitkeep" -print0)
      fi

      if [ -d "$platform_dir" ]; then
        while IFS= read -r -d "" file; do
          prefix="$platform_dir/"
          rel="''${file#"$prefix"}"
          sources["$rel"]="${platform}"
        done < <(find "$platform_dir" -type f ! -name ".gitkeep" -print0)
      fi

      if [ "''${#sources[@]}" -eq 0 ]; then
        echo "No dotfiles found to link."
        return 0
      fi

      echo "Processing ''${#sources[@]} dotfile entries from $repo_root..."

      while IFS= read -r rel; do
        subdir="''${sources["$rel"]}"
        source="$dotfiles_root/$subdir/$rel"
        target="$HOME/$rel"

        mkdir -p "$(dirname "$target")"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "Warning: $target exists and is not a symlink, skipping..."
        else
          ln -snf "$source" "$target"
          echo "✓ Linked $rel"
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
