{
  perSystem =
    { pkgs, lib, ... }:
    let
      config = pkgs.stdenvNoCC.mkDerivation {
        pname = "sketchybar-config";
        version = "0.1.0";

        src = lib.cleanSourceWith {
          src = ../.;
          filter =
            path: type:
            let
              baseName = baseNameOf path;
              relPath = lib.removePrefix (toString ../. + "/") (toString path);
            in
            (type == "regular" && lib.hasSuffix ".lua" baseName)
            || (type == "directory" && lib.hasPrefix "items" relPath);
        };

        buildPhase =
          let
            sbarluaDir = builtins.dirOf (lib.findFirst (lib.hasSuffix "sketchybar.so") "" (
              lib.filesystem.listFilesRecursive pkgs.sbarlua
            ));
          in
          ''
            cat > sketchybarrc <<LUAEOF
            #!${pkgs.lua5_5}/bin/lua
            local dir = "${placeholder "out"}"
            package.path = dir .. "/?.lua;" .. dir .. "/?/init.lua;" .. package.path
            package.cpath = package.cpath .. ";${sbarluaDir}/?.so"
            sbar = require("sketchybar")
            sbar.begin_config()
            require("init")
            sbar.hotload(true)
            sbar.end_config()
            sbar.event_loop()
            LUAEOF
            chmod +x sketchybarrc
          '';

        installPhase = ''
          mkdir -p $out
          cp -r *.lua items sketchybarrc $out/
        '';
      };

      runtimeDeps = with pkgs; [
        wttrbar
        blueutil
      ];

      sketchybar-wrapped = pkgs.writeShellScriptBin "sketchybar" ''
        export PATH="${lib.makeBinPath runtimeDeps}:$PATH"
        if [ $# -eq 0 ]; then
          exec ${pkgs.sketchybar}/bin/sketchybar -c ${config}/sketchybarrc
        else
          exec ${pkgs.sketchybar}/bin/sketchybar "$@"
        fi
      '';
    in
    {
      packages.default = sketchybar-wrapped;
      packages.sketchybar-config = config;
    };
}
