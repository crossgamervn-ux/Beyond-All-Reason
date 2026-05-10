-- Gravity Inversion Mod (Đảo Ngược Trọng Lực)
local groundedPlanes = 0
local flyingGroundUnits = 0

Spring.Echo(">>>>> GRAVITY INVERSION MOD: Kích hoạt... <<<<<")

for n, d in pairs(UnitDefs) do
    local isModified = false

    -- 1. MÁY BAY HÓA XE TĂNG (Tất cả những gì đang bay sẽ bị rớt xuống đất)
    if d.canfly then
        d.canfly = false
        d.cruisealtitude = nil
        d.hoverattack = false
        d.movementclass = "TANK3" -- Bắt buộc có để di chuyển
        d.collide = true
        d.maxslope = 15
        d.maxwaterdepth = 15
        d.upright = true
        d.turnrate = 350
        d.turninplace = true
        d.turninplaceanglelimit = 90

        isModified = true
        groundedPlanes = groundedPlanes + 1

    -- 2. XE TĂNG / BOT / HOVER / TÀU HÓA MÁY BAY
    -- (Những gì không bay, nhưng có tốc độ di chuyển speed > 0)
    elseif not d.canfly and d.speed and d.speed > 0 then
        d.canfly = true
        d.cruisealtitude = 150
        d.hoverattack = true
        d.upright = true
        d.movementclass = nil -- Cắt bỏ vật lý mặt đất

        d.turnrate = (d.turnrate or 500) * 1.5
        d.acceleration = (d.acceleration or 0.1) * 2

        isModified = true
        flyingGroundUnits = flyingGroundUnits + 1
    end

    -- 3. NÂNG CẤP VŨ KHÍ (Để đánh lộn được trong trạng thái mới)
    if isModified then
        if d.weapons then
            for _, weapon in pairs(d.weapons) do
                if weapon.badtargetcategory == "VTOL" or weapon.badtargetcategory == "NOTAIR" then
                    weapon.badtargetcategory = nil
                end
                if weapon.onlytargetcategory == "VTOL" or weapon.onlytargetcategory == "NOTAIR" then
                    weapon.onlytargetcategory = nil
                end
            end
        end

        if d.weapondefs then
            for _, wDef in pairs(d.weapondefs) do
                -- Tăng tốc độ bay đạn để dễ trúng máy bay (do tất cả lính đã thành máy bay)
                if wDef.weaponvelocity then
                    wDef.weaponvelocity = wDef.weaponvelocity * 4
                end

                -- Bơm max sát thương cho đạn bắn máy bay
                if wDef.damage and wDef.damage.default then
                    wDef.damage.vtol = wDef.damage.default
                end
            end
        end
    end
end

Spring.Echo(">>>>> GRAVITY INVERSION MOD: Hoàn tất! <<<<<")
Spring.Echo(">> Máy bay đã ép hạ cánh: " .. groundedPlanes)
Spring.Echo(">> Unit cạn đã bay lên trời: " .. flyingGroundUnits)
