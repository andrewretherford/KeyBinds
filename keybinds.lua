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

-- Resource Imports

require('helper_functions')
require('data')

-- Default Settings

local defaults = {
   trusts = {}
}

defaults.trusts[1] = 'None'
defaults.trusts[2] = 'None'
defaults.trusts[3] = 'None'
defaults.trusts[4] = 'None'
defaults.trusts[5] = 'None'

settings = config.load(defaults)
settings:save()

-- Keybinds
windower.register_event('load', function()
   windower.send_command('bind ~1 send all //kb mount')
   windower.send_command('bind ~2 kb summon_trusts')
   windower.send_command('bind ~3 kb warp')
end)

windower.register_event('addon command', function(command, ...)
   local args = {...}
   local cmd = command and command:lower()

   if cmd == 'mount' then
      mount()

   elseif cmd == 'st' or cmd == 'showtrust' then
      show_trusts()

   elseif cmd == 'at' or cmd == 'addtrust' then
      local slot = args[3] or nil
      local name = string.gsub(string.lower(table.concat(args, ' ')), "%s%d", "")
      -- log(name, slot)
      add_trust(name, slot)
      
   elseif cmd == 'rt' or cmd == 'replacetrust' then
      log(slot)
      -- remove_trust(slot)

   elseif cmd == 'summon_trusts' then
      summon_trusts()

   elseif cmd == 'warp' then
      warp()
   end

end)

-- Mount Function

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

-- Trust Functions

function show_trusts()
   log('Trusts:')

   for i=1,5 do
      log('Trust '..i..': '..settings.trusts[i])
   end
end

function add_trust(name, slot)
   slot = tonumber(slot)

   if not name then
      log('Correct syntax is //kb addtrust "<name of trust>" <slot number>\nExample: //kb addtrust "Tenzen" 1')
      return
   elseif slot <1 or slot > 5 then
      log('Enter a valid slot number (1-5)')
      return
   end
   
   settings.trusts[slot] = name
   settings:save()

   show_trusts()
end

function remove_trust(slot)
   if slot <1 or slot > 5 then
      log('Enter a valid slot number (1-5)')
      return
   end

   settings[slot] = 'None'
   settings:save()

   show_trusts()
end

function summon_trusts()
   local trust_list = ''

   for i=1,5 do
      if settings.trusts[i] ~= 'None' then
         trust_list = trust_list..'input /ma "'..settings.trusts[i]..'" <me>; wait 6;'
      end
   end

   windower.send_command(trust_list)
end

-- Warp Function

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