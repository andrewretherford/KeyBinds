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
res = require('resources')


local defaults = {
   multibox = true,
   weaponskill = {}
}

settings = config.load(defaults)
settings:save('all')

-- General Trackers
attacking = false

----------------------------------
-- Keybinds
----------------------------------

windower.register_event('load', function()
   if settings.multibox then
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

   elseif command == 'sws' or command == 'setws' then
      set_weaponskill({...})

   elseif command == 'attack' then
      attack_toggle()

   elseif command == 'follow' then
      follow_toggle()

   elseif command == 'heal' then
      heal({...})

   elseif command == 'nuke' then
      nuke({...})
      
   elseif command == 'decurse' then
      decurse()

   end

end)

----------------------------------
-- Utility
----------------------------------

function toggle_multibox(toggle)
   if toggle == 'on' then
      settings.multibox = true
      log('Multiboxing mode enabled')
   elseif toggle == 'off' then
      settings.multibox = false
      log('Multiboxing mode disabled')
   elseif toggle == '' then
      settings.multibox = not settings.multibox
      if settings.multibox == true then
         log('Multiboxing mode enabled')
      else
         log('Multiboxing mode disabled')
      end
   else
      log('You must enter either "on" or "off" ')
   end
   
   settings:save('all')

   if settings.multibox == true then
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

function set_weaponskill(args)
   local name = args[1]
   local skill = (table.concat(args, ' ')):gsub(name..' ', '')

   settings.weaponskill[name] = skill
   settings:save('all')
   if settings.multibox then multibox_binds() end
   log(skill..' has been saved for '..name)
end

function attack_toggle()
      attacking = true
      windower.send_command("send picklepants /attack; wait 1; send @others /assist picklepants; wait 2; send @others /attack; wait 1; send @others /follow picklepants")
end

function follow_toggle()
   local following = windower.ffxi.get_player().follow_index

   if not following then
      windower.send_command("input /follow picklepants")
   else
      windower.send_command("setkey numpad7 down; wait 0.1; setkey numpad7 up")
   end
end

function get_target(type)
   local target = windower.ffxi.get_mob_by_target(type)

   if not target then
      log('No target - cancelling operation')
      return false
   end

   return target
end

function heal(args)
   local target = get_target('lastst')
   if not target then return end

   windower.send_command("send "..table.concat(args, " ").." "..target.name)
end

function nuke(args)
   local target = get_target('t')
   if not target then return end

   windower.send_command("send skookum /p Casting "..args[2].." on "..target.name)
   windower.send_command("send "..table.concat(args, " ").." "..target.id)
end

function decurse()
   local buffs = T(windower.ffxi.get_player().buffs)
   local target = get_target('lastst')
   if not target then return end

   local dispel_priority = T{
      [4] = 'paralyna',
      [5] = 'blindna',
      [6] = 'silena',
      [3] = 'poisona'
   }

   local dispel = flase
   for _,v in pairs(buffs) do
      if dispel_priority[v] then
         dispel = dispel_priority[v]
      end
   end
  
   if dispel then
      windower.send_command("send skookum /p Casting "..dispel.." on "..target.name)
      windower.send_command("send skookum /ma "..dispel.." "..target.name)
      return
   end

   windower.send_command("send skookum /p Nothing to dispel")
end

function multibox_binds()
   ------------------------------------
   -- Numpad
   ------------------------------------
   windower.send_command("bind ~numpad7 send @all kb mount")
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad3 send @all kb warp")

   ------------------------------------
   -- Insert Block
   ------------------------------------
   windower.send_command("bind home send skookum kb follow")
   windower.send_command("bind ~home send skookum /ma protectra <me>; wait 4; send skookum /ma shellra <me>")
   -- windower.send_command("bind ^home ")
   -- windower.send_command("bind !home ")
   windower.send_command("bind pageup send skookum /ma 'blindna' picklepants")
   windower.send_command("bind ~pageup send skookum /ma 'paralyna' picklepants")
   windower.send_command("bind ^pageup send skookum /ma 'poisona' picklepants")
   -- windower.send_command("bind !pageup ")
   windower.send_command("bind delete send skookum /ma 'cure II' picklepants")
   windower.send_command("bind ~delete send skookum /ma 'cure II' skookum")
   windower.send_command("bind ^delete send skookum /ma 'curaga' skookum")
   -- windower.send_command("bind !delete ")
   -- windower.send_command("bind ~end kb nuke skookum dia")
   -- windower.send_command("bind ~end ")
   -- windower.send_command("bind ^end ")
   -- windower.send_command("bind !end ")
   -- windower.send_command("bind pagedown ")
   -- windower.send_command("bind ~pagedown ")
   -- windower.send_command("bind ^pagedown ")
   -- windower.send_command("bind !pagedown ")
   
   ------------------------------------
   -- Thumbstick
   ------------------------------------
   -- Physical attack binds
   -- windower.send_command("bind [ send skookum /ws "..settings.weaponskill.skookum.." <t>; send skookum /p Using "..settings.weaponskill.skookum.."!")
   -- windower.send_command("bind ] kb attack")

   windower.send_command("bind [ kb nuke skookum stone")
   windower.send_command("bind ~[ kb nuke skookum water")
   windower.send_command("bind ^[ kb nuke skookum aero")
   -- windower.send_command("bind ![ kb nuke skookum ")
   windower.send_command("bind ] kb nuke skookum fire")
   windower.send_command("bind ~] kb nuke skookum blizzard")
   windower.send_command("bind ^] kb nuke skookum thunder")
   -- windower.send_command("bind !] ")
   windower.send_command("bind f11 kb nuke skookum dia")
   -- windower.send_command("bind ~f11 ")
   -- windower.send_command("bind ^f11 ")
   windower.send_command("bind !f11 send skookum /ma protectra <me>; wait 3; send skookum /ma shellra <me>; wait 3; send skookum /ma aquaveil <me>; wait 10; send skookum /ma blink <me>")
   windower.send_command("bind f12 kb nuke skookum burn; wait 3; kb nuke skookum dia; wait 3; kb nuke skookum blind; wait 3; kb nuke skookum bio; wait 3; kb nuke skookum poison")
   -- windower.send_command("bind ~f12 ")
   -- windower.send_command("bind ^f12 ")
   -- windower.send_command("bind !f12 ")
end

function solo_binds()
   windower.send_command("bind ~numpad7 kb mount")
   windower.send_command("bind ~numpad3 kb warp")
   windower.send_command("unbind delete")
   windower.send_command("unbind home")
   windower.send_command("unbind end")
end