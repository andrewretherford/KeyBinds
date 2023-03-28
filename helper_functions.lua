function get_key_and_action(args)
   if #args < 2 then return false end

   args = T{args}
   local key = ''
   local action = ''

   if table.find(modifiers, args[1]) then
      key = args[1]..' '..args[2]
      action = table.concat(table.slice(args, 3, #args), ' ')
   else
      key = args[1]
      action = table.concat(table.slice(args, 2, #args), ' ')
   end

   return key, args
end

function validate_key(key)
   if key == nil or key == '' then return false end

   key = key
      :gsub('~', '')
      :gsub('^', '')
      :gsub('!', '')

   return table.find(keybinds, key)
end

function display_keybind_format(key)
   if not key or key == '' then return false end

   return key
      :gsub('~', 'Shift ')
      :gsub('^', 'Ctrl ')
      :gsub('!', 'Alt ')
end

function save_keybind_format(key)
   if not key or key == '' then return false end

   if not string.startswith(key, '~') and not string.startswith(key, '^') and not string.startswith(key, '!') then
      return key
         :gsub('shift ', '~')
         :gsub('ctrl ', '^')
         :gsub('alt ', '!')
   end
end