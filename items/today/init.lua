local colors = require("colors")

-- require order determines ui order on bar
local calendar = require("items.today.calendar")
local weather = require("items.today.weather")

local items = {
	calendar.name,
	weather.name
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
