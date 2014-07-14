

Taunts = {}
TauntCategories = {}
AllowedTauntSounds = {}

local function addTaunt(name, snd, pteam, sex, cats, duration)
	if type(snd) != "table" then snd = {snd} end
	if #snd == 0 then error("No sounds for " .. name) return end

	local t = {}
	t.sound = snd
	t.categories = cats
	if type(pteam) == "string" then
		pteam = pteam:lower()
		if pteam == "prop" || pteam == "props" then
			t.team = 3
		elseif pteam == "hunter" || pteam == "hunters" then
			t.team = 2
		end
	else
		t.team = tonumber(pteam)
	end
	if sex && #sex > 0 then
		t.sex = sex
		if sex == "both" then
			t.sex = nil
		end
	end
	t.name = name

	local dur, count = 0, 0
	for k, v in pairs(snd) do
		if !AllowedTauntSounds[v] then AllowedTauntSounds[v] = {} end
		table.insert(AllowedTauntSounds[v], t)
		dur = dur + SoundDuration(v)
		count = count + 1

		if SERVER then
			// network the taunt
			resource.AddFile("sound/" .. v)
		end
	end

	t.soundDuration = dur / count
	if tonumber(duration) then
		t.soundDuration = tonumber(duration)
		t.soundDurationOverride = tonumber(duration)
	end

	table.insert(Taunts, t)
	for k, cat in pairs(cats) do
		if !TauntCategories[cat] then TauntCategories[cat] = {} end
		table.insert(TauntCategories[cat], t)
	end
end

local tempG = {}
tempG.addTaunt = addTaunt

// inherit from _G
local meta = {}
meta.__index = _G
meta.__newindex = _G
setmetatable(tempG, meta)

local function loadTaunts(rootFolder)
	local files, dirs = file.Find(rootFolder .. "*", "LUA")
	for k, v in pairs(files) do
		AddCSLuaFile(rootFolder .. v)

		local name = v:sub(1, -5)
		local f = CompileFile(rootFolder .. v)
		if !f then
			return
		end
		setfenv(f, tempG)
		local b, err = pcall(f)

		local s = SERVER and "Server" or "Client"
		local b = SERVER and 90 or 0
		if !b then
			MsgC(Color(255, 50, 50 + b), s .. " loading taunts failed " .. name .. ".lua\nError: " .. err .. "\n")
		else
			MsgC(Color(50, 255, 50 + b), s .. " loaded taunts file " .. name .. ".lua\n")
		end
	end
end

function GM:LoadTaunts()
	loadTaunts((GM or GAMEMODE).Folder:sub(11) .. "/gamemode/taunts/")
	loadTaunts("prophunters/taunts/")
end

GM:LoadTaunts()