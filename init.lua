qeffects = {
	fire = {
		players = {},
		dps_multiplier = 1
	},
	freeze = {
		players = {},
	},
}

minetest.register_globalstep(function(dtime)
	qeffects.fire.on_step(dtime)
	qeffects.freeze.on_step(dtime)
end)

dofile(minetest.get_modpath("quadeffects").."/effects/fire.lua")
dofile(minetest.get_modpath("quadeffects").."/effects/freeze.lua")
--dofile(minetest.get_modpath("quadeffects").."/stun.lua")
--dofile(minetest.get_modpath("quadeffects").."/bleed.lua")
