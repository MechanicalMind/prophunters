

function IncludeCompile(file, g)
	local rootFolder = (GM or GAMEMODE).Folder:sub(11) .. "/gamemode/"
	local globalMeta = {}
	globalMeta.__index = _G
	globalMeta.__newindex = function (self, key, value)
		_G[key] = value
	end

	setmetatable(g, globalMeta)

	AddCSLuaFile(rootFolder .. "sh_config.lua")

	local f = CompileFile(rootFolder .. "sh_config.lua")
	if !f then
		print("File doesn't exists " .. rootFolder .. "sh_config.lua")
		return
	end
	setfenv(f, g)
	return f()
end

local g = {}
IncludeCompile("sh_config.lua", g)
