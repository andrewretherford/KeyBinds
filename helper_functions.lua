require('data')

function get_key_and_action(args)
   if #args < 2 then return false end

   local key = ''
   local action = ''

   if table.find(modifiers, args[1]) then
      key = args[1]..' '..args[2]
      action = table.concat(table.slice(args, 3, #args), ' ')
   else
      key = args[1]
      action = table.concat(table.slice(args, 2, #args), ' ')
   end

   return key, action
end

function validate_key(key)
   if key == nil or key == '' then return false end

   key = key
      :gsub('~', '')
      :gsub('%^', '')
      :gsub('!', '')
      :gsub('shift ', '')
      :gsub('ctrl ', '')
      :gsub('alt ', '')

   return table.find(keybinds, key)
end

function format_send_keybind(key)
   if not key or key == '' then return false end

   return key
      :gsub('shift ', '~')
      :gsub('ctrl ', '^')
      :gsub('alt ', '!')
      :gsub('shift_', '~')
      :gsub('ctrl_', '^')
      :gsub('alt_', '!')
      :gsub('left_bracket', '[')
      :gsub('right_bracket', ']')
      :gsub('_star', '*')
      :gsub('_forward_slash', '/')
end

function format_display_name(saved_name)
   if saved_name == '' then return false end

   saved_name = saved_name
      :gsub('~', 'shift ')
      :gsub('%^', 'ctrl ')
      :gsub('!', 'alt ')
      :gsub('%[', 'left bracket')
      :gsub('%]', 'right bracket')
      :gsub('%*', ' star')
      :gsub('/', ' forward slash')
      :gsub('_', ' ')

   return saved_name
end

function format_save_name(display_name)
   if display_name == '' then return false end

   display_name = display_name
      :gsub('~', 'shift_')
      :gsub('%^', 'ctrl_')
      :gsub('!', 'alt_')
      :gsub('%[', 'left_bracket')
      :gsub('%]', 'right_bracket')
      :gsub('%*', '_star')
      :gsub('/', '_forward_slash')
      :gsub(' ', '_')

   return display_name
end

function remove(table, key)
   new_table = T{}
   for k,v in pairs(table) do
      if k ~= key then
         new_table[k] = v
      end
   end

   return new_table
end

function unbind_all()
   windower.send_command('clearbinds')
end

function load_binds()
   unbind_all()
   load_set_binds()
   if settings.multibox == true then
      load_multibox_binds()
   else
      load_solo_binds()
   end
end

function load_multibox_binds()
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad7 send @all ub mount")
   windower.send_command("bind ~numpad3 send @all ub warp")   
   windower.send_command("bind ~escape send @all kb exitall")   
end

function load_solo_binds()
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad7 ub mount")
   windower.send_command("bind ~numpad3 ub warp")
   windower.send_command("bind ~escape kb exitall") 
end

function load_set_binds()
   if settings.active_key_set == '' then return end

   if settings.key_sets[settings.active_key_set] then
      for k,v in pairs(settings.key_sets[settings.active_key_set]) do
         windower.send_command("bind "..format_send_keybind(k)..' '..v)
      end
   else
      log('No active keyset')
      return
   end
end