function widget:GetInfo()
    return {
        name      = "IoT TCP Bridge",
        desc      = "Kết nối game BAR với các thiết bị IoT (ví dụ: ESP32) qua TCP",
        author    = "CrossGamer",
        date      = "Hôm nay",
        license   = "GNU GPL, v2 or later",
        layer     = 0,
        enabled   = true
    }
end

local socket = socket
local client
local esp32_ip = "127.0.0.1" -- Đổi sang IP tĩnh của ESP32
local esp32_port = 12345

function widget:Initialize()
    if not socket then
        Spring.Echo("Lỗi: Không tìm thấy thư viện socket. Vui lòng bật TCPAllowConnect = * trong springsettings.cfg")
        return
    end

    client = socket.tcp()
    client:settimeout(0) -- non-blocking
    local res, err = client:connect(esp32_ip, esp32_port)
    if res then
        Spring.Echo("IoT TCP Bridge: Đã kết nối tới ESP32!")
    else
        Spring.Echo("IoT TCP Bridge: Kết nối ESP32 thất bại (" .. tostring(err) .. "). Sẽ thử lại sau.")
    end
end

function widget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeamID)
    if client then
        local data = string.format("UNIT_DESTROYED|ID:%d|DEF:%d|TEAM:%d\n", unitID, unitDefID or -1, teamID or -1)
        client:send(data)
    end
end

function widget:UnitCreated(unitID, unitDefID, teamID, builderID)
    if client then
        local data = string.format("UNIT_CREATED|ID:%d|DEF:%d|TEAM:%d\n", unitID, unitDefID or -1, teamID or -1)
        client:send(data)
    end
end

function widget:Shutdown()
    if client then
        client:close()
    end
end
