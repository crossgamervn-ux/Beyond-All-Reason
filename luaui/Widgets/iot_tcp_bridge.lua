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
local clients = {} -- [robotID] = tcp_client
local tracked_units = {} -- [unitID] = robotID
local last_sent_time = {} -- [robotID] = last_time

function widget:Initialize()
    if not socket then
        Spring.Echo("Lỗi: Không tìm thấy thư viện socket. Vui lòng bật TCPAllowConnect = * trong springsettings.cfg")
        return
    end
end

function widget:TextCommand(command)
    -- /bind <UnitID> <RobotID> <ESP_IP>
    if string.sub(command, 1, 5) == "bind " then
        local parts = {}
        for w in string.gmatch(command, "%S+") do table.insert(parts, w) end

        if #parts == 4 then
            local unitID = tonumber(parts[2])
            local robotID = parts[3]
            local esp_ip = parts[4]
            local esp_port = 12345

            if Spring.ValidUnitID(unitID) then
                local c = socket.tcp()

                -- Kết nối đồng bộ để chắc chắn kết nối thành công trước
                c:settimeout(2)
                local res, err = c:connect(esp_ip, esp_port)

                if res then
                    -- Sau khi kết nối, chuyển sang non-blocking để không lag game
                    c:settimeout(0)
                    clients[robotID] = c
                    tracked_units[unitID] = robotID
                    last_sent_time[robotID] = Spring.GetTimer()

                    Spring.Echo("Đã gán Unit " .. unitID .. " cho Robot " .. robotID .. " (IP: " .. esp_ip .. ")")
                else
                    Spring.Echo("Lỗi kết nối tới ESP32 (" .. esp_ip .. "): " .. tostring(err))
                    c:close()
                end
            else
                Spring.Echo("Unit ID không hợp lệ!")
            end
        else
            Spring.Echo("Lệnh: /bind <UnitID> <RobotID> <ESP_IP>")
        end
        return true
    end
    return false
end

function widget:Update(dt)
    local current_time = Spring.GetTimer()
    for unitID, robotID in pairs(tracked_units) do
        local c = clients[robotID]
        if c then
            -- Gửi dữ liệu tối đa 5 lần mỗi giây (0.2s một lần) để tránh spam mạng và treo socket
            if Spring.DiffTimers(current_time, last_sent_time[robotID]) >= 0.2 then
                if Spring.ValidUnitID(unitID) then
                    local x, y, z = Spring.GetUnitPosition(unitID)
                    local data = string.format("POS|X:%.1f|Z:%.1f\n", x, z)
                    local sent, err = c:send(data)

                    if not sent and err ~= "timeout" then
                        Spring.Echo("Robot " .. robotID .. " ngắt kết nối: " .. tostring(err))
                        c:close()
                        clients[robotID] = nil
                        tracked_units[unitID] = nil
                    else
                        last_sent_time[robotID] = current_time
                    end
                else
                    c:send("DESTROYED\n")
                    c:close()
                    clients[robotID] = nil
                    tracked_units[unitID] = nil
                    last_sent_time[robotID] = nil
                end
            end
        end
    end
end

function widget:Shutdown()
    for robotID, c in pairs(clients) do
        if c then
            c:close()
        end
    end
end
