let 

    fromGitHub = pkgs: source: name:
        with source; pkgs.fetchFromGitHub {
            inherit owner repo rev sha256 name;
            fetchSubmodules = true;
        };

    sources = builtins.fromJSON
        (builtins.readFile ./sources.json);

    nix-project-all = import (import ./sources.nix).nix-project;

    pkgs = import (import ./sources.nix).nixpkgs {
        config = {};
    };

    qmk-factory = fromGitHub pkgs sources.qmk "qmk-src";

    kaleidoscope-factory =
        fromGitHub pkgs sources.kaleidoscope "kaleidoscope-src";

    model01-factory = fromGitHub pkgs sources.model01 "model01-src";

    shajra-keyboards-common = pkgs.callPackage (import ./common.nix) {
        inherit nix-project-all;
    };

in rec {

    shajra-keyboards-ergodoxez = 
        pkgs.callPackage (import ./ergodoxez.nix) {
            inherit 
            qmk-factory
            shajra-keyboards-common;
        };

    shajra-keyboards-model01 = 
        pkgs.callPackage (import ./model01.nix) {
            inherit 
            kaleidoscope-factory
            model01-factory
            shajra-keyboards-common;
        };

    shajra-keyboards-flash = 
        pkgs.callPackage (import ./flash.nix) {
            inherit shajra-keyboards-common;
        };

    shajra-keyboards-flash-scripts = 
        pkgs.callPackage (import ./flash-scripts.nix) {
            inherit shajra-keyboards-flash;
        };

    shajra-keyboards-licenses = 
        pkgs.callPackage (import ./licenses.nix) {
            inherit 
            kaleidoscope-factory
            model01-factory
            qmk-factory
            shajra-keyboards-common;
        };

    org2gfm = nix-project-all.org2gfm;

    nix-project = nix-project-all.nix-project;

    inherit pkgs;

}
