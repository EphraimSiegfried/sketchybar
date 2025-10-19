#!/usr/bin/env lua

local colors = require("colors")
local icons = require("icons")
local make_popup = require("items.control_center.popup")

local disk = sbar.add("item", "disk", {
  icon = {
    string = icons.stats.disk,
    color = colors.blue,
  },
  update_freq = 2,
  position = "right",
  popup = {
    align = "right",
  },
})

disk:subscribe("system_stats", function(env)
  local _, _, num = string.find(env.DISK_USAGE, "(%d*)")
  local load = tonumber(num)

  local color = colors.text
  if load < 60 then
    color = colors.white
  elseif load < 80 then
    color = colors.orange
  else
    color = colors.red
  end

  disk:set({
    label = {
      string = env.DISK_USAGE,
      color = color,
    },
  })
end)

popup_items = {
  { name = "Total", env_name = "DISK_TOTAL" },
  { name = "Used", env_name = "DISK_USED" },
}
make_popup(disk, popup_items)

return disk
