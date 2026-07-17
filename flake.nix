{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs — bleeding edge
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager — master tracks unstable nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Niri compositor (Wayland tiling compositor)
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # iNiR desktop shell (bar, panels, dock, notifications, etc.)
    inir.url = "github:snowarch/inir";
    inir.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # =====================================================================
    # NixOS hosts
    # =====================================================================
    nixosConfigurations = {
      # --- my-laptop: Kaby Lake i5-7440HQ, HD 630, 8GB ---
      my-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/my-laptop/configuration.nix
          ./hosts/my-laptop/hardware-configuration.nix
        ];
      };

      # --- my-pc: Ivy Bridge i5-3470, HD 4000, 8GB, USB WiFi+BT ---
      my-pc = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/my-pc/configuration.nix
          ./hosts/my-pc/hardware-configuration.nix
        ];
      };
    };

    # =====================================================================
    # Home Manager configurations
    # =====================================================================
    homeConfigurations = {
      "banumath@my-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./hosts/my-laptop/home.nix
        ];
      };

      "banumath@my-pc" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./hosts/my-pc/home.nix
        ];
      };
    };
  };
}
