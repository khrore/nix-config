{
  # Homebrew for macOS-native apps
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall unlisted packages
      upgrade = true;
    };

    # CLI tools not available or better via Homebrew
    brews = [
      # Add any Mac-specific brews here if needed
      "orbstack"
      "codex"
    ];

    # GUI applications
    casks = [
      # Optional: macOS-native apps that aren't in nixpkgs
      # or are better installed via Homebrew
      # Examples:
      "localsend"
      "zen@twilight"
      "docker-desktop"
      "asmvik/formulae/yabai"
      "zed"
      "ghostty"
      "anydesk"
      "chatgpt-atlas"
      "ungoogled-chromium"
    ];

    # Mac App Store apps (requires mas-cli)
    masApps = {
      # "Xcode" = 497799835;
    };
  };
}
