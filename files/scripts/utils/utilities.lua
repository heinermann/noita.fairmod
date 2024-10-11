---@param ... table
---@return table
function MergeTables(...)
	local tables = {...}
	local out = {}
	for _,t in ipairs(tables) do
		for k,v in pairs(t) do
			out[k] = v
		end
	end
	return out
end

---@return number[]
function GetPlayers()
	return MergeTables(EntityGetWithTag("player_unit") or {}, EntityGetWithTag("polymorphed_player") or {}) or {}
end

---@return number
function GetPlayer()
	return GetPlayers()[1]
end

---@param x number
---@param y number
---@param radius number
---@return number[]
function GetEnemiesInRadius(x, y, radius)
	return MergeTables(EntityGetInRadiusWithTag(x, y, radius, "enemy"), EntityGetInRadiusWithTag(x, y, radius, "boss"))
end

---@param component_id number
---@param values table<string, any>?
function SetComponentValues(component_id, values)
	for k,v in pairs(values or {}) do
		ComponentSetValue2(component_id, k, v)
	end
end
