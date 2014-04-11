local base = {}
function base:accessor(name)
	local first, rest = name:sub(1,1), name:sub(2)
	self["get" .. first:upper() .. rest] = function (tab)
		return tab[first:lower() .. rest]
	end

	self["set" .. first:upper() .. rest] = function (tab, value)
		tab[first:lower() .. rest] = value
	end
end

function base:loadInstance(saveTable, ...)
	local inst = {}
	setmetatable(inst, self)
	if inst.load then
		inst:load(saveTable, ...)
	end
	return inst
end

function base:saveInstance(inst, ...)
	local tab = {}
	if inst.save then
		inst:save(tab, ...)
	end
	return tab
end

function class(parent)
	parent = parent or base
	local t = {}
	local meta = {}
	t.__index = t
	t.__meta = meta
	meta.__index = parent
	meta.__call = function (self, ...)
		local inst = {}
		setmetatable(inst, self)
		if inst.initialize then
			inst:initialize(...)
		end
		return inst
	end
	meta.__mul = function (self, other)
		local inst = {}
		setmetatable(inst, self)
		if inst.load then
			inst:load(other)
		end
		return inst
	end
	setmetatable(t, meta)
	return t
end

function setClass(inst, class)
	if inst && class then
		setmetatable(inst, class)
		if inst.setClass then
			inst:setClass()
		end
	end
end

function saveClass(inst, ...)
	if inst then
		if inst.save then
			local tab = {}
			inst:save(tab, ...)
			return tab
		end
		return {}
	end
end

function loadClass(class, saveTable, ...)
	if class && saveTable then
		return class:loadInstance(saveTable, ...)
	end
end
