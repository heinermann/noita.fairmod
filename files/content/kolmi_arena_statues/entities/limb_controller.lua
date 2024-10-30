-- enum for changing C++ logic state. keep this in sync with the values in limbboss_system.cpp
STATE = {
	MoveAroundNest = 0,
	FollowPlayer = 1,
	Escape = 2,
	DontMove = 3,
	MoveTo = 4,
	MoveDirectlyTowardsPlayer = 5,
}

-- Limb management
local controller = {
	walkers = {},
	limbs = {},
}

dofile_once("mods/noita.fairmod/files/scripts/utils/utilities.lua")

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)

local children = EntityGetAllChildren(entity_id)
if children ~= nil then
	for _, child in ipairs(children) do
		controller.walkers = MergeTables(controller.walkers, EntityGetComponentIncludingDisabled(child, "IKLimbWalkerComponent"))
		controller.limbs = MergeTables(controller.limbs, EntityGetComponentIncludingDisabled(child, "IKLimbComponent"))
	end
end


return controller
