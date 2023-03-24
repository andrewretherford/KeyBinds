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
   windower.send_command('bind ~2 kb trusts')
   windower.send_command('bind ~3 kb warp')
end)

windower.register_event('addon command', function(command, ...)
   local cmd = command and command:lower()
   local args = {...}

   if cmd == 'mount' then
      mount()

   elseif cmd == 'st' or cmd == 'showtrust' then
      show_trusts()

   elseif cmd == 'at' or cmd == 'addtrust' then
      add_trust(unpack(args))

   elseif cmd == 'rt' or cmd == 'replacetrust' then
      remove_trust(unpack(args))

   elseif cmd == 'trusts' then
      log(summoning)
      if not summoning then
         summon_trusts()
      end

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

   -- log('Trust 1: '..settings.t1)
   -- log('Trust 2: '..settings.t2)
   -- log('Trust 3: '..settings.t3)
   -- log('Trust 4: '..settings.t4)
   -- log('Trust 5: '..settings.t5)
end

function add_trust(name, slot)
   local key, key_name = table.unpack(parse_slot(slot))

   if not name then
      log('Correct syntax is //kb addtrust "<name of trust>" <slot number>\nExample: //kb addtrust "Tenzen" 1')
      return
   elseif key == nil then
      log('Enter a valid slot number (1-5)')
      return
   end
   
   settings[key] = name
   settings:save()

   show_trusts()
end

function remove_trust(slot)
   local key, key_name = table.unpack(parse_slot(slot))

   if key == nil then
      log('Enter a valid slot number (1-5)')
      return
   end

   settings[key] = 'None'
   settings:save()

   show_trusts()
end

function summon_trusts()
   local trust_list = ''

   for key,trust in ipairs(settings) do
      if trust ~= 'None' then
         trust_list = trust_list..'input /ma "'..trust..'" <me>; wait 6;'
      end
   end
   log(trust_list)
   -- windower.send_command(trust_list)
   -- windower.send_command(
   --    'input /ma "'..settings.t1..'" <me>; wait 6; input /ma "'..settings.t2..'" <me>; wait 6; input /ma "'..settings.t3..'" <me>; wait 6; input /ma "'..settings.t4..'" <me>; wait 6; input /ma "'..settings.t5..'" <me>')
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