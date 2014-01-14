local ev = require 'ev'
local vent = require 'vent'
timer = require 'mockTimer'
setloop('ev')

local function eventually(onTimeout)
	ev.Timer.new(function()
	onTimeout()
	end, 2 ^ -40):start(ev.Loop.default)
end

describe("Testing vent", function()

	it("calls a listener", function(done)
		eventually(async(function()
			local function listener()
				print'hola'
				done()
			end
			vent:on('test1', listener)
			vent:trigger('test1')
		end))
	end)

	it("calls a listener with data", function(done)
		local function listener(event)
			assert.is_true(event.ok)
			done()
		end
		vent:on('test', listener)
		vent:trigger('test', {ok = true})
	end)

	it('doesnt call a function after off', function(done)
		local function listener()
			assert.True(false, 'function was called')
		end
		vent:on('test', listener)
		vent:off('test', listener)
	end)

	it('doesnt call a function after allOff', function(done)
		local function listener()
			assert.True(false, 'function was called')
		end
		vent:on('test', listener)
		vent:allOff('test')
	end)

	it("calls a listener once", function(done)
		local timescalled = 0
		local function listener(event)
			print 'on listener'
			timescalled = timescalled + 1
			assert.True(timescalled == 1, 'Function was called multiple times')
		end

		vent:once('test', listener)
		vent:trigger('test')
		vent:trigger('test')
	end)

end)
