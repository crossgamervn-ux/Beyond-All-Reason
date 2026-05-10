-- Walking Planes Mod (Máy bay đi bộ)
local convertedCount = 0
local failedCount = 0

Spring.Echo(">>>>> WALKING PLANES MOD: Bắt đầu ép máy bay hạ cánh... <<<<<")

for unitName, unitDef in pairs(UnitDefs) do
    -- Tìm các unit là máy bay (canfly == true) và không phải lính xây dựng/công trình (builder)
    if unitDef.canfly == true and not unitDef.builder then

        -- 1. Xóa bỏ các đặc tính bay lơ lửng trên không
        unitDef.canfly = false
        unitDef.cruisealtitude = nil
        unitDef.hoverattack = false

        -- 2. Cấp đặc tính di chuyển mặt đất giống như hệ Xe tăng
        unitDef.movementclass = "TANK3" -- Bắt buộc phải có để engine tìm đường
        unitDef.collide = true          -- Cho phép va chạm với địa hình/nhau
        unitDef.maxslope = 15           -- Lên dốc tối đa 15 độ
        unitDef.maxwaterdepth = 15      -- Có thể lội nước nông
        unitDef.upright = true          -- Luôn đứng thẳng, không bị nghiêng lật sấp

        -- 3. Tinh chỉnh di chuyển cho giống xe tăng hơn
        unitDef.turnrate = 350          -- Tốc độ xoay thân chậm lại
        unitDef.turninplace = true      -- Cho phép xoay thân tại chỗ như xe tăng
        unitDef.turninplaceanglelimit = 90

        convertedCount = convertedCount + 1
        Spring.Echo("[Walking Mod] THÀNH CÔNG: Máy bay " .. unitName .. " đã bị tước cánh, giờ sẽ bò dưới đất!")
    else
        -- Unit không phải máy bay, bỏ qua
        -- (Tắt bớt log failed để đỡ rác console vì có rất nhiều unit dưới đất)
    end
end

Spring.Echo(">>>>> WALKING PLANES MOD: Hoàn tất! <<<<<")
Spring.Echo(">> Chuyển đổi thành công: " .. convertedCount .. " máy bay thành xe tăng.")
