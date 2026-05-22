function gadget:GetInfo()
	return {
		name      = "IoT Telemetry Bridge (Synced)",
		desc      = "Gathers unit telemetry and processes incoming external commands.",
		author    = "CrossGamer",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

local UPDATE_INTERVAL = 30 -- ~1 second at 30 fps

if gadgetHandler:IsSyncedCode() then

	local function handleIoTControlMsg(_, data)
		local parts = {}
		for part in string.gmatch(data, "[^,]+") do
			parts[#parts + 1] = part
		end

		if #parts >= 2 then
			local unitID = tonumber(parts[1])
			local cmdStr = parts[2]

			if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
				if cmdStr == "MOVE" and #parts >= 5 then
					local tx = tonumber(parts[3])
					local ty = tonumber(parts[4])
					local tz = tonumber(parts[5])
					if tx and ty and tz then
						Spring.GiveOrderToUnit(unitID, CMD.MOVE, {tx, ty, tz}, 0)
					end
				elseif cmdStr == "STOP" then
					Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, 0)
				end
			end
		end
	end

	function gadget:RecvLuaMsg(msg, playerID)
		if msg:sub(1, 14) == "IoT_ControlMsg" then
			handleIoTControlMsg(nil, msg:sub(16))
			return true
		end
	end

	function gadget:GameFrame(n)
		-- Send telemetry data periodically to LuaUI via Unsynced wrapper
		if n % UPDATE_INTERVAL == 0 then
			local units = Spring.GetAllUnits()

			local telemetryData = "{"
			local count = 0
			for _, unitID in ipairs(units) do
				if not Spring.GetUnitIsDead(unitID) then
					local ux, uy, uz = Spring.GetUnitPosition(unitID)
					local hp, maxHP = Spring.GetUnitHealth(unitID)
					local unitDefID = Spring.GetUnitDefID(unitID)

					if ux and hp then
						if count > 0 then telemetryData = telemetryData .. "," end
						telemetryData = telemetryData .. string.format('"%d": {"def":%d,"x":%f,"y":%f,"z":%f,"hp":%f,"maxHP":%f}', unitID, unitDefID, ux, uy, uz, hp, maxHP)
						count = count + 1
					end
				end
			end
			telemetryData = telemetryData .. "}"

			SendToUnsynced("IoT_TelemetryMsg", telemetryData)
		end
	end

else
	-- Unsynced Gadget portion merely bridges the Sync action to LuaUI Script
	local function handleIoTTelemetryMsg(_, telemetryStr)
		if Script.LuaUI("IoT_TelemetryUpdate") then
			Script.LuaUI.IoT_TelemetryUpdate(telemetryStr)
		end
	end

	function gadget:Initialize()
		gadgetHandler:AddSyncAction("IoT_TelemetryMsg", handleIoTTelemetryMsg)
	end
end