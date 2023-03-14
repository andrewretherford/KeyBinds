_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

-- Windower Libraries
require('logger')

-- Keybinds
windower.register_event('load', function()
   windower.send_command('bind ~1 kb mount')
end)

windower.register_event('addon command', function(command,...)
   command = command and command:lower()

   if command == 'mount' then
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
end)
