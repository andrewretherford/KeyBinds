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
config = require('config')


local defaults = {
   multibox = true,
   weaponskill = {}
}

settings = config.load(defaults)
settings:save('all')

----------------------------------
-- Keybinds
----------------------------------

windower.register_event('load', function()
   if multibox then
      multibox_binds()
   else
      solo_binds()
   end
end)

----------------------------------
-- Command Switch
----------------------------------

windower.register_event('addon command', function(command, ...)
   local args = table.concat({...}, " ")
   command = command and command:lower()

   if command == 'mount' then
      mount()

   elseif command == 'warp' then
      warp()

   elseif command == 'mb' or command == 'multibox' then
      toggle_multibox(args)

   elseif command == 'attack' then
      attack_target()

   elseif command == 'sws' or command == 'setws' then
      set_weaponskill({...})
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
      multibox_binds()
   else
      solo_binds()
   end
end

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

function attack_target()
   windower.send_command("send picklepants /attack; wait 1; send @others /assist picklepants; wait 2; send @others /attack")
end

function set_weaponskill(args)
   local name = args[1]
   local skill = (table.concat(args, ' ')):gsub(name..' ', '')

   settings.weaponskill[name] = skill
   settings:save('all')
   log(skill..' has been saved for '..name)
end

function multibox_binds()
   windower.send_command("bind ~numpad7 send @all kb mount")
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad3 kb warp")
   windower.send_command("bind delete send skookum /ma 'cure' picklepants")
   windower.send_command("bind ~delete send skookum /ma 'cure' skookum")
   windower.send_command("bind home send skookum /follow picklepants")
   windower.send_command("bind ~home kb attack")
end

function solo_binds()
   windower.send_command("bind ~numpad7 kb mount")
   windower.send_command("bind ~numpad3 kb warp")
   windower.send_command("unbind delete")
   windower.send_command("unbind home")
end