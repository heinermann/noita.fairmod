--- World utils - automatic pixel scene relocator through map fuckery.
--- (by Heinermann)

dofile_once("mods/noita.fairmod/files/lib/compatibility.lua")

local graph = require("luagraphs.data.graph")
local connected_components = require('luagraphs.connectivity.ConnectedComponents')

local vec2 = dofile_once("mods/noita.fairmod/files/scripts/utils/vec2.lua") --- @type vec2

local world_utils = {}


local function dbg_print_lua_table(tbl, visited, depth)
	if visited == nil then visited = {} end
	if depth == nil then depth = 0 end

	visited[tbl] = true

	local prefix = string.rep("  ", depth)
	print(prefix .. "{")
	for k, v in pairs(tbl) do
		if type(v) == "string" then
			print(prefix .. tostring(k) .. " = \"" .. tostring(v) .. "\",")
		elseif type(v) == "table" then
			print(prefix .. tostring(k) .. " = ")
			dbg_print_lua_table(v, visited, depth + 1)
		else
			print(prefix .. tostring(k) .. " = " .. tostring(v) .. ",")
		end
	end
	print(prefix .. "},")
end


local function read_world_file(world_filename)
	local id, width, height = ModImageMakeEditable(world_filename, 1, 1)
	if id == 0 or width == 1 or height == 1 then
		error("Failed to read world file: " .. tostring(world_filename))
		return nil
	end

	local pixel_map = {
		width = width,
		height = height,
		x_left =  math.floor(-width / 2 + 1),
		x_right = math.floor(width / 2 + 1),
		zero = math.floor(width / 2 - 1),
		data = {},
	}
	for x = 0, width - 1 do
		pixel_map.data[x + pixel_map.x_left] = {}
		for y = 0, height-1 do
			pixel_map.data[x + pixel_map.x_left][y] = ModImageGetPixel(id, x, y)
		end
	end

	return pixel_map
end

local function get_world_description(pixels)
	-- Rough ideal structure
	--	{
	--		color = {
	--			{	-- chunk description 1
	--				shape_str = "3x2_111100100",
	--				shape = { {1, 1, 1}, {1, 0, 0}, {1, 0, 0} },
	--              x, y,
	-- 				left, top, right, bottom, width, height,
	--			},
	--			{	-- chunk description 2
	--				-- ...
	--			}
	--		}
	--	}


	-- STEP 1: Create mapping of biome pixels to list of coordinates with the same colour.

	-- After this, pass1 should be { colour1 = { {x1, y1}, {x2, y2}, ... }, colour2 = ... }
	local pass1 = {}
	for y = 0, pixels.height - 1 do
		for x = pixels.x_left, pixels.x_right do
			local biome = pixels.data[x][y]
			if pass1[biome] == nil then
				pass1[biome] = {}
			end

			table.insert(pass1[biome], vec2.new(x, y))
		end
	end

	-- STEP 2: Create graph connecting each adjacent same-biome pixel.
	-- STEP 3: Run connected components on said graphs (for each biome).
	--         This creates clusters of each contiguous same-biome area.

	-- After this, pass2 should be { colour1 = { graph = {...}, connections = {...} }, colour2 = ... }.
	-- When the graph is constructed, the coordinates are converted to strings to work properly with the library.
	-- TODO: This is not performant and can be fixed by updating the lib to work with coordinates.
	-- connections will have a vertex to id mapping, { ["x1, y1"] = 0, ["x2, y2"] = 0, ["x3, y3"] = 1, ... }
	-- The ids are incremental from 0.
	local pass2 = {}
	for biome, data in pairs(pass1) do
		if pass2[biome] == nil then
			pass2[biome] = {
				graph = graph.create(),
				connections = connected_components.create()
			}
		end

		for _, pos in ipairs(pass1[biome]) do
			local pos_str = tostring(pos)

			-- Ensure there is a vertex for this coordinate
			pass2[biome].graph:addVertexIfNotExists(pos_str)

			-- Since we are iterating everything and this is an undirected graph,
			-- links don't need to be added in the reverse direction.
			if pixels.data[pos.x + 1] ~= nil and pixels.data[pos.x + 1][pos.y] == biome then
				pass2[biome].graph:addEdge(pos_str, tostring(vec2.new(pos.x + 1, pos.y)))
			end
			if pixels.data[pos.x][pos.y + 1] == biome then
				pass2[biome].graph:addEdge(pos_str, tostring(vec2.new(pos.x, pos.y + 1)))
			end
		end

		-- connected components will have a mapping from vertex to id
		pass2[biome].connections:run(pass2[biome].graph)
	end


	-- STEP 4: TODO
	-- 5. Generate final description with the center's x/y, bounds, and shape_str.
	local pass3 = {}
	for biome, data in pairs(pass2) do
		for v, id in ipairs(data.connections.id) do
			if pass3[biome] == nil then
				pass3[biome] = {}
			end
			if pass3[biome][id + 1] == nil then
				pass3[biome][id + 1] = {}
			end

			-- TODO
		end
	end

	local result = {}

	return result
end

function world_utils.generate_world_diff(from_world, to_world)
	local from_pixels = read_world_file(from_world)
	local to_pixels = read_world_file(to_world)

	if from_pixels == nil or to_pixels == nil then
		error("Pixel scene relocation failed: Unable to read a world file.")
		return nil
	end

	local gen_diff = {}

	-- TODO:
	-- 1. Get biome clusters/groupings. There can be more than 1 grouping per biome.
	-- 2. Create shape strings or hashes for each.
	--		Allows easily checking the difference between moved biomes vs resized biomes.
	-- 3. Compare the two world descriptions. (N^2 comparisons within each one colour between groups)
	--		- Check whether a grouping moved (easy, no size change).
	--			Obvious location for scenes.
	--      - Check whether a grouping was moved + resized (hard).
	--			Scenes can easily be moved to their new location by stretching the location over the new size.
	--      - Check whether a grouping was moved + appended (medium).
	--			Scene locations become non-obvious. i.e. suppose someone extended a biome around the entire map, well now you can't tell where it should go.
	-- 4. Create new array with mapping of (from_x, from_y) -> (to_x, to_y).
	return gen_diff
end

-- NOTE: also need to check whether the scene is located in the main world

-- Pixel scene description:
--	{
--		{
--			x, y, width, height,
--			data = (scene tracking data, i.e. nxml node, we'll let the caller modify it)
--		},
--		...
--	}

function world_utils.relocate_pixel_scenes(scenes, world_diff)
	-- Relocate scenes based on the provided world diff.
end

return world_utils
