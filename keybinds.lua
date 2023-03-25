_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

----------------------------------
-- Imports and Globals
----------------------------------

-- Windower Libraries
require('logger')
require('tables')
require('strings')

multibox = true
----------------------------------
-- Keybinds
----------------------------------

windower.register_event('load', function()
   windower.send_command("bind ~numpad7 send @all kb mount")
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad3 kb warp")
   windower.send_command("bind delete send skookum /ma 'cure' picklepants")
   windower.send_command("bind home send skookum /attack <t>")
end)

----------------------------------
-- Command Switch
----------------------------------

windower.register_event('addon command', function(command, ...)
   local args = table.concat({...}, " ")
   local cmd = command and command:lower()

   if cmd == 'mount' then
      mount()

   elseif cmd == 'warp' then
      warp()

   elseif cmd == 'mb' or cmd == 'multibox' then
      toggle_multibox(args)
   end

end)

----------------------------------
-- Utility
----------------------------------

function toggle_multibox(toggle)
   if toggle == 'on' then
      multibox = true
      log('Multiboxing mode enabled')
   elseif toggle == 'off' then
      multibox = false
      log('Multiboxing mode disabled')
   elseif toggle == '' then
      multibox = not multibox
      if multibox == true then
         log('Multiboxing mode enabled')
      else
         log('Multiboxing mode disabled')
      end
   else
      log('You must enter either "on" or "off" ')
   end

   if multibox == true then
      -- Keybinds for Multibox Mode
      windower.send_command("bind ~numpad7 send @all kb mount")
      windower.send_command("bind ~numpad3 send @all kb warp")
      windower.send_command("bind delete send skookum /ma 'cure' picklepants")
      windower.send_command("bind home send skookum /attack <t>")
   else
      -- Keybinds for Solo Mode
      windower.send_command("bind ~numpad7 kb mount")
      windower.send_command("bind ~numpad3 kb warp")
      windower.send_command("unbind delete")
      windower.send_command("unbind home")
   end
end

----------------------------------
-- Utility
----------------------------------

function warp()
   local equipment = windower.ffxi.get_items('equipment')
   local bag = equipment['right_ring_bag']
   local index = equipment['right_ring']
   local item_data = windower.ffxi.get_items(bag, index)

   if item_data.id == 28540 then
      windower.send_command("input /item 'warp ring' <me>")
   else
      windower.send_command("input /equip ring2 'warp ring'; wait 11; input /item 'warp ring' <me>")
   end   
end

function mount()
   local player = windower.ffxi.get_player()
   local mounted = false

   for _, buff in pairs(player.buffs) do
      if buff == 252 then
         mounted = true
      end
   end

   if mounted then
      windower.send_command('input /dismount')
   else   
      windower.send_command('input /mount raptor')
   end
end