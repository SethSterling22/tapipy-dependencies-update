{
  description = "TapisUI DevEnv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
        tapipyPython = python.withPackages (ps: [
          ps.requests
          ps.pip
          ps.pyaml
          ps.jwt
          ps.openapi-core
          ps.atomicwrites
        ]);
        commonPackages = [
          tapipyPython
          pkgs.docker
          pkgs.poetry
          pkgs.gnugrep
          pkgs.xdg-utils
          pkgs.which
          pkgs.ripgrep
          pkgs.fd
          pkgs.libffi # needed for cffi package which is a dependency of something
        ];

        # menu script package with an optional version parameter
        tapisMenu = pkgs.writeScriptBin "menu" ''
          #!${pkgs.bash}/bin/bash
          echo -e "Entering tapipy nix development environment..."

          # if input $1 is version or --version, show npm and node version
          if [[ "$1" == "version" || "$1" == "--version" ]]; then
            PYTHON_VERSION=$(python --version)
            POETRY_VERSION=$(poetry --version)
            NIX_VERSION=$(nix --version)
            echo -e "Python: $PYTHON_VERSION"
            echo -e "Poetry: $POETRY_VERSION"
            echo -e "Nix: $NIX_VERSION"
          fi

          if ! docker info > /dev/null 2>&1; then
            echo "Docker: Not running. Please start Docker on host. Some commands may not work."
          else
            echo "Docker: $(docker -v)"
          fi

          #poetry env use $(which python)

          

          echo -e "\nAvailable Makefile commands:
          ============================
            - make build: Build the Python package
            - make install: Install the Python package
            - make test: Run tests (in Docker) (must place password in Makefile)
            - make pull_specs: Update OpenAPI specs
          
          Available Python poetry commands:
          ============================
            - poetry install: Install dependencies
            - poetry update: Update dependencies
            - poetry env list: List poetry environments
            - poetry env info: Show poetry environment info
            - poetry run <sh>: Run command in poetry environment
            - poetry build: Build the package
            - poetry publish --username=__token__ --password=pypi-TOKEN: Publish the package
          
          Common commands:
          ============================
            - menu: callable from nix shell, shows this help message
            - menu --version: shows npm and node version + menu
            - nix develop -i: --ignore-environment to isolate nix shell from user env
            - nix develop .#menu: runs menu version in nix shell
            - nix flake show: to view flake outputs

          To Run Tapipy in Dev Shell:
          ============================
            1. Enter shell with: nix develop
            2. Install tapipy from source with: poetry install
            3. Enter python repl: python3
          "
        '';
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = commonPackages ++ [
              tapisMenu
            ];
            shellHook = ''
              menu version
            '';
          help = pkgs.mkShell {
            packages = commonPackages;
            shellHook = ''
              echo "Entering TapisUI nix shell..."
              echo "Available make commands:"
              echo "========================="
              make help
            '';
            };
          };
        };
      }
    );
}

