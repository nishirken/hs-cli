{
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      packageName = "hs-cli";
      overlays = [ haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          ${packageName} =
            final.haskell-nix.stackProject {
              src = ./.;
              shell = {
                tools = {
                  hlint = "latest";
                  haskell-language-server = "latest";
                  ormolu = "0.1.4.1";
                };
                buildInputs = [pkgs.haskellPackages.implicit-hie pkgs.haskellPackages.stack];
                withHoogle = true;
              };
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.${packageName}.flake {};
    in flake // {
      # Built by `nix build .`
      defaultPackage = flake.packages."${packageName}:exe:${packageName}";
    });
}
