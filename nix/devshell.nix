{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      plist_file = "~/Library/LaunchAgents/org.nixos.sketchybar.plist";

      load = pkgs.writeShellScriptBin "load" "launchctl load -w ${plist_file}";
      unload = pkgs.writeShellScriptBin "unload" "launchctl unload -w ${plist_file}";

      dev = pkgs.writeShellScriptBin "dev" ''
        trap 'killall sketchybar 2>/dev/null; launchctl load -w ${plist_file}' EXIT
        launchctl unload -w ${plist_file} 2>/dev/null || true
        killall sketchybar 2>/dev/null || true
        sleep 1
        ${self'.packages.default}/bin/sketchybar
      '';
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.sketchybar
          load
          unload
          dev
        ];
      };
    };
}
