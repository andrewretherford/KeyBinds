-- Validates user entered slot for 'addtrust' command and returns appropriate values

function parse_slot(slot)
   local key
   local key_name

   if slot == '1' then
      key = 't1'
      key_name = 'Trust 1'
   elseif slot == '2' then
      key = 't2'
      key_name = 'Trust 2'
   elseif slot == '3' then
      key = 't3'
      key_name = 'Trust 3'
   elseif slot == '4' then
      key = 't4'
      key_name = 'Trust 4'
   elseif slot == '5' then
      key = 't5'
      key_name = 'Trust 5'
   else
      return {nil, nil}
   end

   return {key, key_name}
end

function delete_element(table, key)
   local new_table = T{}

   for k,v in pairs(table) do
      if k ~= key then
         new_table[k] = v
      end
   end

   return new_table
end