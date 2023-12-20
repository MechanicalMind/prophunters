local url = "https://raw.githubusercontent.com/mechanicalmind/prophunters/master/prophunters.txt"
local downloadlinks = "https://github.com/mechanicalmind/prophunters/releases or http://steamcommunity.com/sharedfiles/filedetails/?id=260275546"


function GM:CheckForNewVersion(ply)
	local req = {}
	req.url = url
	req.failed = function (reason)
		print("Couldn't get version file", reason)
	end
	req.success = function (code, body, headers)
		local tab = util.KeyValuesToTable(body)
		if !tab || !tab.version then
			print("Couldn't parse version file")
			return
		end
		local t = MsgClients()
		if tab.version != GAMEMODE.Version then
			t:Add("Out of date. ", Color(215, 20, 20))
		end
		t:Add("Latest version is " .. tab.version, color_white)
		if tab.version != GAMEMODE.Version then
			t:Add(". Current version is " .. tostring(GAMEMODE.Version or "error"))
			t:Add(". Download the latest version from " .. downloadlinks)
		else
			t:Add(". Up to date")
		end
		t:Add("\n")
		if ply then
			t:Send(ply)
		else
			t:Print()
			local ct = ChatText(t.msgs)
			for k, v in pairs(player.GetAll()) do
				if v:IsListenServerHost() || v:IsSuperAdmin() then
					ct:Send(v)
				end
			end
		end
	end
	HTTP(req)
end

concommand.Add("ph_version", function (ply)
	local t = MsgClients()
	t:Add("Prophunters by Mechanical Mind version " .. tostring(GAMEMODE.Version or "error") .. "\n", Color(255, 149, 129))
	if IsValid(ply) then
		t:Send(ply)
	else
		t:Print()
	end
	GAMEMODE:CheckForNewVersion(ply)
end)