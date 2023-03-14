_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = 0.0.0
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

-- Keybinds

windower.register_event('load',funciton()
   windower.send_command('bind ~1 mount')
end)

windower.register_event('addon command', function(command,...)
   command = command and command:lower()
   if command == 'mount' then
      input "/mount Raptor"
   end
end)
