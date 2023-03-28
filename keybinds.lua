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
   command = command and command:lower()
   local args = table.concat({...}, " ")

   if command == 'mb' or command == 'multibox' then
      toggle_multibox(args)
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

function multibox_binds()
   ------------------------------------
   -- Numpad
   ------------------------------------
   windower.send_command("bind ~numpad7 send @all ub mount")
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad3 send @all ub warp")

   ------------------------------------
   -- Insert Block
   ------------------------------------
   windower.send_command("bind home send skookum ub follow")
   windower.send_command("bind ~home send skookum /heal")
   windower.send_command("bind ^home send skookum ub consumables")
   -- windower.send_command("bind !home ")
   windower.send_command("bind pageup send skookum /ja 'elemental seal' <me>")
   windower.send_command("bind ~pageup send skookum /ja 'divine seal' <me>")
   windower.send_command("bind ^pageup ")
   -- windower.send_command("bind !pageup ")
   windower.send_command("bind delete send skookum /ma curaga <me>")
   windower.send_command("bind ~delete ")
   windower.send_command("bind ^delete ")
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

   windower.send_command("bind [ ub nuke skookum stone II")
   windower.send_command("bind ~[ ub nuke skookum water II")
   windower.send_command("bind ^[ ub nuke skookum aero II")
   -- windower.send_command("bind ![ ub nuke skookum ")
   windower.send_command("bind ] ub nuke skookum fire")
   windower.send_command("bind ~] ub nuke skookum blizzard")
   windower.send_command("bind ^] ub nuke skookum thunder")
   -- windower.send_command("bind !] ")
   windower.send_command("bind f11 ub nuke skookum dia")
   -- windower.send_command("bind ~f11 ")
   -- windower.send_command("bind ^f11 ")
   windower.send_command("bind !f11 send skookum /ma protectra <me>; wait 4; send skookum /ma shellra <me>; wait 4; send skookum /ma aquaveil <me>; wait 10; send skookum /ma blink <me>")
   windower.send_command("bind f12 ub nuke skookum burn; wait 6; ub nuke skookum dia; wait 4; ub nuke skookum bio II")
   -- windower.send_command("bind ~f12 ")
   -- windower.send_command("bind ^f12 ")
   -- windower.send_command("bind !f12 ")
end

function solo_binds()
   windower.send_command("bind ~numpad7 ub mount")
   windower.send_command("bind ~numpad3 ub warp")
   windower.send_command("unbind delete")
   windower.send_command("unbind home")
   windower.send_command("unbind end")
end