---@class vec2
---@field x number
---@field y number
local vec2 = {}

vec2.__index = vec2

---@param x number
---@param y number
---@return vec2
function vec2.new(x, y)
	local vec = {}
	setmetatable(vec, vec2)

	vec.x = x
	vec.y = y

	return vec
end

---@param other vec2
---@return vec2
function vec2:__add(other)
	return vec2.new(self.x + other.x, self.y + other.y)
end

---@param other vec2
---@return vec2
function vec2:__sub(other)
	return vec2.new(self.x - other.x, self.y - other.y)
end

---@param value number
---@return vec2
function vec2:__mul(value)
	return vec2.new(self.x * value, self.y * value)
end

---@param value number
---@return vec2
function vec2:__div(value)
	return vec2.new(self.x / value, self.y / value)
end

---@return vec2
function vec2:__unm()
	return vec2.new(-self.x, -self.y)
end

---@param other vec2
---@return boolean
function vec2:__eq(other)
	return self.x == other.x and self.y == other.y
end

---@return integer
function vec2:__len()
	return 2
end

---@param key number|string
---@return number
function vec2:__index(key)
	if key == 1 then
		return self.x
	elseif key == 2 then
		return self.y
	else
		return self[key]
	end
end

---@param key number|string
---@param value number
function vec2:__newindex(key, value)
	if key == 1 then
		self.x = value
	elseif key == 2 then
		self.y = value
	else
		self[key] = value
	end
end

---@return number x
---@return number y
function vec2:__call()
	return x, y
end

---@return string
function vec2:__tostring()
	return tostring(self.x) .. ", " .. tostring(self.y)
end

---@return string
function vec2:__name()
	return "vec2"
end

---@param str string
---@return vec2
function vec2.from_string(str)
	local x, y = str:match("(.+),(.+)")
	return vec2.new(tonumber(x, 10), tonumber(y, 10))
end
