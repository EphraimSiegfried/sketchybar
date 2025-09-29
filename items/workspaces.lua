local colors = require("colors")
local settings = require("settings")
local app_icons = require("app_icons")
local sbar = require("sketchybar")
require("utils")

sbar.add("event", "aerospace_workspace_change")

local workspaces = {}
local max_workspaces = 9

-- Function to execute shell commands and return the output
local function execute_command(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end

local function set_visible(workspace_id, is_visible)
  workspaces[workspace_id]:set({ label = { drawing = is_visible }, icon = { drawing = is_visible } })
end

-- Get monitor information

local function set_icon_line(workspace_id)
  if workspace_id == nil then
    return
  end
  sbar.exec(
    [[aerospace list-windows --workspace ]] .. tostring(workspace_id) .. [[ | awk -F '|' '{print $2}']],
    function(appNames)
      local icon_line = ""
      for appName in string.gmatch(appNames, "[^\r\n]+") do
        -- Trim leading and trailing whitespace
        appName = appName:match("^%s*(.-)%s*$")
        local lookup = app_icons[appName]
        local icon = ((lookup == nil) and app_icons["Default"] or lookup)
        icon_line = icon_line .. icon
      end
      if workspace_id == "focused" then
        sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
          for id in focused_workspace:gmatch("%S+") do
            workspaces[tonumber(id)]:set({ label = icon_line })
          end
        end)
      else
        sbar.animate("tanh", 10, function()
          workspaces[tonumber(workspace_id)]:set({ label = icon_line })
        end)
      end
    end
  )
end

-- initial run

-- Get workspaces for each monitor
local monitors = {}
local monitor_output = execute_command("aerospace list-monitors")
for line in monitor_output:gmatch("[^\r\n]+") do
  local id, name = line:match("(%d+) | (.+)")
  if id and name then
    monitors[tonumber(id)] = name
  end
end

for monitor_id, _ in pairs(monitors) do
  for workspace_id = 1, max_workspaces do
    local space = sbar.add("space", "space." .. tostring(workspace_id), {
      space = monitor_id,
      display = monitor_id,
      icon = {
        font = { family = settings.font },
        string = workspace_id,
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

    workspaces[workspace_id] = space

    -- Padding space
    sbar.add("space", "space.padding." .. tostring(workspace_id), {
      space = monitor_id,
      width = settings.paddings,
    })

    space:subscribe({ "aerospace_workspace_change" }, function(env)
      local selected = tonumber(env.FOCUSED_WORKSPACE) == workspace_id
      space:set({
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { border_color = selected and colors.black or colors.bg2 },
      })
    end)

    space:subscribe({ "mouse.clicked" }, function()
      sbar.exec("aerospace workspace " .. workspace_id)
    end)
    set_icon_line(workspace_id)
  end
end

sbar.exec("aerospace list-windows --format %{workspace} --all | sort -n | tail -n 1 ", function(max_active_window)
  for id = 1, max_active_window do
    set_visible(id, true)
  end
end)

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

space_window_observer:subscribe({ "space_windows_change" }, function()
  sbar.exec("aerospace list-workspaces --focused", function(focused_id)
    set_icon_line(tonumber(focused_id))
  end)
end)

-- TODO: fix this
-- Problem: individual spaces fail to get the aerospace_workspace_change trigger when waking up
-- Temporary fix is to just reload the whole bar
space_window_observer:subscribe({ "system_woke" }, function()
  sbar.exec("sketchybar --reload")
end)

space_window_observer:subscribe({ "aerospace_workspace_change" }, function(env)
  local focused_id = tonumber(env.FOCUSED_WORKSPACE)
  local prev_id = tonumber(env.PREV_WORKSPACE)

  if not prev_id or not focused_id or prev_id == focused_id then
    return
  end

  sbar.exec("aerospace list-windows --format %{workspace} --all | sort -n | tail -n 1 ", function(max_active_workspace)
    max_active_workspace = math.max(focused_id, tonumber(max_active_workspace))
    if prev_id > max_active_workspace then
      for id = max_active_workspace + 1, prev_id do
        set_visible(id, false)
      end
    else
      for id = prev_id, max_active_workspace do
        set_visible(id, true)
      end
    end
  end)
end)
