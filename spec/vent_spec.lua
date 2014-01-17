local ev = require 'ev'
local vent = require 'vent'
timer = require 'mocks.timer'
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
				done()
			end
			vent:on('test1', listener)
			vent:trigger('test1')
		end))
	end)

	it("calls a listener with data", function(done)
		eventually(async(function()
			local function listener(event)
				assert.is_true(event.ok)
				done()
			end
			vent:on('test2', listener)
			vent:trigger('test2', {ok = true})
		end))
	end)

	it('doesnt call a function after off', function(done)
		eventually(async(function()
			local function listener()
				assert.True(false, 'function was called')
			end
			vent:on('test3', listener)
			vent:off('test3', listener)
			vent:trigger('test')
			timer.performWithDelay(0.2, function()
				done()
			end)
		end))
	end)

	it('doesnt call a function after allOff', function(done)
		eventually(async(function()
			local function listener()
				assert.True(false, 'function was called')
			end
			vent:on('test4', listener)
			vent:allOff('test4')
			vent:trigger('test4')
			timer.performWithDelay(0.2, function()
				done()
			end)
		end))
	end)

	it("calls a listener once", function(done)
		eventually(async(function()
			local timescalled = 0
			local function listener(event)
				timescalled = timescalled + 1
				assert.True(timescalled == 1, 'Function was called multiple times')
			end

			vent:once('test5', listener)
			vent:trigger('test5')
			vent:trigger('test5')
			timer.performWithDelay(0.2, function()
				done()
			end)
		end))
	end)

end)
