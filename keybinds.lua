_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

-- Windower Libraries
require('logger')

-- Globals

-- Keybinds
windower.register_event('load', function()
   windower.send_command('bind ~1 kb mount')
end)

windower.register_event('addon command', function(command,...)
   command = command and command:lower()
   if command == 'mount' then
      if windower.ffxi
      windower.send_command('input /mount raptor')
      notice("Mounting Raptor")
   end
end)
