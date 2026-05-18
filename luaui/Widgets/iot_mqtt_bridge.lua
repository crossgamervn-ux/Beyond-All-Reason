function widget:GetInfo()
    return {
        name      = "IoT MQTT Bridge",
        desc      = "Kết nối game BAR với các thiết bị IoT (ví dụ: ESP32) qua MQTT",
        author    = "CrossGamer",
        date      = "Hôm nay",
        license   = "GNU GPL, v2 or later",
        layer     = 0,
        enabled   = true
    }
end

-- Do trong giới hạn repo này chưa tích hợp sẵn luamqtt (và tải lua package vào repo sẽ phức tạp)
-- đây là file giữ chỗ để người dùng cấu trúc mã
local client_mqtt

function widget:Initialize()
    Spring.Echo("IoT MQTT Bridge Widget Initialized. Đang chờ module MQTT.")
end

function widget:Update(dt)
    -- Giữ kết nối socket và vòng lặp MQTT ở đây
end

function widget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeamID)
    -- Push MQTT event
end
