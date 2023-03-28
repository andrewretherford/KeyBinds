function validate_key(key)
   if key == nil or key == '' then return false

   key = key
      :gsub('~', '')
      :gsub('^', '')
      :gsub('!', '')

   return table.find(keybinds, key:lower())
end

function display_keybind_format(key)
   if not key or key == '' then return end

   return key
      :gsub('~', 'Shift ')
      :gsub('^', 'Ctrl ')
      :gsub('!', 'Alt ')
end

function save_keybind_format(key)
   if not key or key == '' then return end

   if not string.startswith(key, '~') and not string.startswith(key, '^') and not string.startswith(key, '!') then
      return key
         :gsub('')
   end
end