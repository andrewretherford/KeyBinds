_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

-- Windower Libraries
require('logger')
require('tables')
require('strings')
config = require('config')

-- Default Settings

local defaults = {
   t1 = 'None',
   t2 = 'None',
   t3 = 'None',
   t4 = 'None',
   t5 = 'None'
}

settings = config.load(defaults)
settings:save()

-- Keybinds
windower.register_event('load', function()
   windower.send_command('bind ~1 kb mount')
   windower.send_command('bind ~2 kb trusts')
   windower.send_command('bind ~3 kb warp')
end)

windower.register_event('addon command', function(command, ...)
   local arg = (...) and (...):lower()
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

   elseif command == 'addtr' then
      add_trust(args[1], args[2])

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
   log('Trust 1: '..settings.t1)
   log('Trust 2: '..settings.t2)
   log('Trust 3: '..settings.t3)
   log('Trust 4: '..settings.t4)
   log('Trust 5: '..settings.t5)
end

function add_trust(name, slot)
   settings.trusts['trust'..slot] = name
   settings:save()
end