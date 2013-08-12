# vent

A thin layer on corona events that keeps track on the events and an API more akin to jQuery

## Installation

Ensure the bower registry is `"https://yogome-bower.herokuapp.com"` and then `bower install vent`

## Usage

```lua
require('bower_require')()
local vent = require 'bower.vent'

local function onEvent(event)
  print 'inside an event'
end

vent:on('event', onEvent)

vent:trigger('event', {data = 'foo'})

vent:off('event', onEvent)

vent:allOff('event')

```