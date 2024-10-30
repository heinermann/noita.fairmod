-- What I want to do is,
--  1. The first statue should have a chance of kicking you back into the collapsing mountain.
--  2. It also kicks back teleport projectiles.
--  3. After that then ??? w/e

-- The first statue should do melee
-- The second should buff the other two
-- The third should do ranged

local nxml = dofile_once("mods/noita.fairmod/files/lib/nxml.lua") --- @type nxml

---@param path string
local function add_teleport_tag(path)
	for xml in nxml.edit_file("data/entities/projectiles/deck/" .. path .. ".xml") do
		xml:set((xml:get("tags") or "") .. ",teleport_projectile")
	end
end

add_teleport_tag("teleport_cast")
add_teleport_tag("super_teleport_cast")
add_teleport_tag("teleport_projectile")
add_teleport_tag("teleport_projectile_short")
add_teleport_tag("teleport_projectile_static")
add_teleport_tag("teleport_projectile_closer")


