{}:
let
  pkgs = import (builtins.fetchTarball {
    # qtgamepad was broken on nixos-21.11, a fix came out a month later
    name = "nixos-unstable-2021-12-17";
    url = "https://github.com/nixos/nixpkgs/archive/634141959076a8ab69ca2cca0f266852256d79ee.tar.gz";
    sha256 = "0r6ac5pazrn1whas4jkca3ssqd5xl73nmxjq5qmsnli6rk2s5skv";
  }) {};
  stdenv = pkgs.stdenv;

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

  pulseview-darwin = stdenv.mkDerivation rec {
    pname = "pulseview";
    version = "0.4.1";

    src = pkgs.fetchurl {
      url = "http://sigrok.org/download/source/pulseview/${pname}-${version}.tar.gz";
      sha256 = "0bvgmkgz37n2bi9niskpl05hf7rsj1lj972fbrgnlz25s4ywxrwy";
    };

    buildInputs = with pkgs; [
      pkgconfig
      cmake
      glib
      qt5.full
      boost
      libsigrok
      libsigrokdecode
      libserialport
      libzip
      # udev
      libusb1
      libftdi1
      glibmm
      pcre librevisa python3
     
    ];

  };
in
pkgs.mkShell {
    buildInputs = [
      arduino-darwin
      pulseview-darwin
    ];
    shellHook = ''
set -e
export ARDUINO_BIN=${arduino-darwin}/Applications/Arduino.app/Contents/MacOS/
export SIGROK_BIN=${pulseview-darwin}
# Needed to fix hanky borken window not resizing in wayland...
export _JAVA_AWT_WM_NONREPARENTING=1
export PATH="$PATH:$ARDUINO_BIN"
    '';
}
