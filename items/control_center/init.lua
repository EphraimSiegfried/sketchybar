local colors = require("colors")

-- require order determines ui order on bar
local volume = require("items.control_center.volume")
local battery = require("items.control_center.battery")
local wifi = require("items.control_center.wifi")
-- local bluetooth = require("items.control_center.bluetooth")

local items = {
	wifi.name,
	-- bluetooth.name,
	battery.name,
	volume.icon.name,
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
