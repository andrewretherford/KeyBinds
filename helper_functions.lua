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
end

function format_display_name(saved_name)
   if saved_name == '' then return false end

   saved_name = saved_name
      :gsub('_', ' ')
      :gsub('~', 'shift ')
      :gsub('%^', 'ctrl ')
      :gsub('!', 'alt ')

   return saved_name
end

function format_save_name(set_name)
   if set_name == '' then return false end

   set_name = set_name
      :gsub(' ', '_')
      :gsub('~', 'shift_')
      :gsub('%^', 'ctrl_')
      :gsub('!', 'alt_')

   return set_name
end

function unbind_all()
   for _,v in pairs(keybinds) do
      windower.send_command("unbind "..v)
   end
end

function load_binds()
   if settings.multibox == true then
      unbind_all()
      multibox_binds()
   else
      unbind_all()
      solo_binds()
   end
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