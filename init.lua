qeffects = {
	fire = {
		players = {},
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

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local node = minetest.get_node(player:get_pos()).name

		--
		--- Fire Effect
		--

		if qeffects.fire.players[name] then
			if minetest.get_item_group(node, "water") ~= 0 or minetest.get_item_group(node, "snowy") ~= 0 then
				qeffects.fire.remove(name)
			end
		else
			if minetest.get_item_group(node, "lava") ~= 0 or minetest.get_item_group(node, "igniter") ~= 0 then
				qeffects.fire.apply(name, 1.3, 7)
			end
		end
	end

	--
	--- Fire Effect
	--

	if qeffects.fire.players ~= {} then
		for name, effect in pairs(qeffects.fire.players) do
			local player = minetest.get_player_by_name(name)

			if player then
				local pos = player:get_pos()

				player:set_hp(player:get_hp() - effect.dps, {quadeffect = "fire"})

				minetest.add_particlespawner({
					amount = 20,
					time = 0.5,
					minpos = vector.subtract(pos, 0.3),
					maxpos = vector.add(pos, 0.3),
					minvel = {x = -1, y = 0, z = -1},
					maxvel = {x = 1, y = 1,  z = 1},
					minacc = {x = 0, y = 3, z = 0},
					maxacc = {x = 0, y = 5, z = 0},
					minexptime = 0.5,
					maxexptime = 0.7,
					minsize = 3,
					maxsize = 4,
					texture = "quadeffects_fire_particle.png",
					collisiondetection = true,
					collision_removal = true,
				})
			else
				qeffects.fire.remove(name)
				effect = false
			end

			if effect and effect.time <= 0 then
				qeffects.fire.remove(name)
			elseif effect then
				qeffects.fire.players[name].time = effect.time - 1
			end
		end
	end
end)

dofile(minetest.get_modpath("quadeffects").."/fire.lua")
--dofile(minetest.get_modpath("quadeffects").."/freeze.lua")
--dofile(minetest.get_modpath("quadeffects").."/stun.lua")
--dofile(minetest.get_modpath("quadeffects").."/bleed.lua")
