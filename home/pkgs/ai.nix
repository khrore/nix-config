{
  pkgs-unstable,
  ...
}:
{
  home.packages = with pkgs-unstable; [
    # Qwen
    qwen-code

    # Open source
    opencode
    promptfoo
  ];
}
