local icons = require("icons")
local settings = require("settings")
local colors = require("colors")
local percent = 0

local battery = sbar.add("item", "battery", {
	position = "right",
	click_script = "sketchybar --set $NAME popup.drawing=toggle",
	icon = {
		font = {
			family = settings.nerd_font,
			style = "Regular",
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			style = "Regular",
		},
	},
	update_freq = 30,
})


battery:subscribe({
	"routine",
	"forced",
	"power_source_change",
	"system_woke",
}, function(_)
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local color = colors.green
		local charging = string.find(batt_info, "AC Power")

		local thresholds = {
			{
				percent = 100,
				charging_icon = icons.battery.charging._100,
				non_charging_icon = icons.battery.non_charging._100,
				color = colors.green,
			},
			{
				percent = 90,
				charging_icon = icons.battery.charging._90,
				non_charging_icon = icons.battery.non_charging._90,
				color = colors.green,
			},
			{
				percent = 80,
				charging_icon = icons.battery.charging._80,
				non_charging_icon = icons.battery.non_charging._80,
				color = colors.green,
			},
			{
				percent = 70,
				charging_icon = icons.battery.charging._70,
				non_charging_icon = icons.battery.non_charging._70,
				color = colors.green,
			},
			{
				percent = 60,
				charging_icon = icons.battery.charging._60,
				non_charging_icon = icons.battery.non_charging._60,
				color = colors.yellow,
			},
			{
				percent = 50,
				charging_icon = icons.battery.charging._50,
				non_charging_icon = icons.battery.non_charging._50,
				color = colors.yellow,
			},
			{
				percent = 40,
				charging_icon = icons.battery.charging._40,
				non_charging_icon = icons.battery.non_charging._40,
				color = colors.peach,
			},
			{
				percent = 30,
				charging_icon = icons.battery.charging._30,
				non_charging_icon = icons.battery.non_charging._30,
				color = colors.peach,
			},
			{
				percent = 20,
				charging_icon = icons.battery.charging._20,
				non_charging_icon = icons.battery.non_charging._20,
				color = colors.red,
			},
			{
				percent = 10,
				charging_icon = icons.battery.charging._10,
				non_charging_icon = icons.battery.non_charging._10,
				color = colors.red,
			},
			{
				percent = 0,
				charging_icon = icons.battery.charging._0,
				non_charging_icon = icons.battery.non_charging._0,
				color = colors.red,
			},
		}

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			percent = tonumber(charge)
		end

		for _, threshold in ipairs(thresholds) do
			if percent >= threshold.percent then
				icon = charging and threshold.charging_icon or threshold.non_charging_icon
				color = threshold.color
				break
			end
		end

		battery:set({
			icon = {
				string = icon,
				color = color,
			},
			label = percent,
		})
	end)
end)

battery:subscribe({
	"mouse.exited",
	"mouse.exited.global",
}, function(_)
	battery:set({ popup = { drawing = false } })
end)


return battery
