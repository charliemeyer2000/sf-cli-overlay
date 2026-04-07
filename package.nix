{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  sourcesFile,
}:
let
  sourcesData = lib.importJSON sourcesFile;
  inherit (sourcesData) version;
  sources = sourcesData.platforms;
  source =
    sources.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # Map nix platform to the binary name inside the zip
  binaryName =
    {
      "aarch64-darwin" = "sf-node22-macos-arm64";
      "x86_64-darwin" = "sf-node22-macos-x64";
      "aarch64-linux" = "sf-node22-linux-arm64";
      "x86_64-linux" = "sf-node22-linux-x64";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "sf";
  inherit version;

  src = fetchurl {inherit (source) url hash;};
  sourceRoot = ".";

  nativeBuildInputs =
    [unzip]
    ++ lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 ${binaryName} $out/bin/sf
    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "SF Compute CLI — a market for buying time on GPU clusters";
    homepage = "https://sfcompute.com";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "sf";
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  };
}
