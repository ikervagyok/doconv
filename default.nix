{ nixpkgs ? null, createContainer ? false, createBinary ? true }:

let
  systemPkgs = import <nixpkgs> {};
  pinnedVersion = systemPkgs.lib.importJSON ./nixpkgs.json;
  pinnedPkgs = systemPkgs.fetchFromGitHub {
     owner = "NixOS";
     repo = "nixpkgs";
     inherit (pinnedVersion) rev sha256;
   };
  pkgs = if nixpkgs == null then import pinnedPkgs {} else import nixpkgs {};
  project = pkgs.haskellPackages.callPackage ( ./project.nix ) { };
# project = pkgs.haskell.packages.ghc844.callPackage ( ./project.nix ) { };
  filter = builtins.filterSource (path: type: type != "symlink" || !(builtins.isList (builtins.match "result.*" (baseNameOf path))));
  newProject = pkgs.lib.overrideDerivation project ( old: { src = filter old.src; });
in {

  executable = 
    if createBinary
      then newProject
      else null;

  container =
    if createContainer
      then systemPkgs.dockerTools.buildLayeredImage {
             name = "hello";
             config.Cmd = [ "${newProject}/bin/doconv-exe" ];
           }
      else null;

}
# nix-shell --run 'hpack && cabal2nix . > project.nix' && nix-build && ./result/bin/doconv-exe
