-- area_locked_chests/init.lua
-- Locked chest that check protections
-- Copyright (c) 2022, 2026  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("area_locked_chests")

local def = {
	description = S("Area Protected Chest"),
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png" .. "^[transformFX",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_lock.png"
	},
	sounds = default.node_sound_wood_defaults(),
	groups = { choppy = 2, oddly_breakable_by_hand = 2 },
	legacy_facedir_simple = true,
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("infotext", S("Area Protected Chest"))
		local inv = meta:get_inventory()
		inv:set_size("main", 8 * 4)
	end,
	can_dig = function(pos, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return false
		end
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		end
		return count
	end,
	allow_metadata_inventory_put = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		end
		return stack:get_count()
	end,
	on_rightclick = function(pos, _, player, itemstack)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return itemstack
		end
		core.show_formspec(name, "area_locked_chests:area_locked_chests", default.chest.get_chest_formspec(pos))
	end,
	on_blast = function() end,
}

default.set_inventory_action_loggers(def, "chest")

core.register_node("area_locked_chests:area_locked_chests", def)

if core.global_exists("pipeworks") then
	pipeworks.override_chest("area_locked_chests:area_locked_chests", {},
		{ left = 1, right = 1, back = 1, bottom = 1, top = 1 })
end

core.register_craft({
	type = "shapeless",
	recipe = { "default:chest_locked", "default:steel_ingot" },
	output = "area_locked_chests:area_locked_chests",
})
