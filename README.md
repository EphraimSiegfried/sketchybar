# Sketchybar

[Sketchybar](https://github.com/FelixKratz/SketchyBar) configured with [Lua](https://github.com/FelixKratz/SbarLua).

## Sketchybarrc

This file called `sketchybarrc` has to be added and is generated by nix in my case:

```lua
#!/usr/bin/env lua

-- Add the sketchybar module to the package cpath (the module could be
-- installed into the default search path then this would not be needed)
package.cpath = package.cpath .. ";<insert sbarlua so file here"

sbar = require("sketchybar")
sbar.exec("killall sketchyhelper || sketchyhelper git.felix.sketchyhelper >/dev/null 2>&1 &")
sbar.begin_config()
require("init")
sbar.hotload(true)
sbar.end_config()
sbar.event_loop()
```
