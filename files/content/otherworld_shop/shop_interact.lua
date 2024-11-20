dofile_once("data/scripts/lib/utilities.lua")

local items = dofile_once("mods/noita.fairmod/files/content/otherworld_shop/item_list.lua")

local dialog_system = dofile_once("mods/noita.fairmod/files/lib/DialogSystem/dialog_system.lua")
dialog_system.distance_to_close = 35
dialog_system.dialog_box_height = 80

dialog_system.sounds.gibberish = { bank = "mods/noita.fairmod/fairmod.bank", event = "payphone/gibberish" }
dialog_system.sounds.garbled = { bank = "mods/noita.fairmod/fairmod.bank", event = "payphone/garbled" }

local sale_dialogs = {
	"What're ya buyin?",
	"Khajiit has wares, if you have coin.",
	"Greetings from another world. What are you looking for?",
}

local already_trickortreated_dialogs = {
	"You got yours already.",
	"I already gave you some candy.",
	"I'm not giving you any more.",
	"Sorry, out of candy.",
	"Try asking somewhere else."
}

local treats_list = {
	-- TODO
}

local common_dlg_leave = { text = "Leave" }


local function generate_shop_items()
	-- TODO
	return {}
end

local function create_useless_item(x, y, name, material, image)
	local entity = EntityLoad("mods/noita.fairmod/files/content/otherworld_shop/items/useless_item.xml", x, y)

	edit_all_components2(entity, "UIInfoComponent", function(comp, vars)
		vars.name = name
	end)
	edit_all_components2(entity, "PhysicsImageShapeComponent", function(comp, vars)
		vars.image_file = "mods/noita.fairmod/files/content/otherworld_shop/items/" .. image
		vars.material = material
	end)
	edit_all_components2(entity, "ItemComponent", function(comp, vars)
		vars.ui_sprite = "mods/noita.fairmod/files/content/otherworld_shop/items/" .. image
		vars.item_name = name
	end)
	edit_all_components2(entity, "SpriteComponent", function(comp, vars)
		vars.image_file = "mods/noita.fairmod/files/content/otherworld_shop/items/" .. image
	end)
	edit_all_components2(entity, "AbilityComponent", function(comp, vars)
		vars.ui_name = name
	end)

	return entity
end

local function init_seed()
	local x, y = GameGetCameraPos()
	SetRandomSeed(x, y + GameGetFrameNum())
end

function interacting(player, entity_interacted, interactable_name)
	-- If viewing a scratch ticket, don't interact at the same time
	if EntityHasTag(entity_interacted, "viewing") or GameHasFlagRun("fairmod_scratch_interacting") then return end
	if GameHasFlagRun("fairmod_interacted_with_anything_this_frame") then return end
	GameAddFlagRun("fairmod_interacted_with_anything_this_frame")
	GameAddFlagRun("fairmod_dialog_interacting")

	init_seed()

	local x, y = EntityGetTransform(entity_interacted)
	local trickortreat_flag = "fairmod_trickortreat_rewarded_otherworldshop_" .. y
	local shop_voice_str = "fairmod_otherworld_shop_voice_" .. y

	if GlobalsGetValue(shop_voice_str, "") == "" then
		local voices = {"garbled", "gibberish"}
		GlobalsSetValue(shop_voice_str, voices[Random(1, 2)])
	end

	dialog = dialog_system.open_dialog({
		name = "Otherworld Merchant",
		portrait = "mods/noita.fairmod/files/content/information_kiosk/portrait.png",
		typing_sound = GlobalsGetValue(shop_voice_str),
		text = sale_dialogs[Random(1, #sale_dialogs)],
		options = {
			{
				text = "Item 1",
				enabled = function(stats)
					return true
				end,
				func = function(dialog)
					GamePrint("Item 1")
					-- create item
					-- remove item in stock
					-- play buy sfx
				end,
			},
			{
				text = "Trick or treat!",
				show = function()
					return GameHasFlagRun("fairmod_halloween_mask")
				end,
				func = function(dialog)
					if GameHasFlagRun(trickortreat_flag) then
						dialog.show({
							text = already_trickortreated_dialogs[Random(1, #already_trickortreated_dialogs)],
							options = { common_dlg_leave },
						})
					else
						dialog.show({
							text = "Yeah yeah here you go...",
							options = {
								{
									text = "Take treat",
									func = function(dialog)
										local candies = {
											"candy_fairmod_hamis", "candy_fairmod_ambrosia", "candy_fairmod_toxic"
										}

										GameCreateParticle(candies[Random(1, 3)], x, y, 100, 0, 0, false)

										GameAddFlagRun("fairmod_trickortreated")
										GameAddFlagRun(trickortreat_flag)
										dialog.close()
									end,
								},
							},
						})
					end
				end,
			},
			common_dlg_leave,
		},
		on_closed = function()
			GameRemoveFlagRun("fairmod_dialog_interacting")
		end,
	})
end
