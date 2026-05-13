-- by CrossGamer -- ICBM MIRV Mutator
for n, d in pairs(UnitDefs) do
    if d.weapondefs then
        local newWarheads = {}
        for wName, wDef in pairs(d.weapondefs) do
            -- Xác định ICBM thật
            if wDef.customparams and (wDef.customparams.nuclear == "1" or wDef.customparams.nuclear == 1) then
                -- 1. Tạo đạn con (Warhead)
                local warheadName = wName .. "_mirv_warhead"
                local warhead = {}
                for k, v in pairs(wDef) do
                    if type(v) ~= "table" then
                        warhead[k] = v
                    end
                end
                -- Xử lý table (như damage)
                if wDef.damage then
                    warhead.damage = {}
                    for k, v in pairs(wDef.damage) do
                        warhead.damage[k] = (tonumber(v) or 1000) * 0.35 -- Mỗi quả con gây 35% damage
                    end
                end

                -- Tinh chỉnh đạn con
                warhead.name = "MIRV Warhead"
                warhead.areaofeffect = (tonumber(warhead.areaofeffect) or 1920) * 0.5
                warhead.weaponvelocity = (tonumber(warhead.weaponvelocity) or 1600) * 0.8
                warhead.range = 2000
                warhead.flighttime = nil
                warhead.stockpile = false
                warhead.weapontype = "Cannon" -- Dùng Cannon để đạn rơi thẳng rải thảm thay vì Starburst bay ngược lên
                warhead.turnrate = nil
                warhead.weaponacceleration = nil
                warhead.cegtag = "NUKETRAIL"

                -- Lưu đạn con vào mảng tạm để add vào weapondefs sau khi lặp xong
                newWarheads[warheadName] = warhead

                -- 2. Sửa ICBM mẹ thành nổ chùm
                wDef.customparams.cluster_def = warheadName
                wDef.customparams.cluster_number = 6
                -- Khi chạm trần hoặc mục tiêu, nuke mẹ nổ và nhả 6 quả đạn Cannon rơi tự do
            end
        end

        -- Gộp đạn con vào danh sách vũ khí của unit
        for k, v in pairs(newWarheads) do
            d.weapondefs[k] = v
        end
    end
end
