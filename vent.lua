local vent = display.newGroup()

local listeners = {}

function vent:on(event, listener)
	if listener then
		listeners[event] = listeners[event] or {}
		table.insert(listeners[event], listener)
	end
	vent:addEventListener(event, listener)
end

function vent:off(event, listener)
	if listener then
		for i, currentListener in ipairs(listeners[event]) do
			if currentListener == listener then
				table.remove(listeners[event], i)
			end
		end
	end
	vent:removeEventListener(event, listener)
end

function vent:allOff(event)
	for i, currentListener in ipairs(listeners[event]) do
		table.remove(listeners[event], i)
		vent:removeEventListener(event, currentListener)
	end
end

function vent:trigger( eventName, data )
	assert(eventName, 'The event needs a name to trigger')
	data = data or {}
	if type(data) ~= 'table' then
		data = {value = data}
	end
	data.name = eventName
	vent:dispatchEvent(data)
end

function vent:allEventNames()
	local keys = {}
	for key, value in pairs(listeners)
		keys[#keys + 1] = key
	end
	return keys
end

return vent