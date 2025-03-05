local nxml = dofile_once("mods/noita.fairmod/files/lib/nxml.lua") --- @type nxml

local chest_random_append = "mods/noita.fairmod/files/content/more_orbs/chest_random_append.lua"
local append_to = {
	"data/scripts/items/chest_random.lua",
	"data/scripts/items/chest_random_super.lua",
	"data/scripts/items/utility_box.lua",
}

for _, script in ipairs(append_to) do
	ModLuaFileAppend(script, chest_random_append)
end
