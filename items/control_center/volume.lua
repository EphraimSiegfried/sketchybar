local colors = require("colors")
local icons = require("icons")


local volume = {}

volume.slider = sbar.add("slider", "volume.slider", 100, {
	position = "right",
	updates = true,
	label = { drawing = false },
	icon = { drawing = false },
	slider = {
		highlight_color = colors.blue,
		width = 0,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = false,
		},
	},
})

volume.icon = sbar.add("item", "volume.icon", {
	position = "right",
	icon = {
		string = icons.volume._100,
		align = "right",
		font = {
			style = "Regular",
			size = 14.0,
		},
	},
	label = {
		align = "left",
		font = {
			style = "Regular",
			size = 14.0,
		},
	},
})

volume.slider:subscribe("mouse.clicked", function(env)
	sbar.exec("osascript -e 'set volume output volume " .. env["PERCENTAGE"] .. "'")
end)

volume.slider:subscribe("volume_change", function(env)
	local new_volume = tonumber(env.INFO)
	local icon = icons.volume._0

	if new_volume > 60 then
		icon = icons.volume._100
	elseif new_volume > 30 then
		icon = icons.volume._66
	elseif new_volume > 10 then
		icon = icons.volume._33
	elseif new_volume > 0 then
		icon = icons.volume._10
	end

	volume.icon:set({ label = new_volume })
	volume.icon:set({ icon = icon })
	volume.slider:set({ slider = { percentage = new_volume } })
end)

local function animate_slider_width(width)
	sbar.animate("tanh", 30.0, function()
		volume.slider:set({ slider = { width = width } })
	end)
end

volume.icon:subscribe("mouse.clicked", function()
	if tonumber(volume.slider:query().slider.width) > 0 then
		animate_slider_width(0)
	else
		animate_slider_width(100)
	end
end)

return volume
