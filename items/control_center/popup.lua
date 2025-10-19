function make_popup(main_module, items)
  local popup_width = 250
  for _, item in ipairs(items) do
    local popup_item = sbar.add("item", item.name, {
      position = "popup." .. main_module.name,
      icon = {
        align = "left",
        string = item.name .. ":",
        width = popup_width / 2,
      },
      label = {
        string = "????????????",
        width = popup_width / 2,
        align = "right",
      },
    })
    popup_item:subscribe("system_stats", function(env)
      local value = env[item.env_name]
      popup_item:set({
        label = {
          string = value,
        },
      })
    end)
  end
  main_module:subscribe({ "mouse.entered" }, function(_)
    main_module:set({ popup = { drawing = true } })
  end)
  main_module:subscribe({
    "mouse.exited",
    "mouse.exited.global",
  }, function(_)
    main_module:set({ popup = { drawing = false } })
  end)
end

return make_popup
