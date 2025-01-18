local cal = sbar.add("item", {
	icon = {
		font = {
			style = "Black",
			size = 14.0,
		},
	},
	label = {
		align = "right",
	},
	position = "right",
	update_freq = 15,
})

local function update()
	local date = os.date("%a. %d %b.")
	local time = os.date("%H:%M")
	cal:set({ icon = date, label = time })
end

cal:subscribe("routine", update)
cal:subscribe("forced", update)
return cal
