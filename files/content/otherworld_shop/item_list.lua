
dofile_once("data/scripts/lib/utilities.lua")

local item_metatable = {}

function item_metatable:GetTranslationKey()
	return "$fairmod_" .. self.game .. "_" .. self.name
end

function item_metatable:GetImage()
	return "mods/noita.fairmod/files/content/otherworld_shop/items/" .. self.game .. "/" .. self.name .. ".png"
end

function item_metatable:CreateUseless(x, y)
	local entity = EntityLoad("mods/noita.fairmod/files/content/otherworld_shop/items/useless_item.xml", x, y)

	edit_all_components2(entity, "UIInfoComponent", function(_, vars)
		vars.name = self:GetTranslationKey()
	end)
	edit_all_components2(entity, "PhysicsImageShapeComponent", function(_, vars)
		vars.image_file = self:GetImage()
		vars.material = self.material
	end)
	edit_all_components2(entity, "ItemComponent", function(_, vars)
		vars.ui_sprite = self:GetImage()
		vars.item_name = self:GetTranslationKey()
	end)
	edit_all_components2(entity, "SpriteComponent", function(_, vars)
		vars.image_file = self:GetImage()
	end)
	edit_all_components2(entity, "AbilityComponent", function(_, vars)
		vars.ui_name = self:GetTranslationKey()
	end)

	return entity
end

-- game, name, material
local item_list = {
	{ game = "factorio", name = "advanced-circuit", material = "plastic" }
}

for _, item in ipairs(item_list) do
	setmetatable(item, item_metatable)
end

return item_list
