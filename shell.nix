{}:
let
  pkgs = import (builtins.fetchTarball {
    name = "nixos-21.11";
    url = "https://github.com/nixos/nixpkgs/archive/d2caa9377539e3b5ff1272ac3aa2d15f3081069f.tar.gz";
    sha256 = "0syx1mqpdm37zwpxfkmglcnb1swqvsgf6sff0q5ksnsfvqv38vh0";
  }) {};

  inherit (pkgs) lib stdenv;

  arduino-darwin = stdenv.mkDerivation rec {
    pname = "arduino";
    version = "1.8.19";

    src = pkgs.fetchzip {
      url = "https://downloads.arduino.cc/${pname}-${version}-macosx.zip";
      sha256 = "0ydsf8479ynw3mk88a0d6ic0qp337nxnjfmkllclfqzl1nviprw6";
    };

    installPhase = ''
      mkdir -p $out/Applications/Arduino.app
      mv ./* $out/Applications/Arduino.app
      chmod +x "$out/Applications/Arduino.app/Contents/MacOS/Arduino"
    '';
  };

  pulseview-darwin = pkgs.pulseview.overrideAttrs (old: {
    # the same as previous except without "udev"
    buildInputs = with pkgs; [
      glib boost libsigrok libsigrokdecode libserialport libzip libusb1 libftdi1 glibmm
      pcre librevisa python3
      qt514.qtbase qt514.qtsvg
    ];
    meta = old.meta // (with lib; {
      platforms = platforms.darwin;
    });
  });
in
pkgs.mkShell {
    buildInputs = [
      arduino-darwin
      pulseview-darwin
      pkgs.sigrok-cli
    ];
    shellHook = ''
      set -e
      export ARDUINO_BIN=${arduino-darwin}/Applications/Arduino.app/Contents/MacOS/
      export PATH="$PATH:$ARDUINO_BIN"
    '';
}
