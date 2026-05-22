function widget:GetInfo()
	return {
		name      = "IoT File Bridge (UI)",
		desc      = "Handles JSON file I/O for IoT telemetry and commands.",
		author    = "CrossGamer",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

local IOT_FILE = "iot_data.txt"
local UPDATE_INTERVAL = 30
local lastProcessedCommandCount = 0
local currentTelemetry = {}
local Json = VFS.Include('common/luaUtilities/json.lua')

-- This function is called from the Unsynced Gadget space
function IoT_TelemetryUpdate(telemetryStr)
	local parsedTelemetry = {}
	pcall(function() parsedTelemetry = Json.decode(telemetryStr) end)
	if not parsedTelemetry then
		pcall(function() parsedTelemetry = loadstring("return " .. telemetryStr)() end)
	end

	if parsedTelemetry then
		currentTelemetry = parsedTelemetry

		-- Write out to file
		local f, err = io.open(IOT_FILE, "r")
		local currentData = { game_send = {}, game_received = {} }

		if f then
			local content = f:read("*a")
			f:close()
			if content and content ~= "" then
				pcall(function()
					local decoded = Json.decode(content)
					if decoded and decoded.game_received then
						currentData.game_received = decoded.game_received
					end
				end)
			end
		end

		currentData.game_send = currentTelemetry

		local wf, werr = io.open(IOT_FILE, "w")
		if wf then
			local success, encoded = pcall(function() return Spring.Utilities.json.encode(currentData) end)
			if success and encoded then
				wf:write(encoded)
			else
				-- fallback if json.encode fails
				wf:write('{"game_send":{},"game_received":[]}')
			end
			wf:close()
		else
			Spring.Echo("IoT Widget Error: Failed to write to " .. IOT_FILE .. ": " .. tostring(werr))
		end
	end
end

function widget:Initialize()
	-- Expose to gadget
	widgetHandler:RegisterGlobal("IoT_TelemetryUpdate", IoT_TelemetryUpdate)

	-- Create initial file
	local f = io.open(IOT_FILE, "w")
	if f then
		f:write('{"game_send":{},"game_received":[]}')
		f:close()
	end
end

function widget:Shutdown()
	widgetHandler:DeregisterGlobal("IoT_TelemetryUpdate")
end

function widget:GameFrame(n)
	-- Periodically check for new commands
	if n % UPDATE_INTERVAL == 15 then
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