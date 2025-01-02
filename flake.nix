{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/haskell-updates";
    # nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";

    hackage-unix.url = "github:haskell/unix";
    hackage-unix.flake = false;
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        # inputs.common.flakeModules.ghc810
        inputs.haskell-flake.flakeModule
      ];

      perSystem = { self', pkgs, config, ... }: {

        haskellProjects.default = {
          # basePackages = config.haskellProjects.ghc910.outputs.finalPackages;
          # basePackages = pkgs.haskell.packages.ghc910;
          basePackages = pkgs.haskell.packages.ghc912;
          packages = {
            # unix.source = pkgs.haskell.packages.unix_2_8_6_0;
            # unix.source = pkgs.haskellPackages.unix_2_8_6_0;

            # unix.source = inputs.hackage-unix;
            # unix_2_8_5_1.source = inputs.hackage-unix;
            # unix_2_8_6_0.source = inputs.hackage-unix;
            # unix.source = "2.8.6.0";
            # unix.source = "2.8.6.0";
            # unix_2_8_6_0.source = "2.8.6.0";
            # aeson.source = "1.5.0.0"; # Hackage version override
            # shower.source = inputs.shower;
            # unix.source = pkgs.haskellPackages.unix_2_8_6_0;

          };
          settings = {
            # Cabal-syntax
            # unix = { super, ... }:
            #   { custom = _: super.unix_2_8_6_0; };
            # unix = { super, ... }:
            #   { custom = _: super.unix_2_8_6_0; };

            Cabal.jailbreak = true;
            # unix_2_8_6_0.jailbreak = true;
            # aeson = {
            #   check = false;
            # };
            # relude = {
            #   haddock = false;
            #   broken = false;
            # };
          };

          devShell = {
           # Enabled by default
           enable = true;

           # Programs you want to make available in the shell.
           # Default programs can be disabled by setting to 'null'
           # tools = hp: { fourmolu = hp.fourmolu; ghcid = null; };

           hlsCheck.enable = false;
          };
        };

        # haskell-flake doesn't set the default package, but you can do it here.
        packages.default = self'.packages.cabal-install;
      };
    };
}
