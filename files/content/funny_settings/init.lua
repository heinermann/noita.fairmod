local nxml = dofile_once("mods/noita.fairmod/files/lib/nxml.lua") --- @type nxml
dofile_once("mods/noita.fairmod/files/scripts/utils/utilities.lua")


local function escape(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
end

local shader_append = function(path, find, append)
	-- add to next line
	local file = ModTextFileGetContent(path)
	local pos = string.find(file, escape(find))
	if pos then
		local pos2 = string.find(file, "\n", pos)
		if pos2 then
			local before = string.sub(file, 1, pos2)
			local after = string.sub(file, pos2 + 1)
			ModTextFileSetContent(path, before .. append .. after)
		end
	end
end

shader_append("data/shaders/post_final.frag",
	"varying vec2 tex_coord_fogofwar;",
	[[
uniform vec4 COLORBLIND_MODE_ON;
uniform vec4 INVERT_Y_AXIS_ON;
uniform vec4 LOWER_RESOLUTION_RENDERING_ON;
uniform vec4 _8_BIT_COLOR_ON;
	]]
)

shader_append("data/shaders/post_final.vert",
	"varying vec2 tex_coord_fogofwar;",
	[[
uniform vec4 COLORBLIND_MODE_ON;
uniform vec4 INVERT_Y_AXIS_ON;
uniform vec4 LOWER_RESOLUTION_RENDERING_ON;
uniform vec4 _8_BIT_COLOR_ON;
	]]
)

shader_append("data/shaders/post_final.frag",
	"gl_FragColor.a = 1.0;",
	[[
	if(COLORBLIND_MODE_ON.x == 1.0) {
		vec3 color = pow(gl_FragColor.rgb, vec3(2.0));
		// grayscale conversion
		float gray = dot(color, vec3(0.2126, 0.7152, 0.0722));
		// regamma
		float gammaGray = sqrt(gray);
		gl_FragColor.rgb = vec3(gammaGray, gammaGray, gammaGray);
	}
	if(_8_BIT_COLOR_ON.x == 1.0) {
		gl_FragColor.r = floor(gl_FragColor.r * 3.0) / 3.0;
		gl_FragColor.g = floor(gl_FragColor.g * 7.0) / 7.0;
		gl_FragColor.b = floor(gl_FragColor.b * 7.0) / 7.0;
	}
]]
)

shader_append("data/shaders/post_final.frag",
	"vec2 tex_coord_glow = tex_coord_glow_;",
	[[
	if(LOWER_RESOLUTION_RENDERING_ON.x == 1.0) {

		float resolution_factor = 0.5;
		vec2 screen_size = vec2(SCREEN_W, SCREEN_H) * resolution_factor;

		tex_coord = vec2(floor(tex_coord.x * screen_size.x) / screen_size.x, floor(tex_coord.y * screen_size.y) / screen_size.y);
		tex_coord_y_inverted = vec2(floor(tex_coord_y_inverted.x * screen_size.x) / screen_size.x, floor(tex_coord_y_inverted.y * screen_size.y) / screen_size.y);
		tex_coord_glow = vec2(floor(tex_coord_glow.x * screen_size.x) / screen_size.x, floor(tex_coord_glow.y * screen_size.y) / screen_size.y);

	}
]]
)

shader_append("data/shaders/post_final.vert",
	"world_pos = camera_pos + tex_coord_y_inverted_ * world_viewport_size;",
	[[
	if(INVERT_Y_AXIS_ON.x == 1.0) {
		tex_coord_ = vec2(tex_coord_.x, 1.0 - tex_coord_.y);
		tex_coord_y_inverted_ = vec2(tex_coord_y_inverted_.x, 1.0 - tex_coord_y_inverted_.y);
		tex_coord_glow_ = vec2(tex_coord_glow_.x, 1.0 - tex_coord_glow_.y);
		world_pos = camera_pos + vec2(tex_coord_y_inverted_.x, 1.0 - tex_coord_y_inverted_.y) * world_viewport_size;
	}
]]
)


local function invert_value(cell, name, default_value)
	if default_value == nil then
		local value = cell:get(name)
		if value ~= nil then
			cell:set(name, -tonumber(value))
		end
	else
		cell:set(name, -tonumber(cell:get(name) or tostring(default_value)))
	end
end


local material_files = {
	"data/materials.xml",
	"mods/noita.fairmod/files/content/entrance_cart/bouncy_metal.xml"
}


local box2d_mats = {}
for _, mat_file in ipairs(material_files) do
	for xml in nxml.edit_file(mat_file) do
		for cell in xml:each_of("CellData") do
			if (cell:get("tags") or ""):match("%[box2d%]") then
				box2d_mats[cell:get("name")] = 1
			end
		end

		for cell in xml:each_of("CellDataChild") do
			if cell:get("tags") == nil then
				if box2d_mats[cell:get("_parent")] then
					box2d_mats[cell:get("name")] = 1
				end
			elseif cell:get("tags"):match("%[box2d%]") then
				box2d_mats[cell:get("name")] = 1
			end
		end
	end
end

-- Create inverted materials
local wang_color = 0xfe3b5e00
local function next_wang()
	wang_color = wang_color + 1
	return string.format("%08x", wang_color)
end

for _, mat_file in ipairs(material_files) do
	for xml in nxml.edit_file(mat_file) do
		for cell in xml:each_of("CellData") do
			if box2d_mats[cell:get("name")] then
				xml:add_child(nxml.new_element("CellDataChild", {
					_parent = cell:get("name"),
					_inherit_reactions = 1,
					name = cell:get("name") .. "_fairmod_inverted",
					ui_name = cell:get("ui_name"),
					wang_color = next_wang(),
					solid_gravity_scale = -tonumber(cell:get("solid_gravity_scale") or "1")
				}))
			end
		end

		for cell in xml:each_of("CellDataChild") do
			if box2d_mats[cell:get("name")] then
				xml:add_child(nxml.new_element("CellDataChild", {
					_parent = cell:get("name"),
					_inherit_reactions = 1,
					name = cell:get("name") .. "_fairmod_inverted",
					ui_name = cell:get("ui_name"),
					wang_color = next_wang(),
					solid_gravity_scale = -tonumber(cell:get("solid_gravity_scale") or "1")
				}))
			end
		end
	end
end

local material_id_cache_initialized = false
local material_id_invert_cache = {}

local function initialize_material_id_cache()
	if material_id_cache_initialized then return end

	for mat_name,_ in pairs(box2d_mats) do
		local id = CellFactory_GetType(mat_name)
		local id_inverted = CellFactory_GetType(mat_name .. "_fairmod_inverted")

		material_id_invert_cache[id] = id_inverted
	end
end


local module = {}

module.OnPausedChanged = function()
	local colorblind_mode = ModSettingGet("noita.fairmod.colorblind_mode")
	if colorblind_mode then
		GameSetPostFxParameter("COLORBLIND_MODE_ON", 1, 0, 0, 0)
	else
		GameSetPostFxParameter("COLORBLIND_MODE_ON", 0, 0, 0, 0)
	end

	local invert_y_axis = ModSettingGet("noita.fairmod.invert_y_axis")
	if invert_y_axis then
		GameSetPostFxParameter("INVERT_Y_AXIS_ON", 1, 0, 0, 0)
	else
		GameSetPostFxParameter("INVERT_Y_AXIS_ON", 0, 0, 0, 0)
	end

	local lower_resolution_rendering = ModSettingGet("noita.fairmod.lower_resolution_rendering")
	if lower_resolution_rendering then
		GameSetPostFxParameter("LOWER_RESOLUTION_RENDERING_ON", 1, 0, 0, 0)
	else
		GameSetPostFxParameter("LOWER_RESOLUTION_RENDERING_ON", 0, 0, 0, 0)
	end

	local _8_bit_color = ModSettingGet("noita.fairmod.8_bit_color")
	if _8_bit_color then
		GameSetPostFxParameter("_8_BIT_COLOR_ON", 1, 0, 0, 0)
	else
		GameSetPostFxParameter("_8_BIT_COLOR_ON", 0, 0, 0, 0)
	end
end

module.OnPlayerSpawned = function(player)
	initialize_material_id_cache()
	module.OnPausedChanged()

	if GameHasFlagRun("fairmod_init") then return end

	EntityAddComponent2(player, "LuaComponent", {
		script_source_file = "mods/noita.fairmod/files/content/funny_settings/scripts/player_update.lua",
		execute_every_n_frame = 1,
		execute_on_added = true,
	})
end

local function add_component_to_entity(entity)
	if EntityHasTag(entity, "invert_y_tracked") then return end

	EntityAddTag(entity, "invert_y_tracked")
	EntityAddComponent2(entity, "LuaComponent", {
		script_source_file = "mods/noita.fairmod/files/content/funny_settings/scripts/y_inverter.lua",
		execute_every_n_frame = 1,
		execute_on_added = true,
	})
end

local last_y_setting = nil
module.OnWorldPreUpdate = function()
	if GameGetFrameNum() % 30 == 0 then
		local x, y = GameGetCameraPos()
		local entities = EntityGetInRadius(x, y, 512)

		for _, entity in ipairs(entities) do
			add_component_to_entity(entity)
		end
	end

	local new_y_setting = ModSettingGet("noita.fairmod.invert_y_axis")
	if new_y_setting ~= last_y_setting then
		last_y_setting = new_y_setting

		for id, inverted_id in pairs(material_id_invert_cache) do
			if new_y_setting then
				ConvertMaterialEverywhere(id, inverted_id)
			else
				ConvertMaterialEverywhere(inverted_id, id)
			end
		end
	end

	if new_y_setting then
		local cam_x, cam_y, cam_w, cam_h = GameGetCameraBounds()

		local bodies = PhysicsBodyIDQueryBodies(cam_x, cam_y, cam_x + cam_w, cam_y + cam_h, true, true)
		for _, body in ipairs(bodies) do
			local gravity = PhysicsBodyIDGetGravityScale(body)
			if gravity > 0 then
				PhysicsBodyIDSetGravityScale(body, -gravity)
			end
		end
	end
end

return module
