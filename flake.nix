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
          uv
          libGL
          libz
          glibc
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
          python313
          python3Packages.scikit-video
          python3Packages.ffmpeg
          libvmaf
          ffmpeg-full
          opencv
          cargo
          jq
          bc
          vqmetric-nix.packages.${system}.default
        ];

        shellHook = ''
          export PATH=$HOME/.cargo/bin:$PATH
          rustup default stable
          cargo install av-metrics-tool
          source .venv/bin/activate
        '';
        LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib/:${pkgs.libz}/lib/:${pkgs.libGL}/lib/:${pkgs.glib}/lib/";
      };
    });
  };
}
