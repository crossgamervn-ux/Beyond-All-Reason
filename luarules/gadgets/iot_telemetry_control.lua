function gadget:GetInfo()
	return {
		name      = "IoT Telemetry Control",
		desc      = "Provides file-based telemetry and external unit control using JSON.",
		author    = "CrossGamer",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default
	}
end

local UPDATE_INTERVAL = 30 -- ~1 second at 30 fps
local IOT_FILE = "iot_data.txt"

if gadgetHandler:IsSyncedCode() then
	-- =========================================================================
	-- SYNCED CODE: Interacts with game state (orders, units, health)
	-- =========================================================================

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
		-- Send telemetry data periodically to Unsynced
		if n % UPDATE_INTERVAL == 0 then
			local units = Spring.GetAllUnits()

			-- Construct JSON payload directly or pass a formatted string.
			-- We will build a basic string representation to send over the boundary.
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
	-- =========================================================================
	-- UNSYNCED CODE: Handles File I/O
	-- =========================================================================

	local lastProcessedCommandCount = 0

	-- Write to file, handling the JSON structure
	local function handleIoTTelemetryMsg(telemetryStr)
		local f, err = io.open(IOT_FILE, "r")
		local currentData = {}

		-- Try to read existing data to preserve game_received
		if f then
			local content = f:read("*a")
			f:close()
			if content and content ~= "" then
				pcall(function() currentData = Json.decode(content) end)
			end
		end

		-- Decode the telemetry string coming from Synced
		local parsedTelemetry = {}
		pcall(function() parsedTelemetry = Json.decode(telemetryStr) end)

		-- Update game_send field
		currentData.game_send = parsedTelemetry

		-- Ensure game_received exists so external app doesn't break
		if not currentData.game_received then
			currentData.game_received = {}
		end

		-- Write back
		local wf, werr = io.open(IOT_FILE, "w")
		if wf then
			wf:write(Json.encode(currentData))
			wf:close()
		else
			Spring.Log("IoT", LOG.ERROR, "Failed to write to " .. IOT_FILE .. ": " .. tostring(werr))
		end
	end

	function gadget:Initialize()
		-- Register handler to receive telemetry from Synced
		gadgetHandler:AddSyncAction("IoT_TelemetryMsg", handleIoTTelemetryMsg)

		-- Create initial file
		local f = io.open(IOT_FILE, "w")
		if f then
			f:write('{"game_send":{},"game_received":[]}')
			f:close()
		end
	end

	function gadget:GameFrame(n)
		-- Periodically check for new commands
		if n % UPDATE_INTERVAL == 15 then -- Offset from telemetry generation
			local f, err = io.open(IOT_FILE, "r")
			if f then
				local content = f:read("*a")
				f:close()

				if content and content ~= "" then
					local success, parsed = pcall(function() return Json.decode(content) end)
					if success and parsed and parsed.game_received then

						local commands = parsed.game_received

						-- Only process new commands by tracking array length
						if #commands > lastProcessedCommandCount then
							for i = lastProcessedCommandCount + 1, #commands do
								local cmdStr = commands[i]
								if type(cmdStr) == "string" then
									Spring.SendLuaRulesMsg("IoT_ControlMsg|" .. cmdStr)
								end
							end
							lastProcessedCommandCount = #commands
						elseif #commands < lastProcessedCommandCount then
							-- Array was cleared/reset by external tool
							lastProcessedCommandCount = 0
							for i = 1, #commands do
								local cmdStr = commands[i]
								if type(cmdStr) == "string" then
									Spring.SendLuaRulesMsg("IoT_ControlMsg|" .. cmdStr)
								end
							end
							lastProcessedCommandCount = #commands
						end
					end
				end
			end
		end
	end

end