{}:
let
  unstable-pkgs = import (builtins.fetchTarball {
    # qtgamepad was broken on nixos-21.11, a fix came out a month later
    name = "nixos-unstable-2022-3-20";
    url = "https://github.com/nixos/nixpkgs/archive/3b3a69db09be401aca15436ae879ae0b1aac5dfd.tar.gz";
    sha256 = "0xjrshbcak5g8cakk0m7b4qy179agqbf2v79196xmkm7x5z8h7z5";
  }) {};

  setqt5 = self: super: {
    qt5 = unstable-pkgs.qt5;
    qtwebkit = super.qtwebkit;
  };

  stable-pkgs = import (builtins.fetchTarball {
    name = "nixos-21.11";
    url = "https://github.com/nixos/nixpkgs/archive/d2caa9377539e3b5ff1272ac3aa2d15f3081069f.tar.gz";
    sha256 = "0syx1mqpdm37zwpxfkmglcnb1swqvsgf6sff0q5ksnsfvqv38vh0";
  }) {
    overlays = [
      setqt5
    ];
  };

  pkgs = unstable-pkgs; 

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
