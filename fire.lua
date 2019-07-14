local fire_mod_enabled = minetest.get_modpath("fire")

function qeffects.fire.apply(name, dps, time)
	local player = minetest.get_player_by_name(name)

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

	local soundkey
	if fire_mod_enabled then
		soundkey = minetest.sound_play("fire_fire", {
			to_player = name,
			loop = true,
		})
	end

	qeffects.fire.players[name] = {dps = dps, time = time, hud = hudkey, sound = soundkey}
end

function qeffects.fire.remove(name)
	local player = minetest.get_player_by_name(name)

	if player then
		player:hud_remove(qeffects.fire.players[name].hud)
	else
		minetest.log("warning", "[QEffects:Fire] Player "..name.." not found. Finishing remove()...")
	end

	if fire_mod_enabled then
		minetest.sound_stop(qeffects.fire.players[name].sound)

		if player then minetest.sound_play("fire_extinguish_flame", {to_player = name}) end
	end

	qeffects.fire.players[name] = nil
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
