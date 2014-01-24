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

local class = require 'vendor.middleclass.middleclass'
describe('Works as a mixin', function()
	setup(function()
		MyObject = class'MyObject'
		MyObject:include(vent)
	end)
	teardown(function()
		MyObject = nil
	end)

	it('is a class', function()
		assert.True(MyObject:isSubclassOf(class.Object))
	end)

	it('has methods', function()
		local inst = MyObject:new()
		assert.truthy(inst.on)
		assert.truthy(inst.off)
		assert.truthy(inst.once)
		assert.truthy(inst.trigger)
		inst = nil
	end)

	it('calls a listener with data', function(done)
		eventually(async(function()
			local inst = MyObject:new()
			inst:on('test6', function(self, data)
				assert.True(data.ok)
				done()
			end)
			inst:trigger('test6', {ok = true})
		end))
	end)

	it('has access to self properties', function(done)
		eventually(async(function()
			local inst = MyObject:new()
			inst.hello = 'world'
			inst:on('test7', function(self)
				assert.equals(self.hello, 'world')
				done()
			end)
			inst:trigger('test7')
		end))
	end)

	it('is different to vent', function(done)
		eventually(async(function()
			local inst = MyObject:new()
			local timescalled = 0
			local function listener()
				timescalled = timescalled + 1
				assert.equals(1, timescalled)
			end

			vent:on('test8', listener)
			inst:trigger('test8', nil, true)
			vent:trigger('test8', nil, true)
			timer.performWithDelay(0.2, function()
				done()
			end)
		end))
	end)

end)