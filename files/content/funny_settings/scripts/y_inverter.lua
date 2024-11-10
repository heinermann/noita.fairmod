
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


local function invert_component_gravity(entity, comp, adding)

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

		local col_min_y = ComponentGetValue2(comp, "collision_aabb_min_y")
		local col_max_y = ComponentGetValue2(comp, "collision_aabb_max_y")
		ComponentSetValue2(comp, "collision_aabb_min_y", -col_max_y)
		ComponentSetValue2(comp, "collision_aabb_max_y", - col_min_y)

	elseif comp_name == "CharacterPlatformingComponent" then
		invert_component_value(comp, "pixel_gravity")
		invert_component_value(comp, "jump_velocity_y")
		invert_component_value(comp, "swim_idle_buoyancy_coeff")
		invert_component_value(comp, "swim_down_buoyancy_coeff")
		invert_component_value(comp, "swim_up_buoyancy_coeff")
		if adding then
			ComponentSetValue2(comp, "fly_speed_mult", -ComponentGetValue2(comp, "fly_speed_mult")/2)
		else
			ComponentSetValue2(comp, "fly_speed_mult", -ComponentGetValue2(comp, "fly_speed_mult")*2)
		end

		--local vel_min_y = ComponentGetValue2(comp, "velocity_min_y")
		--local vel_max_y = ComponentGetValue2(comp, "velocity_max_y")
		--ComponentSetValue2(comp, "velocity_min_y", vel_max_y)
		--ComponentSetValue2(comp, "velocity_max_y", vel_min_y)
	elseif comp_name == "PhysicsBodyComponent" then
		ComponentSetValue2(comp, "gravity_scale_if_has_no_image_shapes", -ComponentGetValue2(comp, "gravity_scale_if_has_no_image_shapes") - 1)

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
	elseif comp_name == "SpriteComponent" then
		--invert_component_value(comp, "offset_y")
	end
end

local entity_id = GetUpdatedEntityID()
local want_y_inverted = ModSettingGet("noita.fairmod.invert_y_axis")

-- Change properties only when the setting changes
if want_y_inverted and not EntityHasTag(entity_id, "y_inverted") then
	EntityAddTag(entity_id, "y_inverted")

	local x, y, rot, scale_x, scale_y = EntityGetTransform(entity_id)
	EntitySetTransform(entity_id, x, y, rot, scale_x, -scale_y)

	for _, comp in ipairs(EntityGetAllComponents(entity_id)) do
		invert_component_gravity(entity_id, comp, true)
	end


elseif not want_y_inverted and EntityHasTag(entity_id, "y_inverted") then
	EntityRemoveTag(entity_id, "y_inverted")

	local x, y, rot, scale_x, scale_y = EntityGetTransform(entity_id)
	EntitySetTransform(entity_id, x, y, rot, scale_x, -scale_y)

	for _, comp in ipairs(EntityGetAllComponents(entity_id)) do
		invert_component_gravity(entity_id, comp, false)
	end

end

-- Logic run on every frame
if want_y_inverted then
	local x, y = EntityGetTransform(entity_id)
	local components = EntityGetComponent(entity_id, "CharacterDataComponent")

	if components ~= nil then
		for _, comp in ipairs(components) do
			local coll_y = ComponentGetValue2(comp, "collision_aabb_min_y")

			local hit = RaytracePlatforms(x, y, x, y + coll_y - 1)
			if not hit then
				local coll_x1 = ComponentGetValue2(comp, "collision_aabb_min_x")
				hit = RaytracePlatforms(x + coll_x1, y, x + coll_x1, y + coll_y - 1)
				if not hit then
					local coll_x2 = ComponentGetValue2(comp, "collision_aabb_max_x")
					hit = RaytracePlatforms(x + coll_x2, y, x + coll_x2, y + coll_y - 1)
				end
			end

			ComponentSetValue2(comp, "is_on_ground", hit)

			if hit then
				ComponentSetValue2(comp, "mFramesOnGround", ComponentGetValue2(comp, "mFramesOnGround") + 1)
				ComponentSetValue2(comp, "mLastFrameOnGround", GameGetFrameNum())
			else
				if ComponentGetValue2(comp, "mLastFrameOnGround") == GameGetFrameNum() then
					local vx, vy = ComponentGetValue2(comp, "mVelocity")
					ComponentSetValue2(comp, "mVelocity", vx, -9.8)
				end

				ComponentSetValue2(comp, "mFramesOnGround", 0)
			end
		end
	end
end
