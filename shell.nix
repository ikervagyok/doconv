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
in 
  systemPkgs.mkShell { buildInputs = with pkgs; [ cabal2nix haskellPackages.hpack ]; }
