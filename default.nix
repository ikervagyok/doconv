{ nixpkgs ? null, createContainer ? false, createBinary ? true, static ? false, ghcVersion ? null }:

let
  systemPkgs = import <nixpkgs> {};
  pinnedVersion = systemPkgs.lib.importJSON ./nixpkgs.json;
  pinnedPkgs = systemPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (pinnedVersion) rev sha256;
   };
  hsNoTest = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = selfH: superH: {
        tdigest = self.haskell.lib.dontCheck superH.tdigest;
        hslua   = self.haskell.lib.dontCheck superH.hslua;
      };
    };
  };
  pkgs = let packages = (if nixpkgs == null then import pinnedPkgs else import nixpkgs) { overlays = [ hsNoTest ]; };
         in if static then packages.pkgsMusl else packages;

  project = let hp = if ghcVersion == null then pkgs.haskellPackages else pkgs.haskell.packages.ghc844;
            in hp.callPackage ( ./project.nix ) { };
  filter = let match = regex: path: builtins.isList (builtins.match regex (baseNameOf path));
           in builtins.filterSource ( path: type: !(match "\.git" path) && !(match "result.*" path && !(match ".*\.swp" path)));
  doconv = pkgs.lib.overrideDerivation project ( old: { src = filter old.src; });

in {

  executable = 
    if createBinary
      then doconv
      else null;

  container =
    if createContainer
      then systemPkgs.dockerTools.buildLayeredImage {
             name = "hello";
             config.Cmd = [ "${doconv}/bin/doconv-exe" ];
           }
      else null;

}
# nix-shell --run 'hpack && cabal2nix . > project.nix' && nix-build && ./result/bin/doconv-exe
