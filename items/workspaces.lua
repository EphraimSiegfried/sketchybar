local colors = require("colors")
local settings = require("settings")
local app_icons = require("app_icons")
local sbar = require("sketchybar")
require("utils")

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "change_window_workspace")

local workspaces = {} -- workspaces[wid] = space item
local monitor_workspaces = {} -- monitor_workspaces[mid] = sorted list of wids

-- Function to execute shell commands and return the output
local function execute_command(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end

local function set_visible(wid, is_visible)
  if not workspaces[wid] then return end
  workspaces[wid]:set({ label = { drawing = is_visible }, icon = { drawing = is_visible } })
end

-- Show workspaces 1..max(focused, highest_with_windows) per monitor
local function refresh_visibility()
  sbar.exec("aerospace list-windows --format %{workspace} --all", function(output)
    local occupied = {}
    for ws in output:gmatch("%S+") do
      occupied[tonumber(ws)] = true
    end
    sbar.exec("aerospace list-workspaces --focused", function(focused)
      local fid = tonumber(focused)
      for mid, wids in pairs(monitor_workspaces) do
        local max_visible = 0
        for _, wid in ipairs(wids) do
          if occupied[wid] or wid == fid then
            max_visible = math.max(max_visible, wid)
          end
        end
        for _, wid in ipairs(wids) do
          set_visible(wid, wid <= max_visible)
        end
      end
    end)
  end)
end

local function set_icon_line(wid)
  if wid == nil or not workspaces[wid] then
    return
  end
  sbar.exec(
    [[aerospace list-windows --workspace ]] .. tostring(wid) .. [[ | awk -F '|' '{print $2}']],
    function(appNames)
      local icon_line = ""
      for appName in string.gmatch(appNames, "[^\r\n]+") do
        local trimmed = appName:match("^%s*(.-)%s*$")
        local lookup = app_icons[trimmed]
        local icon = ((lookup == nil) and app_icons["Default"] or lookup)
        icon_line = icon_line .. icon
      end
      sbar.animate("tanh", 10, function()
        workspaces[wid]:set({ label = icon_line })
      end)
    end
  )
end

local function refresh_all()
  refresh_visibility()
  for wid, _ in pairs(workspaces) do
    set_icon_line(wid)
  end
  sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
    local focused_id = tonumber(focused_workspace)
    if not focused_id then return end
    for wid, space in pairs(workspaces) do
      local selected = focused_id == wid
      space:set({
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { border_color = selected and colors.black or colors.bg2 },
      })
    end
  end)
end

-- Get workspace-to-monitor mapping from aerospace
local ws_monitor_output = execute_command("aerospace list-workspaces --monitor all --format '%{workspace} %{monitor-id}'")
for line in ws_monitor_output:gmatch("[^\r\n]+") do
  local wid_str, mid_str = line:match("(%S+)%s+(%S+)")
  if wid_str and mid_str then
    local wid = tonumber(wid_str)
    local mid = tonumber(mid_str)

    -- Track which workspaces belong to which monitor
    if not monitor_workspaces[mid] then
      monitor_workspaces[mid] = {}
    end
    table.insert(monitor_workspaces[mid], wid)

    local item_name = "space." .. tostring(mid) .. "." .. tostring(wid)
    local space = sbar.add("space", item_name, {
      space = mid,
      display = mid,
      icon = {
        font = { family = settings.font },
        string = wid,
        padding_left = 10,
        padding_right = 8,
        color = colors.white,
        highlight_color = colors.magenta,
        drawing = false,
      },
      label = {
        padding_right = 10,
        color = colors.grey,
        highlight_color = colors.white,
        font = "sketchybar-app-font:Regular:16.0",
        y_offset = -1,
        drawing = false,
      },
      padding_right = 1,
      padding_left = 1,
      background = {
        color = colors.bar.bg,
        border_color = colors.bar.border,
        border_width = 1,
      },
      popup = { background = { border_width = 5, border_color = colors.black } },
    })

    workspaces[wid] = space

    sbar.add("space", "space.padding." .. tostring(mid) .. "." .. tostring(wid), {
      space = mid,
      width = settings.paddings,
    })

    space:subscribe({ "aerospace_workspace_change" }, function(env)
      local selected = tonumber(env.FOCUSED_WORKSPACE) == wid
      space:set({
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { border_color = selected and colors.black or colors.bg2 },
      })
    end)

    space:subscribe({ "mouse.clicked" }, function()
      sbar.exec("aerospace workspace " .. wid)
    end)

    set_icon_line(wid)
  end
end

-- Sort workspace lists per monitor
for mid, wids in pairs(monitor_workspaces) do
  table.sort(wids)
end

refresh_visibility()

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

space_window_observer:subscribe({ "space_windows_change" }, function()
  refresh_all()
end)

-- Re-sync everything on app focus change as a safety net
space_window_observer:subscribe({ "front_app_switched" }, function()
  refresh_all()
end)

space_window_observer:subscribe({ "change_window_workspace" }, function(env)
  set_icon_line(tonumber(env.FOCUSED_WORKSPACE))
  set_icon_line(tonumber(env.TARGET_WORKSPACE))
  refresh_visibility()
end)

space_window_observer:subscribe({ "system_woke" }, function()
  sbar.exec("sketchybar --reload")
end)

space_window_observer:subscribe({ "aerospace_workspace_change" }, function()
  refresh_all()
end)
