{
  perSystem =
    { pkgs, lib, ... }:
    let
      plist_file = "~/Library/LaunchAgents/org.nixos.sketchybar.plist";

      load = pkgs.writeShellScriptBin "load" "launchctl load -w ${plist_file}";
      unload = pkgs.writeShellScriptBin "unload" "launchctl unload -w ${plist_file}";

      start = pkgs.writeShellScriptBin "start" ''
        cp -f ${pkgs.sketchybar-app-font}/share/fonts/truetype/sketchybar-app-font.ttf ~/Library/Fonts/sketchybar-app-font.ttf
        killall sketchybar 2>/dev/null || true
        sleep 1
        sketchybar -c "$(pwd)/sketchybarrc" &
      '';

      gen-config = pkgs.writeShellScriptBin "gen-config" ''
        cat > sketchybarrc <<'EOF'
        #!${pkgs.lua5_4}/bin/lua
        package.cpath = package.cpath .. ";${pkgs.sbarlua}/lib/lua/${pkgs.lua54Packages.lua.luaversion}/?.so"
        sbar = require("sketchybar")
        sbar.begin_config()
        require("init")
        sbar.hotload(true)
        sbar.end_config()
        sbar.event_loop()
        EOF
        chmod +x sketchybarrc
        echo "Generated sketchybarrc"
      '';
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.wttrbar
          pkgs.sketchybar
          load
          unload
          start
          gen-config
        ];
      };
    };
}
