-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local vent = require 'vent'
local log = require 'vendor.log.log'
-- log.disabled = true

vent:on('foo', function()
	log('WORKS')
end)

vent:on('foo', function(data)
	log('WORKS TOO', data)
end)

vent:once('foo', function()
	log.line("AM I APPEARING ONCE?")
end)

vent:trigger('foo')
vent:trigger('foo', {foo = 'bar'})
