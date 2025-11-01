-- Do NOT touch 'global' at file scope. Only inside events.

-- Ensure our persistent table exists when the mod (or save) loads.
local function ensure_globals()
  if not global then return end           -- guard: in case on_load fires before init
  global.recycler_modes = global.recycler_modes or {}
end

script.on_init(function()
  ensure_globals()
end)

script.on_configuration_changed(function()
  ensure_globals()
end)

-- GUI helper
local function update_button(player, unit_number)
  local button = player.gui.relative.recyc_toggle
  if not button then return end
  local mode = global.recycler_modes and global.recycler_modes[unit_number]
  button.caption = (mode == "destroy") and "🔥 Destroy" or "🔁 Recycle"
end

-- When player opens a recycler, add toggle button
script.on_event(defines.events.on_gui_opened, function(event)
  if not (event.entity and event.entity.valid and event.entity.name == "recycler") then return end
  local player = game.get_player(event.player_index)
  if not player then return end

  local parent = player.gui.relative
  if parent.recyc_toggle then parent.recyc_toggle.destroy() end

  local button = parent.add{
    type = "button",
    name = "recyc_toggle",
    caption = "🔁 Recycle",
    anchor = {
      gui = defines.relative_gui_type.assembling_machine_gui,
      position = defines.relative_gui_position.top_left
    }
  }

  button.tags = { unit = event.entity.unit_number }
  update_button(player, event.entity.unit_number)
end)

-- Button click handler
script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not (element and element.valid and element.name == "recyc_toggle") then return end
  local unit = element.tags.unit
  if not unit then return end

  global.recycler_modes = global.recycler_modes or {}
  local current = global.recycler_modes[unit]
  global.recycler_modes[unit] = (current == "destroy") and "recycle" or "destroy"

  local player = game.get_player(event.player_index)
  if player then update_button(player, unit) end
end)

-- Every second, clear outputs for recyclers in destroy mode
script.on_nth_tick(60, function()
  if not global.recycler_modes then return end
  for _, surface in pairs(game.surfaces) do
    for _, r in pairs(surface.find_entities_filtered{name = "recycler"}) do
      if global.recycler_modes[r.unit_number] == "destroy" then
        local out = r.get_output_inventory()
        if out and not out.is_empty() then out.clear() end
      end
    end
  end
end)
