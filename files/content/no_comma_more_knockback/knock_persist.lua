local entity = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity)

local vx_comp = EntityGetFirstComponent(entity, "VariableStorageComponent", "vx")
local vy_comp = EntityGetFirstComponent(entity, "VariableStorageComponent", "vy")
if vx_comp ~= nil and vy_comp ~= nil then
	local vx = ComponentGetValue2(vx_comp, "value_float")
	local vy = ComponentGetValue2(vy_comp, "value_float")

	local comp = EntityGetFirstComponentIncludingDisabled(root, "CharacterDataComponent")
	if comp ~= nil then
		ComponentSetValue2(comp, "mVelocity", vx, vy)
		ComponentSetValue2(comp, "is_on_ground", false)
		ComponentSetValue2(comp, "mFramesOnGround", 0)
	end
end
