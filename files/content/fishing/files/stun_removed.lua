local me = GetUpdatedEntityID()
local parent = EntityGetParent(me)
local platformer = EntityGetFirstComponent(parent, "CharacterPlatformingComponent")
if platformer == nil then return end

local accel_x_air_comp = EntityGetFirstComponent(me, "VariableStorageComponent", "accel_x_air")
local accel_x_comp = EntityGetFirstComponent(me, "VariableStorageComponent", "accel_x")
if accel_x_air_comp ~= nil and accel_x_comp ~= nil then
	ComponentSetValue2(platformer, "accel_x_air", ComponentGetValue2(accel_x_air_comp, "value_float"))
	ComponentSetValue2(platformer, "accel_x", ComponentGetValue2(accel_x_comp, "value_float"))
end

local pixel_gravity = EntityGetFirstComponent(me, "VariableStorageComponent", "pixel_gravity")
if pixel_gravity ~= nil then
	ComponentSetValue2(platformer, "pixel_gravity", ComponentGetValue2(pixel_gravity, "value_float"))
end


if EntityHasTag(parent, "player_unit") or EntityHasTag(parent, "polymorphed_player") then
	local controls = EntityGetFirstComponentIncludingDisabled(parent, "ControlsComponent")
	if controls ~= nil then
		ComponentSetValue2(controls, "enabled", true)
	end
end
