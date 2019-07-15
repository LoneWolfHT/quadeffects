local fire_mod_found = false
local fire_sound
local fire_sound_gain = 1.0
local fire_extinguish_sound

if minetest.get_modpath("fire") then
	fire_mod_found = true
	fire_sound = "fire_fire"
	fire_extinguish_sound = "fire_extinguish_flame"
elseif minetest.get_modpath("nc_fire") then
	fire_sound_gain = 4
	qeffects.fire.dps_multiplier = 1.5
	fire_mod_found = true
	fire_sound = "nc_fire_flamy"
	fire_extinguish_sound = "nc_fire_snuff"
end

function qeffects.fire.apply(name, dps, time)
	local player = minetest.get_player_by_name(name)
	local pos = vector.new(0, 0.5, 0)

	if not player then
		minetest.log("warning", "[QEffects:Fire] Player "..name.." not found. Aborting apply()...")
		return
	end


	local hudkey = player:hud_add({
		hud_elem_type = "image",
		name = "quadeffects_firehud",
		position  = {x = 0.5, y = 0.75},
		offset    = {x = 0, y = 0},
		text      = "quadeffects_fire_hud.png",
		alignment = {x = 0, y = 0},
		scale     = {x = -100, y = -75},
	})

	local particles = minetest.add_particlespawner({
		time = 0,
		amount = dps * 30,
		minpos = vector.subtract(pos, 0.5),
		maxpos = vector.add(pos, 0.5),
		minvel = {x = -1, y = 3, z = -1},
		maxvel = {x = 1, y = 4,  z = 1},
		minacc = {x = 0, y = 3, z = 0},
		maxacc = {x = 0, y = 5, z = 0},
		minexptime = 0.2,
		maxexptime = 0.3,
		minsize = 4,
		maxsize = 5,
		texture = "quadeffects_fire_particle.png",
		collisiondetection = true,
		collision_removal = false,
		attached = player,
	})

	local soundkey
	if fire_mod_found then
		soundkey = minetest.sound_play(fire_sound, {
			to_player = name,
			loop = true,
		})
	end

	qeffects.fire.players[name] = {dps = dps, time = time, hud = hudkey, sound = soundkey, pkey = particles}
end

function qeffects.fire.remove(name)
	local player = minetest.get_player_by_name(name)

	if player then
		player:hud_remove(qeffects.fire.players[name].hud)
		minetest.delete_particlespawner(qeffects.fire.players[name].pkey)
	else
		minetest.log("warning", "[QEffects:Fire] Player "..name.." not found. Finishing remove()...")
	end

	if fire_mod_found then
		minetest.sound_stop(qeffects.fire.players[name].sound)

		if player then minetest.sound_play(fire_extinguish_sound, {to_player = name, pitch = fire_sound_gain}) end
	end

	qeffects.fire.players[name] = nil
end

function qeffects.fire.on_step()
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
				qeffects.fire.apply(name, 0.7 * qeffects.fire.dps_multiplier, 7)
			end
		end
	end

	if qeffects.fire.players ~= {} then
		for name, effect in pairs(qeffects.fire.players) do
			local player = minetest.get_player_by_name(name)

			if player then
				player:set_hp(player:get_hp() - effect.dps, {quadeffect = "fire"})
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
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	if qeffects.fire.players[name] then
		qeffects.fire.remove(name)
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()

	if qeffects.fire.players[name] then
		qeffects.fire.remove(name)
	end
end)
