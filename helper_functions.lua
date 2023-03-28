require('data')

function get_key_and_action(args)
   if #args < 2 then return false end

   local key = ''
   local action = ''

   if table.find(modifiers, args[1]) then
      log('modifier')
      key = args[1]..' '..args[2]
      action = table.concat(table.slice(args, 3, #args), ' ')
   else
      log('no modifier')
      key = args[1]
      action = table.concat(table.slice(args, 2, #args), ' ')
   end
   -- log('inside get_key_and_action: '..key, action)
   return key, action
end

function validate_key(key)
   if key == nil or key == '' then return false end
   log('inside validate: '..key)
   key = key
      :gsub('~', '')
      :gsub('^', '')
      :gsub('!', '')
      :gsub('shift ', '')
      :gsub('ctrl ', '')
      :gsub('alt ', '')

   return table.find(keybinds, key)
end

-- function display_keybind_format(key)
--    if not key or key == '' then return false end

--    return key
--       :gsub('~', 'Shift ')
--       :gsub('^', 'Ctrl ')
--       :gsub('!', 'Alt ')
-- end

function send_keybind_format(key)
   if not key or key == '' then return false end

   if not string.startswith(key, '~') and not string.startswith(key, '^') and not string.startswith(key, '!') then
      return key
         :gsub('shift ', '~')
         :gsub('ctrl ', '^')
         :gsub('alt ', '!')
         :gsub('shift_', '~')
         :gsub('ctrl_', '^')
         :gsub('alt_', '!')
   end
end

function display_name_format(saved_name)
   if saved_name == '' then return false end

   return saved_name:gsub('_', ' ')
end

function save_name_format(set_name)
   if set_name == '' then return false end

   local output = set_name
      :gsub(' ', '_')
      :gsub('~', 'shift_')
      :gsub('%^', 'ctrl_')
      :gsub('!', 'alt_')

   return output
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