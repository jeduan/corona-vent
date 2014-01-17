local vent = {}
local log = require 'vendor.log.log'

local listeners = {}

function vent:on(event, listener)
	assert(type(self) == 'table', 'Method was called as .on instead of :on')
	assert(type(event) == 'string', 'Expected event to be a string')

	if listener then
		listeners[event] = listeners[event] or {}
		table.insert(listeners[event], listener)
	end
end

function vent:off(event, listener)
	assert(type(self) == 'table', 'Method was called as .off instead of :off')
	assert(type(event) == 'string', 'Expected event to be a string')

	if listener then
		for i, currentListener in ipairs(listeners[event] or {}) do
			if currentListener == listener then
				table.remove(listeners[event], i)
			end
		end
	else
		self:allOff(event)
	end
end

function vent:allOff(event)
	for i, currentListener in ipairs(listeners[event] or {}) do
		table.remove(listeners[event], i)
	end
end

function vent:trigger(event, data)
	assert(event, 'The event needs a name to trigger')
	data = data or {}
	if type(data) ~= 'table' then
		data = {value = data}
	end
	data.name = event

	local removals = {}

	for i, listener in ipairs(listeners[event] or {}) do
		if type(listener) == 'function' then
			timer.performWithDelay(2 ^ -40, function()
				listener(data)
			end)
		elseif type(listener) == 'table' and listener.listener then
			if listener.once then
				removals[#removals + 1] = i
			end
			timer.performWithDelay(2 ^ -40, function()
				listener.listener(data)
			end)
		end
	end

	for i = 1, #removals do
		table.remove(listeners[event], removals[i])
	end
end

function vent:allEventNames()
	local keys = {}
	for key, _ in pairs(listeners) do
		keys[#keys + 1] = key
	end
	return keys
end

function vent:once(name, listener)
	vent:on(name, {
		listener = listener,
		once = true
	})
end

return vent
