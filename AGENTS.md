# AGENTS.md - Project Memory Map (nixos)

This file captures repository-specific structure and intent so coding agents can inspect the right places quickly and avoid cross-host regressions.

## Purpose

- Repository type: multi-host Nix flake covering NixOS and `nix-darwin`, with Home Manager used mainly as a package layer on top of shared system modules.
- Main goal: keep host definitions small and composable while centralizing reusable packages, root-level system behavior, dotfiles, and platform-specific modules.
- Primary use cases: workstation bootstrap, developer tool installation, desktop setup, shell/editor environment, and portable multiagent workflow configuration.
- Change priority: preserve evaluation stability first, then host portability, then ergonomics.

## Top-Level Layout

- `flake.nix`: canonical entrypoint for inputs, outputs, host registry, and shared `specialArgs`.
- `flake.lock`: pinned upstream revisions.
- `hosts/`: per-host entrypoints plus shared system modules.
- `home/`: shared Home Manager configuration, package bundles, and dotfile activation.
- `lib/`: helper functions for module scanning, platform checks, and dotfile merging.
- `dotfiles/`: symlinked user config files, with `common/` plus platform overrides.
- `docs/workflow/`: multiagent workflow specs and runtime adapter docs.

## Flake Model

Defined hosts:

- `dev-4`: NixOS, `x86_64-linux`, user `khrore`
- `nixos`: NixOS, `x86_64-linux`, user `khorer`
- `macix`: Darwin, `aarch64-darwin`, user `khrore`

Core inputs in use:

- `nixpkgs` and `nixpkgs-unstable`: package sources
- `darwin`: `nix-darwin`
- `home-manager`: user environment layer
- `disko`: disk layout modules for Linux hosts
- `zen-browser`: browser package source
- `agenix`: encrypted secret management
- `secrets`: private flake with host secret modules

Shared `specialArgs` passed into modules:

- `hostName`, `username`, `system`
- `inputs`
- `stateVersion`, `shell`, `terminalEditor`, `configurationLimit`
- `mylib`
- `nixpkgsConfig`
- `pkgs-unstable`

Notes:

- `nixpkgsConfig` enables unfree packages and NVIDIA license acceptance.
- The `secrets` input is a private SSH-backed repository, so evaluation on a new machine depends on SSH access.
- Username values differ between Linux hosts; treat that as intentional until proven otherwise.

## Module Composition

- `hosts/<host>/default.nix` is the host entrypoint.
- Each host imports `hosts/common/default.nix`.
- `hosts/common/default.nix` imports:
  - `./modules`
  - `./nixpkgs-config.nix`
  - `../../home`
- `hosts/common/modules/default.nix` imports:
  - `./shared` on all platforms
  - `./nixos` only on Linux
  - `./darwin` only on macOS

Shared system behavior:

- Enables flakes and trusted user access in `hosts/common/modules/shared/nix.nix`.
- Sets timezone to `Europe/Moscow`.
- Configures user creation, default shell, OpenSSH, and `agenix` identity/secret paths in `hosts/common/default.nix`.

Linux-specific behavior:

- `boot.nix`: `systemd-boot` with configurable generation limit.
- `audio.nix`: PipeWire and RTKit.
- `fonts.nix`: JetBrains Mono Nerd Font defaults.
- `hyprland.nix`: Hyprland with UWSM.
- `location.nix`: locale defaults.
- `nix-ld.nix`: compatibility layer for selected binaries.
- `programs.nix`: `fish`, `zsh`, `localsend`, and `throne`.
- `services.nix`: Docker and `udisks2`.

Darwin-specific behavior:

- Auto-imports all modules in `hosts/common/modules/darwin/`.
- `hosts/macix/default.nix` sets macOS defaults, shell programs, SSH restrictions, and primary user.
- `hosts/macix/homebrew.nix` manages Homebrew brews and casks for tools that fit macOS better outside Nix.

## Home Manager Model

- Entry: `home/default.nix`
- Uses global packages and user packages.
- Imports all `home/pkgs/*.nix` bundles plus `home/link-dotfiles.nix`.
- Enables `programs.home-manager.enable`.
- In practice this layer is primarily used to install user packages and expose the `link-dotfiles` helper; dotfile linking can also be run manually outside a full Home Manager switch.

Package bundles are grouped by concern:

- `ai.nix`: `qwen-code`, `github-copilot-cli`, `opencode`, `promptfoo`
- `gui.nix`: desktop apps, browsers, terminals, editors, media tools, Hyprland utilities
- `lang.nix`: language servers, formatters, linters, debuggers, and build tools
- `shell.nix`: shell quality-of-life tools such as `atuin`, `zoxide`, `starship`, `fzf`, `bat`, `ripgrep`
- `tui.nix`: terminal-first apps such as `neovim`, `yazi`, `spotify-player`, `ncdu`, `btop`
- `utils.nix`: Git, networking, archive, document, filesystem, and encryption utilities

This repo is optimized for:

- Nix-managed workstation provisioning
- CLI-heavy development
- Hyprland-based Linux desktop usage
- macOS workstation setup through `nix-darwin` plus Homebrew
- AI/agent tooling in both terminal and dotfile layers

## Dotfiles Model

- Dotfiles live under `dotfiles/common`, `dotfiles/nixos`, and `dotfiles/darwin`.
- `home/link-dotfiles.nix` generates a `link-dotfiles` helper and a Home Manager activation hook.
- `link-dotfiles` is user-invokable at any time; do not assume dotfile changes require a Home Manager rebuild.
- Dotfiles are discovered at runtime from:
  - `$NIXOS_CONFIG_ROOT`
  - `$HOME/nixos`
  - `$HOME/.config/nixos`
  - or a nearby `flake.nix` discovered under `$HOME`
- Platform-specific files override `common` by relative path.

Implication for new environments:

- The repo no longer assumes only `$HOME/nixos`, but that location still remains the simplest default.

## Workflow And Agent Files

- Canonical workflow docs live under `docs/workflow/`.
- OpenCode runtime files live in `dotfiles/common/.config/opencode/`.
- Codex runtime files live in `dotfiles/common/.codex/`.
- Queue order is:
  - `analyzer -> researcher -> planner -> coder -> reviewer -> tester -> technical-writer -> summarizer`

When touching workflow files:

- Keep adapter behavior aligned across docs and dotfile runtime configs.
- Avoid changing queue order or review/test semantics without updating docs and runtime config together.

## Known Risks

- Private `secrets` input blocks reproducibility on machines without SSH access to that repository.
- Linux hosts depend on `disko` and host-specific hardware modules, so cloning this repo onto unrelated hardware is not drop-in.
- Some package choices are platform-specific or duplicated across Nix and Homebrew; preserve intent before consolidating.
- Dotfile linking can skip targets that already exist as non-symlinks in `$HOME`.

## Validation Baseline

Run the smallest relevant checks after behavior changes:

1. `nix flake check`
2. `nixos-rebuild build --flake .#dev-4` for Linux shared changes
3. `nixos-rebuild build --flake .#nixos` when touching that host
4. `darwin-rebuild build --flake .#macix` for Darwin changes

If commands are unavailable or blocked by missing private inputs, report that explicitly.

## Editing Guardrails

- Keep changes scoped; avoid unrelated host churn.
- Preserve Linux/Darwin guards.
- Prefer shared modules only for genuinely cross-host behavior.
- Do not hardcode variables or environment-specific values in code; when such values are required, move them into the relevant app configuration and reference them from there.
- Do not commit secrets, decrypted payloads, or machine-local tokens.
- Stop if touched files changed unexpectedly outside the current task.
