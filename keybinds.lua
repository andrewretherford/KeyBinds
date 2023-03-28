_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

----------------------------------------------------------------------------------------------------
-- Imports and Globals
----------------------------------------------------------------------------------------------------

-- Windower Libraries
require('logger')
require('tables')
require('strings')
require('functions')
config = require('config')
res = require('resources')

-- Local Imports
require('helper_functions')
require('data')

-- Default Settings
local defaults = {
   multibox = true,
   active_key_set = '',
   key_sets = T{},
}

settings = config.load(defaults)
settings:save('all')

----------------------------------------------------------------------------------------------------
-- Addon Events
----------------------------------------------------------------------------------------------------

windower.register_event('load', function()
   if settings.multibox then
      multibox_binds()
   else
      solo_binds()
   end
end)

windower.register_event('unload', function()
   unbind_all()
end)

----------------------------------------------------------------------------------------------------
-- Command Switch
----------------------------------------------------------------------------------------------------

windower.register_event('addon command', function(command, ...)
   command = command and command:lower()
   local argstring = table.concat({...}, ' '):lower()
   -- log(argstring)

   if command == 'mb' or command == 'multibox' then
      toggle_multibox(argstring)
   elseif command == 'dis' or command == 'display' then
      display_set(argstring)
   elseif command == 'add' or command == 'addset' then
      add_set(argstring)
   elseif command == 'rem' or command == 'removeset' then
      remove_set(argstring)
   elseif command == 'active' or command == 'setactive' then
      set_active_set(argstring)
   elseif command == 'bind' then
      bind({...})
   -- elseif command == 'test' then
   --    function test()
   --       return 'one', 'two'
   --    end
   --    local a,b = test()
   --    log(a,b)
   end

end)

----------------------------------------------------------------------------------------------------
-- Core Functions
----------------------------------------------------------------------------------------------------

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
   load_binds()
end

function display_set(set_name)
   if set_name == '' then     -- Displays all set names if no name is given
      if settings.key_sets:length() < 1 then
         log('No saved sets')
      else
         log('Saved key sets:')
         for k,_ in pairs(settings.key_sets) do
            log(display_name_format(k))
         end
      end

      if settings.active_key_set ~= '' then
         log(display_name_format(settings.active_key_set)..' is currently active')
      else
         log('No sets are currently active')
      end
   else                       -- Displays all keybinds in the given set
      if settings.key_sets:containskey(save_name_format(set_name)) then
         log(set_name)
         if settings.key_sets[save_name_format(set_name)]:length() > 0 then
            for k,v in pairs(settings.key_sets[save_name_format(set_name)]) do
               log(display_name_format(k), v)
            end
         else
            log('This set is empty')
         end
      else
         log(set_name..' did not match any saved sets')
      end
   end
end

function add_set(set_name)
   if set_name == '' then
      log('Please enter a name for the new set')
      return
   end

   settings.key_sets[save_name_format(set_name)] = {}
   settings:save('all')
   log(set_name..' has been created')
end

function remove_set(set_name)
   if set_name == '' then
      log('Please enter the name of the set to be removed')
      return
   end

   if settings.key_sets:containskey(save_name_format(set_name)) then
      settings.key_sets = remove(settings.key_sets, save_name_format(set_name))
      settings:save('all')
      log(set_name..' has been removed')
   else
      log(set_name..' did not match any saved sets')
   end
end

function set_active_set(set_name)
   if not settings.key_sets[save_name_format(set_name)] then
      log("That set does not exist yet, but you can create it with 'kb addset <set name>'")
      return
   end

   settings.active_key_set = save_name_format(set_name)
   settings:save('all')
   log(set_name..' is now the active set')
   load_binds()
end

function bind(args)
   if settings.active_key_set == '' then          -- Check that a key set is active
      log("Please set an active key set with 'kb activeset <set name>' before binding keys")
      return
   end

   if #args < 2 then                              -- Check for minimum number of arguments
      log("Invalid entry, please use format 'kb [modifier] <key> <action>' with modifier being optional")
      return
   end

   args = T(args)
   args = args:map(string.lower)

   local key, action = get_key_and_action(args)

   if validate_key(key) then
      settings.key_sets[settings.active_key_set][save_name_format(key)] = action
      settings:save('all')
      windower.send_command("unbind "..send_keybind_format(key).."; wait 0.5; bind "..send_keybind_format(key).." "..action)
      log(key..' has been bound to '..action)
   else
      log('Key entered is invalid, please verify and try again')
      return
   end
