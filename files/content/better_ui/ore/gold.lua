local ORE = "gold"
local VARIABLE = "fairmod_" .. ORE .. "_detected"

function material_area_checker_failed( pos_x, pos_y)
	GamePrint("no gold")
	GlobalsSetValue(VARIABLE, "0")
end

function material_area_checker_success( pos_x, pos_y)
	GamePrint("GOLD")
	GlobalsSetValue(VARIABLE, "1")
end
