qeffects = {
	fire = {
		players = {},
		dps_multiplier = 1
	}
}

local step = 0
minetest.register_globalstep(function(dtime)
	if step < 1 then
		step = step + dtime
		return
	else
		step = 0
	end

	qeffects.fire.on_step()
end)

dofile(minetest.get_modpath("quadeffects").."/fire.lua")
--dofile(minetest.get_modpath("quadeffects").."/freeze.lua")
--dofile(minetest.get_modpath("quadeffects").."/stun.lua")
--dofile(minetest.get_modpath("quadeffects").."/bleed.lua")
