--
--
---#TODO#
--
--* Add particle effects

local player_stand_anim = {x = 1, y = 1}
local attached_func = function() end

if minetest.get_modpath("player_api") then
	attached_func = function(player, val)
		player_api.player_attached[player:get_player_name()] = val
	end
elseif minetest.get_modpath("nc_player_model") then
	player_stand_anim = {x = 0, y = 0}

	local default_player_anim = nodecore.player_anim

	nodecore.player_anim = function(player) -- todo: disable anims by overriding default anim func
		local name = player:get_player_name()
	end

	attached_func = function(player, val)
		nc_player_model.attached_players[player:get_player_name()] = val
	end
end

minetest.register_entity("quadeffects:freeze_entity", {
	initial_properties = {
		physical = true,
		collide_with_objects = true,
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		pointable = false,
		is_visible = false,
		static_save = false,
	},
	on_step = function(self, dtime)
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,
})

function qeffects.freeze.apply(name, time)
	local player = minetest.get_player_by_name(name)

	if not player then
		minetest.log("warning", "[QEffects:Freeze] Player "..name.." not found. Aborting apply()...")
		return
	elseif player:get_hp() <= 0 then
		minetest.log("warning", "[QEffects:Freeze] Player "..name.." is dead. Aborting apply()")
		return
	elseif qeffects.freeze.players[name] then -- player is already frozen. Reset time and abort
		qeffects.freeze.players[name].time = time
		return
	end

	local pos = player:get_pos()
	local obj = minetest.add_entity(pos, "quadeffects:freeze_entity")
	local textures_before = player:get_properties().textures[1]

	player:set_properties({
		textures = {"(" .. textures_before .. ")^[colorize:#008aff:155"},
	})

	player:set_animation(player_stand_anim, 1, false, true)
	attached_func(player, true)

	player:set_attach(obj, "", vector.new(), vector.new())

	obj:set_pos(pos)
	player:set_pos(pos)

	qeffects.freeze.players[name] = {
		time = time,
		entity = obj,
		textures_before = textures_before,
	}
end

function qeffects.freeze.remove(name)
	local player = minetest.get_player_by_name(name)

	if not player then
		minetest.log("warning", "[QEffects:Freeze] Player "..name.." not found. Removal will still finish...")

		qeffects.freeze.players[name].entity:remove()
		attached_func(player, nil)

		return
	end

	player:set_properties({
		textures = {qeffects.freeze.players[name].textures_before}, -- remove frozen color
	})

	player:set_detach()
end

function qeffects.freeze.on_step(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local node = minetest.get_node(player:get_pos()).name
	
		--
		--- Freeze Effect
		--
	
		if qeffects.freeze.players[name] then
			qeffects.freeze.players[name].time = qeffects.freeze.players[name].time - dtime

			if minetest.get_item_group(node, "lava") ~= 0 or minetest.get_item_group(node, "igniter") ~= 0 or
			qeffects.freeze.players[name].time <= 0 then
				qeffects.freeze.remove(name)
			end
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	if qeffects.freeze.players[name] then
		qeffects.freeze.remove(name)
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()

	if qeffects.freeze.players[name] then
		qeffects.freeze.remove(name)
	end
end)

minetest.register_on_punchplayer(function(player, _, _, tcaps, _, dmg)
	if tcaps.damage_groups.freezes > 0 and (player:get_hp() - dmg) > 0 then
		qeffects.fire.apply(player:get_player_name(), tcaps.damage_groups.freezes)
	end

	return false
end)
