{
  description = "Flake for installing dependencies needed to use wrapper script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    vqmetric-nix.url = "github:allesis/vqmetric-nix/main";
  };

  outputs = {
    self,
    nixpkgs,
    vqmetric-nix,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
          };
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bc
          jq
          libvmaf
          ffmpeg-full
	  opencv
          vqmetric-nix.packages.${system}.default
          just
          cargo
          bash-language-server
          python313Packages.jedi-language-server
        ];

        nativeBuildInputs = with pkgs; [
          libvmaf
          ffmpeg-full
	  opencv
          jq
          bc
          vqmetric-nix.packages.${system}.default
        ];

        shellHook = ''
          export PATH=$HOME/.cargo/bin:$PATH
          cargo install av-metrics-tool
        '';
      };
    });
  };
}
