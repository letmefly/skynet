local configdata = {}

configdata.define_attendance = require "config.define_attendance"
configdata.define_enchant = require "config.define_enchant"
configdata.define_instant_item = require "config.define_instant_item"
configdata.define_item = require "config.define_item"
configdata.define_level = require "config.define_level"
configdata.define_mission = require "config.define_mission"
configdata.define_price = require "config.define_price"
configdata.define_reward = require "config.define_reward"
configdata.define_stage = require "config.define_stage"

function configdata:get(configname)
	return self[configname]
end

return configdata
