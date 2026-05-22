function gadget:GetInfo()
	return {
		name      = "IoT Telemetry Console Bridge",
		desc      = "Gathers unit telemetry and processes incoming external commands via STDOUT/Chat.",
		author    = "CrossGamer",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

local UPDATE_INTERVAL = 30 -- ~1 second at 30 fps

if gadgetHandler:IsSyncedCode() then

	function gadget:GotChatMsg(msg, playerID)
		-- Example external command via STDIN: "a /iot MOVE 123 500 0 500"
		-- (The engine often prefixes chat with "a " or "s " depending on alliance/spec state)
		-- We will find the /iot keyword

		local iotStart = string.find(msg, "/iot ")
		if iotStart then
			local command = string.sub(msg, iotStart + 5)

			local parts = {}
			for part in string.gmatch(command, "[^%s]+") do
				parts[#parts + 1] = part
			end

			if #parts >= 2 then
				local cmdStr = parts[1]
				local unitID = tonumber(parts[2])

				if unitID and Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
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

			-- Return true to swallow the message so it doesn't clutter in-game chat for players
			return true
		end
		return false
	end

	function gadget:GameFrame(n)
		-- Send telemetry data periodically to Console (STDOUT)
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

			-- Print to console so external processes can capture it
			Spring.Echo("IOT_TELEMETRY: " .. telemetryData)
		end
	end

end