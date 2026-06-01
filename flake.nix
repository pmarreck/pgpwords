{
	description = "PGP wordlist CLI in LuaJIT";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs }:
		let
			systems = [
				"aarch64-darwin"
				"aarch64-linux"
				"x86_64-linux"
			];
			forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
				f (import nixpkgs {
					inherit system;
				}));
		in {
			devShells = forAllSystems (pkgs: {
				default = pkgs.mkShell {
					packages = with pkgs; [
						bash
						coreutils
						luajit
						ripgrep
					];
				};
			});

			packages = forAllSystems (pkgs: {
				default = pkgs.stdenvNoCC.mkDerivation {
					pname = "pgpwords";
					version = "0.1.0";
					src = ./.;
					nativeBuildInputs = [ pkgs.luajit ];
					installPhase = ''
						mkdir -p $out/bin
						cp bin/pgpwords $out/bin/pgpwords
						chmod +x $out/bin/pgpwords
						PGPWORDS_BIN=$out/bin/pgpwords luajit -e 'assert(loadfile(os.getenv("PGPWORDS_BIN")))'
					'';
				};
			});

			checks = forAllSystems (pkgs: {
				test = pkgs.stdenvNoCC.mkDerivation {
					pname = "pgpwords-test";
					version = "0.1.0";
					src = ./.;
					nativeBuildInputs = [ pkgs.luajit ];
					doCheck = true;
					checkPhase = ''
						patchShebangs test build tests/cli/pgpwords bin || true
						./test
						./build
					'';
					installPhase = ''
						mkdir -p $out
						echo tests passed > $out/result
					'';
				};
			});
		};
}
