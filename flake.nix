{
  description = "System configuration by khrore";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # nix-darwin for macOS
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # home-manager for user environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    secrets = {
      # Private repo over SSH (requires working SSH agent/key access for nix).
      url = "git+ssh://git@github.com/khrore/nixrets.git";
    };
  };

  outputs =
    {
      nixpkgs,
      darwin,
      home-manager,
      ...
    }@inputs:
    let
      stateVersion = "26.05";
      nixpkgsConfig = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };

      mkPkgsFor =
        nixpkgsSource: system:
        import nixpkgsSource {
          inherit system;
          config = nixpkgsConfig;
        };

      mkPkgsUnstable =
        system:
        mkPkgsFor inputs.nixpkgs-unstable system;

      # importing library
      mylib = import ./lib/default.nix { inherit (nixpkgs) lib; };

      ######################### USER LEVEL ##########################

      # Configuration for user settings
      terminalEditor = "nvim";
      shell = "bash";

      configurationLimit = 10;

      #################################################################

      # Common special args factory
      mkSpecialArgs =
        {
          hostName,
          username,
          system,
        }:
        {
          inherit
            username
            system
            inputs
            terminalEditor
            stateVersion
            configurationLimit
            shell
            mylib
            nixpkgsConfig
            hostName
            ;
          pkgs-unstable = mkPkgsUnstable system;
        };

      mkNixosConfiguration =
        name: host:
        nixpkgs.lib.nixosSystem {
          system = host.system;
          modules = host.modules ++ [
            host.path
            inputs.agenix.nixosModules.default
            inputs.secrets.nixosModules.default
            home-manager.nixosModules.home-manager
          ];
          specialArgs = mkSpecialArgs {
            hostName = name;
            username = host.username;
            system = host.system;
          };
        };

      mkDarwinConfiguration =
        name: host:
        darwin.lib.darwinSystem {
          system = host.system;
          modules = host.modules ++ [
            host.path
            inputs.agenix.darwinModules.default
            inputs.secrets.darwinModules.default
            home-manager.darwinModules.home-manager
          ];
          specialArgs = mkSpecialArgs {
            hostName = name;
            username = host.username;
            system = host.system;
          };
        };

      hosts = {
        dev-4 = {
          kind = "nixos";
          system = "x86_64-linux";
          username = "khrore";
          path = ./hosts/dev-4;
          modules = [ inputs.disko.nixosModules.disko ];
        };

        nixos = {
          kind = "nixos";
          system = "x86_64-linux";
          username = "khorer";
          path = ./hosts/nixos;
          modules = [ inputs.disko.nixosModules.disko ];
        };

        macix = {
          kind = "darwin";
          system = "aarch64-darwin";
          username = "khrore";
          path = ./hosts/macix;
          modules = [ ];
        };
      };

      nixosHosts = nixpkgs.lib.filterAttrs (_: host: host.kind == "nixos") hosts;
      darwinHosts = nixpkgs.lib.filterAttrs (_: host: host.kind == "darwin") hosts;
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkNixosConfiguration nixosHosts;
      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwinConfiguration darwinHosts;
    };
}
