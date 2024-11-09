
---@param component_id int
---@param value_name string
local function invert_component_value(component_id, value_name)
	ComponentSetValue2(component_id, value_name, -ComponentGetValue2(component_id, value_name))
end

---@param component_id int
---@param value_name string
local function invert_component_xy_value(component_id, value_name)
	local x, y = ComponentGetValue2(component_id, value_name)
	ComponentSetValue2(component_id, value_name, x, -y)
end


local function invert_component_gravity(entity, comp)

	local comp_name = ComponentGetTypeName(comp)
	if comp_name == "WormComponent" or comp_name == "BossDragonComponent" then
		invert_component_value(comp, "gravity")
		invert_component_value(comp, "tail_gravity")
	elseif comp_name == "VelocityComponent" then
		invert_component_value(comp, "gravity_y")
	elseif comp_name == "SpriteParticleEmitterComponent" then
		invert_component_xy_value(comp, "gravity")
		-- TODO: invert scale?
	elseif comp_name == "ParticleEmitterComponent" then
		invert_component_xy_value(comp, "gravity")
	elseif comp_name == "ProjectileComponent" then
		ComponentObjectSetValue2(comp, "config", "gravity", - (ComponentObjectGetValue2(comp, "config", "gravity") or 0))
	elseif comp_name == "AbilityComponent" then
		ComponentObjectSetValue2(comp, "gunaction_config", "gravity", - (ComponentObjectGetValue2(comp, "gunaction_config", "gravity") or 0))
	elseif comp_name == "CharacterDataComponent" then
		invert_component_value(comp, "gravity")
		invert_component_value(comp, "buoyancy_check_offset_y")
	elseif comp_name == "CharacterPlatformingComponent" then
		invert_component_value(comp, "pixel_gravity")
		invert_component_value(comp, "jump_velocity_y")
		ComponentSetValue2(comp, "fly_speed_mult", -11)
	elseif comp_name == "PhysicsBodyComponent" then
		invert_component_value(comp, "gravity_scale_if_has_no_image_shapes")

		--local mBodyId = ComponentGetValue2(comp, "mBodyId")
		--PhysicsBodyIDSetGravityScale(mBodyId, -PhysicsBodyIDGetGravityScale(mBodyId))

		--local bodies = PhysicsBodyIDGetFromEntity(entity, comp)
		--for _, body in ipairs(bodies) do
		--	PhysicsBodyIDSetGravityScale(body, -PhysicsBodyIDGetGravityScale(body))
		--end
	elseif comp_name == "PhysicsBody2Component" or comp_name == "SimplePhysicsComponent" then
		--local bodies = PhysicsBodyIDGetFromEntity(entity, comp)
		--for _, body in ipairs(bodies) do
		--	PhysicsBodyIDSetGravityScale(body, -PhysicsBodyIDGetGravityScale(body))
		--end
	end
end


local entity_id = GetUpdatedEntityID()
local want_y_inverted = ModSettingGet("noita.fairmod.invert_y_axis")


local components = EntityGetComponent(entity_id, "CharacterDataComponent")
if components ~= nil then
	for _, comp in ipairs(components) do
		ComponentSetValue2(comp, "is_on_ground", true)
	end
end

if want_y_inverted and not EntityHasTag(entity_id, "y_inverted") then
	EntityAddTag(entity_id, "y_inverted")

	local x, y, rot, scale_x, scale_y = EntityGetTransform(entity_id)
	EntitySetTransform(entity_id, x, y, rot, scale_x, -scale_y)

	for _, comp in ipairs(EntityGetAllComponents(entity_id)) do
		invert_component_gravity(entity_id, comp)
	end

elseif not want_y_inverted and EntityHasTag(entity_id, "y_inverted") then
	EntityRemoveTag(entity_id, "y_inverted")

	local x, y, rot, scale_x, scale_y = EntityGetTransform(entity_id)
	EntitySetTransform(entity_id, x, y, rot, scale_x, -scale_y)

	for _, comp in ipairs(EntityGetAllComponents(entity_id)) do
		invert_component_gravity(comp)
	end

end
