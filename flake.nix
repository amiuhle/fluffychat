{
  description = "FluffyChat, a Matrix client for Android, iOS, and the web";
  # https://nixos.org/manual/nixpkgs/unstable/#android
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "30.0.3";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ buildToolsVersion "28.0.3" ];
          platformVersions = [ "33" "32" "31" "30" "29" "28" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          includeNDK = true;
          ndkVersions = [ "21.4.7075529" ];
          cmakeVersions = [ "3.18.1" ];
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs; mkShell rec {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";
            CHROME_EXECUTABLE = "${pkgs.chromium}/bin/chromium";
            LIBSECRET = "${pkgs.libsecret}/lib/";
            buildInputs = [
              flutter
              androidSdk
              jdk11
              chromium
              jsoncpp
              libsecret
              pass-secret-service
              rhash
              webkitgtk
              unzip
            ];
          };
      });
}
