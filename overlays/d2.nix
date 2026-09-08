final: prev: let
  version = "0.9.0";
  releases = {
    aarch64-darwin = {
      platform = "macos-arm64";
      hash = "sha256-6vbAwUPlbdn6l7+23yXqnB685AJF8FagdozxpsFdMGQ=";
    };
    x86_64-darwin = {
      platform = "macos-amd64";
      hash = "sha256-ytOVdqSA1rsC6hQv7xcmZHkUsNLaUczJswtmCisbq/A=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "sha256-rCwChpcZlHmssyHbHj1oyu6fK6SS7XPKo80T84Kb+RM=";
    };
    x86_64-linux = {
      platform = "linux-amd64";
      hash = "sha256-VmndxGuZ6ULMlgePSk421eYhAzSPTAUXnt4ngC/dh6k=";
    };
  };
  release = releases.${final.stdenv.hostPlatform.system};
in {
  # Upstream binaries avoid upgrading the pinned Go toolchain to 1.27.
  d2 = final.stdenvNoCC.mkDerivation {
    pname = "d2";
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/d2lang/d2/releases/download/v${version}/d2-v${version}-${release.platform}.tar.gz";
      inherit (release) hash;
    };

    nativeBuildInputs = [final.installShellFiles];
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 bin/d2 "$out/bin/d2"
      installManPage man/d2.1
      install -Dm644 LICENSE.txt "$out/share/licenses/d2/LICENSE.txt"
      install -Dm644 THIRD_PARTY_NOTICES.txt "$out/share/licenses/d2/THIRD_PARTY_NOTICES.txt"
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      test "$("$out/bin/d2" --version)" = "v${version}"
      "$out/bin/d2" layout tala
      printf 'api -> db: queries\n' > smoke.d2
      for format in svg png txt; do
        "$out/bin/d2" --layout=tala --timeout=30 smoke.d2 "smoke.$format"
        test -s "smoke.$format"
      done
      runHook postInstallCheck
    '';

    meta =
      prev.d2.meta
      // {
        homepage = "https://d2lang.com";
        changelog = "https://github.com/d2lang/d2/releases/tag/v${version}";
        platforms = builtins.attrNames releases;
        sourceProvenance = [final.lib.sourceTypes.binaryNativeCode];
      };
  };
}
