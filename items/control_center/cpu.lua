#!/usr/bin/env lua

local settings = require("settings")
local colors = require("colors")
local icons = require("icons")
local make_popup = require("items.control_center.popup")

local cpu = sbar.add("item", "cpu", {
  icon = {
    string = icons.stats.cpu,
    color = colors.blue,
  },
  update_freq = 2,
  position = "right",
})

cpu:subscribe("system_stats", function(env)
  local _, _, num = string.find(env.CPU_USAGE, "(%d*)")
  local load = tonumber(num)

  local color = colors.text
  if load < 30 then
    color = colors.white
  elseif load < 60 then
    color = colors.yellow
  elseif load < 80 then
    color = colors.orange
  else
    color = colors.red
  end

  cpu:set({
    label = {
      string = env.CPU_USAGE,
      color = color,
    },
  })
end)

cpu:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

popup_items = {
  { name = "Temperature", env_name = "CPU_TEMP" },
}
make_popup(cpu, popup_items)

return cpu
