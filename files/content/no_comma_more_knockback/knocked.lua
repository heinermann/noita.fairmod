-- OK I couldn't figure out how to get mina to FUCKING SEND IT
-- so this jank exists, it's wrong, but I don't care anymore


local entity = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity)

if not EntityHasTag(root, "player_unit") and not EntityHasTag(root, "polymorphed_player") then
	return
end

local amt = tonumber(GlobalsGetValue("PERK_NO_COMMA_MORE_KNOCKBACK_AMT", "0"))
if amt <= 0 then return end

local comp = EntityGetFirstComponentIncludingDisabled(root, "CharacterDataComponent")
if comp == nil then return end

local game_effect = EntityGetFirstComponent(entity, "GameEffectComponent")
if game_effect ~= nil then
	EntityRemoveComponent(entity, game_effect)
	--ComponentSetValue2(game_effect, "frames", 20)
	--ComponentSetValue2(game_effect, "disable_movement", true)
	EntityAddComponent2(entity, "LifetimeComponent", {
		lifetime = 20
	})
end

local platformer = EntityGetFirstComponent(root, "CharacterPlatformingComponent")
if platformer == nil then return end

local accel_air = ComponentGetValue2(platformer, "accel_x_air")
local accel = ComponentGetValue2(platformer, "accel_x")
local pixel_gravity = ComponentGetValue2(platformer, "pixel_gravity")
EntityAddComponent2(entity, "VariableStorageComponent", { _tags="accel_x_air", name = "accel_x_air", value_float = accel_air })
EntityAddComponent2(entity, "VariableStorageComponent", { _tags="accel_x", name = "accel_x", value_float = accel })
EntityAddComponent2(entity, "VariableStorageComponent", { _tags="pixel_gravity", name = "pixel_gravity", value_float = pixel_gravity })
ComponentSetValue2(platformer, "accel_x_air", 0)
ComponentSetValue2(platformer, "accel_x", 0)
ComponentSetValue2(platformer, "pixel_gravity", 0)


local function reel_in_objects(x, y, dir_x, dir_y)
	local objects_to_reel = EntityGetInRadius(x, y, 10)

	for _, entity in ipairs(objects_to_reel) do
		if EntityHasTag(entity, "bobber") then goto continue end

		local phys3 = EntityGetFirstComponent(entity, "SimplePhysicsComponent")
		if phys3 and ComponentGetValue2(phys3, "can_go_up") then
			local velocity_comp = EntityGetFirstComponent(entity, "VelocityComponent")
			if velocity_comp ~= nil then
				ComponentSetValue2(velocity_comp, "mVelocity", dir_x * 10, dir_y * 10)
			end
		end

		local chr = EntityGetFirstComponent(entity, "CharacterDataComponent")
		if chr then
			local vx, vy = ComponentGetValue2(chr, "mVelocity")
			--LoadGameEffectEntityTo(entity, "mods/noita.fairmod/files/content/fishing/files/stun_effect.xml")
			ComponentSetValue2(chr, "mVelocity", vx + dir_x * 200, vy + dir_y * 200)
		end

		::continue::
	end

	PhysicsApplyForceOnArea(function(body_entity, body_mass, body_x, body_y, body_vel_x, body_vel_y, body_vel_angular)
		local scale = 1000 * body_mass / (((body_x - x) ^ 2 + (body_y - y) ^ 2) ^ 0.5 + 20)
		return x, y, dir_x * scale, dir_y * scale, 0
	end, entity, x - 10, y - 10, x + 10, y + 10)
end

local x, y = EntityGetTransform(root)
local vx, vy = ComponentGetValue2(comp, "mVelocity")
vy = vy - 60

vx = vx * 2 * amt
if vx >= 0 and vx < 200 then
	vx = vx + 200
elseif vx < 0 and vx > -200 then
	vx = vx - 200
end
vy = vy * 2 * amt

local vx_comp = EntityGetFirstComponent(entity, "VariableStorageComponent", "vx")
local vy_comp = EntityGetFirstComponent(entity, "VariableStorageComponent", "vy")
if vx_comp ~= nil and vy_comp ~= nil then
	ComponentSetValue2(vx_comp, "value_float", vx)
	ComponentSetValue2(vy_comp, "value_float", vy)
end

--GamePrint("reeled")
reel_in_objects(x, y, vx, vy)

--ComponentSetValue2(comp, "mVelocity", vx * (amt + 1) * 10, vy * (amt + 1) * 10)
ComponentSetValue2(comp, "is_on_ground", false)
ComponentSetValue2(comp, "mFramesOnGround", 0)

EntityLoadToEntity("mods/noita.fairmod/files/content/no_comma_more_knockback/knockback_player_ext.xml", entity)
