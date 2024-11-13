-- Required for luagraphs, which uses `require`.

local MODULE_PREFIX = "mods/noita.fairmod/files/lib/"

function require(modulename)
	local filename = MODULE_PREFIX .. modulename:gsub("%.", "/")

	if not ModDoesFileExist(filename) then
		error("Failed to find lib module: " .. tostring(modulename))
	end
	return dofile_once(filename)
end
