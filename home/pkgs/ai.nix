{
  pkgs-unstable,
  ...
}:
{
  home.packages = with pkgs-unstable; [
    # Qwen
    qwen-code

    # Microsoft
    github-copilot-cli

    # Open source
    opencode
    promptfoo
  ];
}
