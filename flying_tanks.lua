-- Flying Vehicles Mod (Hệ xe cơ giới)
local convertedCount = 0
local failedCount = 0

Spring.Echo(">>>>> FLYING TANK MOD: Bắt đầu quét hệ thống xe cơ giới... <<<<<")

for unitName, unitDef in pairs(UnitDefs) do
    -- Hệ xe cơ giới trong BAR Engine thường có movementclass chứa chữ "TANK" (như TANK2, TANK3, MTANK3, HTANK4, ATANK3)
    if unitDef.movementclass and string.find(unitDef.movementclass, "TANK") then
        -- Lọc ra các unit chưa phải là máy bay
        if not unitDef.canfly then
            unitDef.canfly = true
            unitDef.cruisealt = 150          -- Độ cao bay trên không
            unitDef.hoverattack = true       -- Cho phép lơ lửng khi tấn công
            unitDef.upright = true           -- Giữ xe tank luôn hướng lên trên, không bị lật
            unitDef.movementclass = nil      -- Bỏ giới hạn di chuyển mặt đất của Engine

            -- Tùy chỉnh thêm để giống máy bay:
            unitDef.turnrate = (unitDef.turnrate or 500) * 1.5 -- Tăng tốc độ xoay khi bay
            unitDef.acceleration = (unitDef.acceleration or 0.1) * 2 -- Tăng gia tốc

            convertedCount = convertedCount + 1
            Spring.Echo("[Flying Mod] Thêm THÀNH CÔNG: Đã độ chế máy bay cho " .. unitName)
        else
            -- Nếu xe này đã có khả năng bay (canfly == true) từ trước
            failedCount = failedCount + 1
            Spring.Echo("[Flying Mod] Thêm KHÔNG THÀNH CÔNG: Xe " .. unitName .. " đã là máy bay từ trước, bỏ qua.")
        end
    end
end

Spring.Echo(">>>>> FLYING TANK MOD: Hoàn tất! <<<<<")
Spring.Echo(">> Chuyển đổi thành công: " .. convertedCount .. " xe.")
Spring.Echo(">> Chuyển đổi thất bại (đã bay sẵn): " .. failedCount .. " xe.")
