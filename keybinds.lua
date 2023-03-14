_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

-- Windower Libraries
require('logger')
require('tables')
config = require('config')

-- Initial Settings

local defaults = {
   trusts = {
      t1 = 'None', 
      t2 = 'None', 
      t3 = 'None', 
      t4 = 'None', 
      t5 = 'None',
   },
}

settings = config.load(defaults)
settings:save()

-- Keybinds
windower.register_event('load', function()
   windower.send_command('bind ~1 kb mount')
   windower.send_command('bind ~2 kb trusts')
   windower.send_command('bind ~3 kb warp')
end)

windower.register_event('addon command', function(command,...)
   command = command and command:lower()

   if command == 'mount' then
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

   elseif command == 'showtr' then
      show_trusts()

   elseif command == 'warp' then
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

   
end)

-- Trust Functions

function show_trusts()
   local i = 1
   for trust in pairs(settings.trusts) do
      log('Trust ', i, trust)
      i = i + 1
   end
end