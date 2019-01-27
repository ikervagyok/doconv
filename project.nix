{ mkDerivation, aeson, base, brick, hpack, pandoc, servant
, servant-client, servant-server, stdenv, text, time, transformers
, wai, warp
}:
mkDerivation {
  pname = "doconv";
  version = "0.0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson base brick pandoc servant servant-client servant-server text
    time transformers wai warp
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson base brick pandoc servant servant-client servant-server text
    time transformers wai warp
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/ikervagyok/doconv#readme";
  license = stdenv.lib.licenses.agpl3;
}
