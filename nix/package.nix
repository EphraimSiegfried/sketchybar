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
            cat > init.lua.in <<LUAEOF
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

            cat > sketchybarrc <<'SHEOF'
            #!/usr/bin/env bash
            SHEOF
            echo "${pkgs.lua5_5}/bin/lua ${placeholder "out"}/init.lua.in" >> sketchybarrc
            chmod +x sketchybarrc
          '';


        installPhase = ''
          mkdir -p $out
          cp -r *.lua *.lua.in items sketchybarrc $out/
        '';
      };

      sketchybar-wrapped = pkgs.writeShellScriptBin "sketchybar" ''
        exec ${pkgs.sketchybar}/bin/sketchybar -c ${config}/sketchybarrc "$@"
      '';
    in
    {
      packages.default = sketchybar-wrapped;
      packages.sketchybar-config = config;
    };
}
