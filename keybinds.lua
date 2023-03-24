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

settings = config.load(defaults)
settings:save()

-- Keybinds
windower.register_event('load', function()
   windower.send_command('bind ~1 send all //kb mount')
   windower.send_command('bind ~2 kb summon_trusts')
   windower.send_command('bind ~3 kb warp')
end)

windower.register_event('addon command', function(command, ...)
   local args = table.concat({...}, " ")
   local cmd = command and command:lower()

   if cmd == 'mount' then
      mount()

   elseif cmd == 'ds' or cmd == 'displaysets' then
      display_sets()

   elseif cmd == 'ss' or cmd == 'saveset' then
      save_set(args)
      
   elseif cmd == 'rs' or cmd == 'removeset' then
      remove_set(args)

   elseif cmd == 'summon_trusts' then
      summon_trusts(args)

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

function display_sets()
   if next(settings.trusts) == nil then
      log('You have no saved sets.')
      return
   end
   
   log('Trust sets:')

   for k,v in pairs(settings.trusts) do
      if v then
         local name = k:gsub('_', ' ')
         log(name)
      end
   end
end

function save_set(set_name)
   local party = windower.ffxi.get_party()

   if party['p1'] == nil then
      log('You have no summoned trusts to save.')
      return
   end
   
   saved_name = set_name:gsub('%s', '_')
   settings.trusts[saved_name] = {}
   
   for i=1, 5 do
      if party['p'..i] then
         if party['p'..i].mob.is_npc then
            settings.trusts[saved_name][i] = trusts:with('models', party['p'..i].mob.models[1]).english
            log(trusts:with('models', party['p'..i].mob.models[1]).english)
         end
      end
   end

   settings:save('all')
   log('Trust set "'..set_name..'" saved.')
end

function remove_set(set_name)
   saved_name = set_name:gsub('%s', '_')

   if settings.trusts[saved_name] then
      settings.trusts = delete_element(settings.trusts, saved_name)
      settings:save('all')
      log("Set "..set_name.." has been removed.")
   else
      log("That set doesn't exist.")
   end
end

function summon_trusts(set_name)
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