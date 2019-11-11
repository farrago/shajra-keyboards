let fromGitHub = pkgs: source: name:
        with source; pkgs.fetchFromGitHub {
            inherit owner repo rev sha256 name;
            fetchSubmodules = true;
        };

    sources = builtins.fromJSON
        (builtins.readFile ./sources.json);

in rec {

    config = import ../config.nix;

    thirdParty = {
        nixpkgs = with sources.nixpkgs;
            builtins.fetchTarball { inherit url sha256; };
        qmk = fromGitHub pkgs sources.qmk "qmk-src";
        kaleidoscope = fromGitHub pkgs sources.kaleidoscope "kaleidoscope-src";
        model01 = fromGitHub pkgs sources.model01 "model01-src";
    };

    pkgs = import thirdParty.nixpkgs {};

    keymapPath = keymapsPath: keymapName:
        let readKeymaps = builtins.readDir keymapsPath;
            hasKeymap = readKeymaps ? "${keymapName}";
            isDirectory = readKeymaps.${keymapName} == "directory";
            result = "${keymapsPath}/${keymapName}";
            msgDir = "${toString keymapsPath}/${keymapName}";
            failNotFound = throw "keymap dir not found: ${msgDir}";
            failNotDir = throw "not a directory: ${msgDir}";
        in if hasKeymap
            then if isDirectory then result else failNotDir
            else failNotFound;

}
