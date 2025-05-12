{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        # https://nixos.org/manual/nixpkgs/stable/#ios
        xcodeWrapper = pkgs.xcodeenv.composeXcodeWrapper { };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        devShells.default =
          with pkgs;
          mkShellNoCC {
            nativeBuildInputs = [
              xcodeWrapper
            ];

            buildInputs = [

            ];

            # https://github.com/NixOS/nixpkgs/issues/358795#issuecomment-2598552176
            shellHook = ''
              export PATH=''${PATH//'${pkgs.xcbuild.xcrun}/bin:'/}
              unset DEVELOPER_DIR
              unset SDKROOT
            '';
          };
      }
    );
}
