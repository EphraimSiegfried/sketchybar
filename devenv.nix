{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  plist_file = "~/Library/LaunchAgents/org.nixos.sketchybar.plist";
in
{
  packages = [
    inputs.custom.packages.${pkgs.system}.sketchybar-system-stats
  ];
  scripts.load.exec = "launchctl load -w ${plist_file}";
  scripts.unload.exec = "launchctl unload -w ${plist_file}";
  scripts.start = {
    exec = ''
      content=$(cat <<END
      package.cpath = package.cpath .. ";${pkgs.sbarlua}/lib/lua/${pkgs.lua54Packages.lua.luaversion}/?.so"
      sbar = require("sketchybar")

      sbar.begin_config()
      require("init")
      sbar.hotload(true)
      sbar.end_config()
      sbar.event_loop()
      END
      )
      echo "$content" > "${config.env.DEVENV_ROOT}/sketchybarrc"
    '';
    package = pkgs.lua5_4;
  };

}
