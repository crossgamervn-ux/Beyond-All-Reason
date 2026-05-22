function gadget:GetInfo()
	return {
		name      = "IoT Telemetry Control",
		desc      = "Provides UDP telemetry and external unit control via luasocket.",
		author    = "CrossGamer",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default
	}
end

local UPDATE_INTERVAL = 30 -- ~1 second at 30 fps

if gadgetHandler:IsSyncedCode() then
	-- =========================================================================
	-- SYNCED CODE: Interacts with game state (orders, units, health)
	-- =========================================================================

	function gadget:Initialize()
		-- Register the incoming message handler
		gadgetHandler:AddSyncAction("IoT_ControlMsg", handleIoTControlMsg)
	end

	function gadget:GameFrame(n)
		-- Send telemetry data periodically to Unsynced
		if n % UPDATE_INTERVAL == 0 then
			local units = Spring.GetAllUnits()
			for _, unitID in ipairs(units) do
				if not Spring.GetUnitIsDead(unitID) then
					local ux, uy, uz = Spring.GetUnitPosition(unitID)
					local hp, maxHP = Spring.GetUnitHealth(unitID)
					local unitDefID = Spring.GetUnitDefID(unitID)

					if ux and hp then
						local telemetryStr = string.format("%d,%d,%f,%f,%f,%f,%f", unitID, unitDefID, ux, uy, uz, hp, maxHP)
						SendToUnsynced("IoT_TelemetryMsg", telemetryStr)
					end
				end
			end
		end
	end

	function handleIoTControlMsg(_, data)
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

else
	-- =========================================================================
	-- UNSYNCED CODE: Handles Network I/O (luasocket)
	-- =========================================================================

	-- Try standard global first, fallback to require for standard Lua environments.
	-- Spring's LuaRules engine exposes socket differently depending on config.
	local socket = socket
	if not socket then
		pcall(function() socket = require("socket") end)
	end

	local udpSend
	local udpRecv

	local TARGET_IP = "127.0.0.1"
	local SEND_PORT = 7945
	local RECV_PORT = 9002

	function gadget:Initialize()
		-- Register handler to receive telemetry from Synced
		gadgetHandler:AddSyncAction("IoT_TelemetryMsg", handleIoTTelemetryMsg)

		if socket then
			udpSend = socket.udp()
			if udpSend then
				udpSend:setpeername(TARGET_IP, SEND_PORT)
			end

			udpRecv = socket.udp()
			if udpRecv then
				udpRecv:setsockname("*", RECV_PORT)
				udpRecv:settimeout(0)
			end
		else
			Spring.Log("IoT", LOG.ERROR, "Luasocket not found. Ensure TCPAllowConnect is set.")
		end
	end

	function gadget:GameFrame(n)
		-- Process incoming network commands
		if udpRecv then
			-- Loop to drain the UDP buffer
			while true do
				local data, ip, port = udpRecv:receivefrom()
				if not data then break end

				-- Send valid data to Synced via explicit action
				SendToSynced("IoT_ControlMsg", data)
			end
		end
	end

	-- Handlers for SendToUnsynced receive only the arguments explicitly sent, no implicit playerID.
	function handleIoTTelemetryMsg(telemetryStr)
		if udpSend and telemetryStr then
			udpSend:send(telemetryStr)
		end
	end

end
