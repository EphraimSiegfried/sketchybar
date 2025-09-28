#!/usr/bin/env lua

local settings = require("settings")
local colors = require("colors")
local icons = require("icons")

sbar.exec("killall sketchy_cpu_load &>/dev/null; sketchy_cpu_load cpu_update 2.0")

local cpu = sbar.add("item", "cpu", {
  icon = {
    string = icons.stats.cpu,
    color = colors.blue,
  },
  update_freq = 5,
  position = "right",
})

cpu:subscribe("cpu_update", function(env)
  -- Also available: env.user_load, env.sys_load
  local load = tonumber(env.total_load)

  local color = colors.text
  if load > 30 then
    if load < 60 then
      color = colors.yellow
    elseif load < 80 then
      color = colors.orange
    else
      color = colors.red
    end
  end

  cpu:set({
    label = {
      string = env.total_load,
      color = color,
    },
  })
end)

cpu:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

return cpu
