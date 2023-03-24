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

----------------------------------
-- Keybinds
----------------------------------

windower.register_event('load', function()
   windower.send_command('bind ~1 send all //kb mount')
   windower.send_command('bind ~2 tm summontrusts')
   windower.send_command('bind ~3 kb warp')
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
   end

end)

----------------------------------
-- Utility
----------------------------------

function warp()
   local equipment = windower.ffxi.get_items('equipment')
   local bag = equipment['right_ring_bag']
   local index = equipment['right_ring']
   local item_data = windower.ffxi.get_items(bag, index)

   if item_data.id == 28540 then
      windower.send_command('input /item "warp ring" <me>')
   else
      windower.send_command('input /equip ring2 "warp ring"; wait 10; input /item "warp ring" <me>')
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