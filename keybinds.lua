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
require('chat')
config = require('config')
files = require('files')

-- Local Imports
require('helper_functions')
require('data')

-- Default Settings
local defaults = {
   key_color = 158,
   action_color = 166,
   active_key_set = '',
   key_sets = T{},
   multibox = true,
}

settings = config.load(defaults)
settings:save('all')

----------------------------------------------------------------------------------------------------
-- Addon Events
----------------------------------------------------------------------------------------------------

windower.register_event('load', function()
   if settings.multibox then
      load_multibox_binds()
   else
      load_solo_binds()
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

   if command == 'mb' or command == 'multibox' then
      toggle_multibox(argstring)
   elseif command == 'dis' or command == 'display' then
      display_set(argstring)
   elseif command == 'addset' then
      add_set(argstring)
   elseif command == 'rmset' or command == 'removeset' then
      remove_set(argstring)
   elseif command == 'active' or command == 'setactive' then
      set_active_set(argstring)
   elseif command == 'bind' or command == 'addbind' then
      add_bind({...})
   elseif command == 'unbind' or command == 'removebind' then
      remove_bind(argstring)
   elseif command == 'load' or command == 'loadset' then
      load_file(argstring)
   elseif command == 'test' then
      lastst = windower.ffxi.get_mob_by_target('lastst')
      log(lastst.id)
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
            windower.add_to_chat(settings.key_color, format_display_name(k))
         end
      end

      if settings.active_key_set ~= '' then
         windower.add_to_chat(settings.action_color, format_display_name(settings.active_key_set):color(settings.key_color, settings.action_color)..' is currently active')
      else
         log('No set is currently active')
      end
   else                       -- Displays all keybinds in the given set
      if settings.key_sets:containskey(format_save_name(set_name)) then
         if settings.key_sets[format_save_name(set_name)]:length() > 0 then
            for k,v in pairs(settings.key_sets[format_save_name(set_name)]) do
               -- windower.add_to_chat(settings.key_color, format_display_name(k))
               windower.add_to_chat(settings.action_color, format_display_name(k):color(settings.key_color, settings.action_color)..' '..v)
            end
         else
            log('This set is empty')
         end
      else
         windower.add_to_chat(settings.action_color, set_name:color(settings.key_color, settings.action_color)..' did not match any saved sets')
      end
   end
end

function add_set(set_name)
   if settings.key_sets[format_save_name(set_name)] then
      log('That set already exists')
      return false
   elseif set_name == '' then
      log('Please enter a name for the new set')
      return false
   elseif set_name:match('[^%w%s]') then
      log('Set names can only contain alphanumeric characters')
      return false
   end


   settings.key_sets[format_save_name(set_name)] = T{}
   settings:save('all')
   log(set_name..' has been created')
   return true
end

function remove_set(set_name)
   if set_name == '' then
      log('Please enter the name of the set to be removed')
      return
   end

   if settings.key_sets:containskey(format_save_name(set_name)) then -- Removes set if it exists
      settings.key_sets = remove(settings.key_sets, format_save_name(set_name))
      if settings.active_key_set == format_save_name(set_name) then -- Clears active set if removed
         settings.active_key_set = ''
      end
      settings:save('all')
      log(set_name..' has been removed')
   else
      log(set_name..' did not match any saved sets')
   end
end

function set_active_set(set_name)
   if not settings.key_sets[format_save_name(set_name)] then
      log("That set does not exist yet, but you can create it with 'kb addset <set name>'")
      return
   end

   settings.active_key_set = format_save_name(set_name)
   settings:save('all')
   log(set_name..' is now the active set')
   load_binds()
end

function add_bind(args)
   if settings.active_key_set == '' then          -- Check that a key set is active
      log("Please set an active key set with 'kb activeset <set name>' before binding keys")
      return false
   end

   if #args < 2 then                              -- Check for minimum number of arguments
      log("Invalid entry, please use format 'kb bind [modifier] <key> <action>' with modifier being optional")
      return false
   end

   args = T(args)
   args = args:map(string.lower)

   local key, action = get_key_and_action(args)

   if validate_key(key) then
      settings.key_sets[settings.active_key_set][format_save_name(key)] = action
      settings:save('all')
      windower.send_command("unbind "..format_send_keybind(key).."; wait 0.5; bind "..format_send_keybind(key).." "..action)
      windower.add_to_chat(settings.action_color, format_display_name(key):color(settings.key_color, settings.action_color)..' '..action)
      return true
   else
      log('Key entered is invalid, please verify and try again')
      return false
   end
end

function remove_bind(key)
   if not key or key == '' then
      log("Invalid entry, please use format 'kb unbind [modifier] <key>' with modifier being optional")
      return
   end

   if settings.key_sets[settings.active_key_set]:containskey(format_save_name(key)) then
      settings.key_sets[settings.active_key_set] = remove(settings.key_sets[settings.active_key_set], format_save_name(key))
      settings:save('all')
      windower.send_command("unbind "..format_send_keybind(key))
      log(key..' has been removed from '..format_display_name(settings.active_key_set))
   else
      log('Key entered does not exist in '..format_display_name(settings.active_key_set))
   end
end

function load_file(file_name)
   if files.exists("./kb_sets/"..file_name) then
      new_set = files.readlines("./kb_sets/"..file_name)
   else
      log('File does not exist')
      return
   end

   file_name = file_name:gsub('%p%a+', '')

   if add_set(file_name) then
      set_active_set(file_name)
      unbind_all()
      for _,v in pairs(new_set) do
         if type(v) == 'string' and v ~= '' then
            if not add_bind(v:split(' ')) then
               log('Failed to bind: '..v)
            end
         end
      end
   end
end