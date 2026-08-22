local nxml = dofile_once("mods/noita.fairmod/files/lib/nxml.lua") --- @type nxml

ModLuaFileAppend(
    "data/scripts/perks/perk_list.lua",
    "mods/noita.fairmod/files/content/no_comma_more_knockback/perk.lua"
)

for xml in nxml.edit_file("data/entities/misc/effect_knockback.xml") do
	xml:create_child("LuaComponent", {
		script_source_file = "mods/noita.fairmod/files/content/no_comma_more_knockback/knocked.lua",
		remove_after_executed = 1,
	})
end
