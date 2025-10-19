#!/usr/bin/env lua

local settings = require("settings")
local colors = require("colors")
local icons = require("icons")
local make_popup = require("items.control_center.popup")

local ram = sbar.add("item", "ram", {
  icon = {
    string = icons.stats.memory,
    color = colors.blue,
  },
  update_freq = 2,
  position = "right",
  popup = {
    align = "right",
  },
})

ram:subscribe("system_stats", function(env)
  local _, _, num = string.find(env.RAM_USAGE, "(%d*)")
  local load = tonumber(num)

  local color = colors.text
  if load < 60 then
    color = colors.white
  elseif load < 80 then
    color = colors.orange
  else
    color = colors.red
  end

  ram:set({
    label = {
      string = env.RAM_USAGE,
      color = color,
    },
  })
end)

popup_items = {
  { name = "RAM Total", env_name = "RAM_TOTAL" },
  { name = "RAM Used", env_name = "RAM_USED" },
  { name = "Swap Usage", env_name = "SWP_USAGE" },
}
make_popup(ram, popup_items)

ram:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

return ram
