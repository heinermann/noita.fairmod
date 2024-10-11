-- Collection of many props tweaked en mass
--  * Emits 20x more particles
--  * Bleeds 10x more
--  * Anything with a material inventory gets launched when hit
--  * 25x more material dropped on entity death

local nxml = dofile("mods/noita.fairmod/files/lib/nxml.lua") --- @type nxml
dofile_once("mods/noita.fairmod/files/scripts/utils/utilities.lua")
local prop_files = dofile("mods/noita.fairmod/files/content/better_props/prop_files.lua")

---Multiplies a nxml element's attribute by a multiplier if it exists
---@param component element
---@param name string
---@param multiplier number
local function elem_multiply_attr(component, name, multiplier)
  if component:get(name) then
    component:set(name, tonumber(component:get(name)) * multiplier)
  end
end

---Applies changes to the given prop xml element.
---@param element element
local function fixup_prop_children(element)
  if element == nil then return end

  -- Emit lots of materials
  for comp in element:each_of("ParticleEmitterComponent") do
    comp:set("create_real_particles", 1)
    comp:set("emit_cosmetic_particles", 0)
    elem_multiply_attr(comp, "count_min", 20)
    elem_multiply_attr(comp, "count_max", 20)
  end

  -- Bleed a lot, and increase max HP for other effects
  for comp in element:each_of("DamageModelComponent") do
    comp:set("blood_multiplier", 10)
    -- better chance to see things fly around instead of exploding immediately
    elem_multiply_attr(comp, "hp", 3)
  end

  -- Add more materials, leakage, pressure, and nonsense to material inventories
  for comp in element:each_of("MaterialInventoryComponent") do
    comp:set("leak_pressure_min", 10)
    comp:set("leak_pressure_max", 100)
    comp:set("b2_force_on_leak", 5)
    comp:set("on_death_spill", 1)
    comp:set("leak_on_damage_percent", 0.999)

    for mat_count in comp:each_of("count_per_material_type") do
      for mat in mat_count:each_of("Material") do
        elem_multiply_attr(mat, "count", 25)
      end
    end
  end
end

-- Modify all supported prop XMLs
for _, prop_file in ipairs(prop_files) do
  for prop_xml in nxml.edit_file(prop_file) do
    fixup_prop_children(prop_xml)
    fixup_prop_children(prop_xml:first_of("Base"))

    prop_xml:set("tags", (prop_xml:get("tags") or "") .. ",fuckedprop")
  end
end

----
Props = {
  scanned = {}
}

local solid_component_types = {
  "PhysicsBodyComponent",
  "PhysicsBody2Component",
  "PhysicsImageShapeComponent",
  "DamageModelComponent",
  "PhysicsShapeComponent",
}

local enabled_in_hand_types = {
  SpriteParticleEmitterComponent = 1,
  AudioComponent = 1,
  AudioLoopComponent = 1,
  MusicEnergyAffectorComponent = 1,
  ParticleEmitterComponent = 1,
  LightComponent = 1,
  SpriteComponent = 1,
  ElectricChargeComponent = 1,
  ElectricitySourceComponent = 1,
  LuaComponent = 1,
  TorchComponent = 1,
  GameEffectComponent = 1,
  MagicConvertMaterialComponent = 1,
}

---Modifies the first occurrence of the given component type, otherwise creates one with those values.
---@param entity number
---@param component_type string
---@param values table<string,any>?
---@return number
local function SetOrAddComponent(entity, component_type, values)
  local component = EntityGetFirstComponent(entity, component_type)
  if component ~= nil then
    SetComponentValues(component, values)
  else
    component = EntityAddComponent2(entity, component_type, values or {})
  end
  ComponentAddTag(component, "enabled_in_world")
  return component
end

local function make_pickable_entity(entity)
  if EntityHasTag(entity, "enemy") or EntityHasTag(entity, "boss") then return end

  local is_solid = false
  for _,component_type in ipairs(solid_component_types) do
    if EntityGetFirstComponent(entity, component_type) ~= nil then
      is_solid = true
      break
    end
  end
  if is_solid == false then return end

  for _, comp in ipairs(EntityGetAllComponents(entity)) do
    if ComponentGetIsEnabled(comp) then
      ComponentAddTag(comp, "enabled_in_world")

      if enabled_in_hand_types[ComponentGetTypeName(comp)] then
        ComponentAddTag(comp, "enabled_in_hand")
      end
    end
  end

  EntityAddTag(entity, "item_physics")
  EntityAddTag(entity, "item_pickup")

  local phys_shape = EntityGetFirstComponent(entity, "PhysicsImageShapeComponent")
  local image_file = "data/items_gfx/emerald_tablet.png"
  if phys_shape ~= nil then
    image_file = ComponentGetValue2(phys_shape, image_file)
  end

  local phys_body1 = EntityGetFirstComponent(entity, "PhysicsBodyComponent")
  if phys_body1 ~= nil then
    SetComponentValues(phys_body1, {
      is_bullet = 1,
      hax_fix_going_through_ground = 1,
      angular_damping = 0,
      fixed_rotation = 0,
      allow_sleep = 1,
      linear_damping = 0,
      auto_clean = 1,
      on_death_leave_physics_body = 1,
    })
  end

  local phys_body2 = EntityGetFirstComponent(entity, "PhysicsBody2Component")
  if phys_body2 ~= nil then
    SetComponentValues(phys_body2, {
      is_bullet = 1,
      hax_fix_going_through_ground = 1,
      kill_entity_after_initialized = 0,
      angular_damping = 0,
      fixed_rotation = 0,
      allow_sleep = 1,
      linear_damping = 0,
      auto_clean = 1,
    })
  end


  SetOrAddComponent(entity, "ItemComponent", {
    max_child_items = 2,
    is_pickable = 1,
		is_equipable_forced = 1,
    ui_sprite = image_file,
    preferred_inventory = "QUICK",
    play_spinning_animation = 0,
    item_name = "TODO",
    ui_description = "TODO",
  })

  local ability = EntityAddComponent2(entity, "AbilityComponent", {
    ui_name = "TODO",
    throw_as_item = 1,
  })
  ComponentObjectSetValue2(ability, "gun_config", "deck_capacity", 0)

  SetOrAddComponent(entity, "PhysicsThrowableComponent")
  SetOrAddComponent(entity, "PhysicsBodyCollisionDamageComponent")
  SetOrAddComponent(entity, "VelocityComponent", {
    affect_physics_bodies = 1,
  })
  SetOrAddComponent(entity, "UIInfoComponent", {
    name = "TODO",
  })
  SetOrAddComponent(entity, "ProjectileComponent", {
    penetrate_entities = 1,
  })

  local held_gfx = EntityAddComponent2(entity, "SpriteComponent", {
		offset_x = 4,
		offset_y = 4,
    image_file = image_file,
  })
  ComponentAddTag(held_gfx, "enabled_in_hand")
  EntitySetComponentIsEnabled(entity, held_gfx, false)

  
end


function Props.OnWorldPreUpdate()
	local props = EntityGetWithTag("fuckedprop")

	for _, prop in ipairs(props) do
		if not Props.scanned[prop] then
      Props.scanned[prop] = true
      make_pickable_entity(prop)
		end
	end
end

