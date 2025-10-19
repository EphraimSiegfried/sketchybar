local colors = require("colors")

-- require order determines ui order on bar
local volume = require("items.control_center.volume")
local battery = require("items.control_center.battery")
local wifi = require("items.control_center.wifi")
-- local bluetooth = require("items.control_center.bluetooth")
-- local cpu = require("items.control_center.cpu")
-- local ram = require("items.control_center.ram")
-- local disk = require("items.control_center.disk")

local items = {
  wifi.name,
  -- bluetooth.name,
  battery.name,
  volume.icon.name,
  -- cpu.name,
  -- ram.name,
  -- disk.name,
}

sbar.add("bracket", items, {
  background = {
    color = colors.bar.bg,
    border_color = colors.bar.border,
    border_width = 2,
    padding_left = 5,
    padding_right = 10,
  },
})