end

function unbind(args)

end

function multibox_binds()
   if settings.active_key_set == '' then return end

   if settings.key_sets[settings.active_key_set] then
      for k,v in pairs(settings.key_sets[settings.active_key_set]) do
         windower.send_command("bind "..k..' '..v)
      end
   end

   -------------------------------------------------------------------------------------------------
   -- Numpad
   -------------------------------------------------------------------------------------------------
   -- windower.send_command("bind ~numpad7 send @all ub mount")
   -- windower.send_command("bind ~numpad9 tm summontrusts")
   -- windower.send_command("bind ~numpad3 send @all ub warp")

   -- -------------------------------------------------------------------------------------------------
   -- -- Insert Block
   -- -------------------------------------------------------------------------------------------------
   -- windower.send_command("bind home send skookum ub follow")
   -- windower.send_command("bind ~home send skookum /heal")
   -- windower.send_command("bind ^home send skookum ub consumables")
   -- -- windower.send_command("bind !home ")
   -- windower.send_command("bind pageup send skookum /ja 'elemental seal' <me>")
   -- windower.send_command("bind ~pageup send skookum /ja 'divine seal' <me>")
   -- windower.send_command("bind ^pageup ")
   -- -- windower.send_command("bind !pageup ")
   -- windower.send_command("bind delete send skookum /ma curaga <me>")
   -- windower.send_command("bind ~delete ")
   -- windower.send_command("bind ^delete ")
   -- -- windower.send_command("bind !delete ")
   -- -- windower.send_command("bind ~end kb nuke skookum dia")
   -- -- windower.send_command("bind ~end ")
   -- -- windower.send_command("bind ^end ")
   -- -- windower.send_command("bind !end ")
   -- -- windower.send_command("bind pagedown ")
   -- -- windower.send_command("bind ~pagedown ")
   -- -- windower.send_command("bind ^pagedown ")
   -- -- windower.send_command("bind !pagedown ")
   
   -- -------------------------------------------------------------------------------------------------
   -- -- Thumbstick
   -- -------------------------------------------------------------------------------------------------
   -- -- Physical attack binds
   -- -- windower.send_command("bind [ send skookum /ws "..settings.weaponskill.skookum.." <t>; send skookum /p Using "..settings.weaponskill.skookum.."!")
   -- -- windower.send_command("bind ] kb attack")

   -- windower.send_command("bind [ ub nuke skookum stone II")
   -- windower.send_command("bind ~[ ub nuke skookum water II")
   -- windower.send_command("bind ^[ ub nuke skookum aero II")
   -- -- windower.send_command("bind ![ ub nuke skookum ")
   -- windower.send_command("bind ] ub nuke skookum fire")
   -- windower.send_command("bind ~] ub nuke skookum blizzard")
   -- windower.send_command("bind ^] ub nuke skookum thunder")
   -- -- windower.send_command("bind !] ")
   -- windower.send_command("bind f11 ub nuke skookum dia")
   -- -- windower.send_command("bind ~f11 ")
   -- -- windower.send_command("bind ^f11 ")
   -- windower.send_command("bind !f11 send skookum /ma protectra <me>; wait 4; send skookum /ma shellra <me>; wait 4; send skookum /ma aquaveil <me>; wait 10; send skookum /ma blink <me>")
   -- windower.send_command("bind f12 ub nuke skookum burn; wait 6; ub nuke skookum dia; wait 4; ub nuke skookum bio II")
   -- -- windower.send_command("bind ~f12 ")
   -- -- windower.send_command("bind ^f12 ")
   -- -- windower.send_command("bind !f12 ")
end

function solo_binds()
   windower.send_command("bind ~numpad7 ub mount")
   windower.send_command("bind ~numpad3 ub warp")
   -- windower.send_command("unbind delete")
   -- windower.send_command("unbind home")
   -- windower.send_command("unbind end")
end