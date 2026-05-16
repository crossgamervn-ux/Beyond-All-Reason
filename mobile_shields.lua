-- Mod Author: Jules
-- Mod Name: Mobile Shields
if UnitDefs then
    local units_to_modify = {"armcroc", "corsala", "legfloat"}
    for _, unitName in ipairs(units_to_modify) do
        local ud = UnitDefs[unitName]
        if ud then
            -- Thay đổi thành không thể tấn công thông thường
            ud.canattack = false

            -- Thêm customparams cho khiên để UI hiển thị vòng shield
            ud.customparams = ud.customparams or {}
            ud.customparams.shield_power = 6175
            ud.customparams.shield_radius = 550

            -- Ghi đè vũ khí duy nhất thành Shield (không bắn được đạn nữa)
            ud.weapons = {
                [1] = {
                    def = "REPULSOR",
                    onlytargetcategory = "NOTSUB",
                }
            }

            -- Thêm định nghĩa vũ khí Shield y hệt trụ armgate (Plasma Repulsor)
            ud.weapondefs = ud.weapondefs or {}
            ud.weapondefs.repulsor = {
                avoidfeature = false,
                craterareaofeffect = 0,
                craterboost = 0,
                cratermult = 0,
                edgeeffectiveness = 0.15,
                name = "PlasmaRepulsor",
                soundhitwet = "sizzle",
                weapontype = "Shield",
                shield = {
                    alpha = 0.17,
                    armortype = "shields",
                    exterior = true,
                    energyupkeep = 0,
                    force = 2.5,
                    intercepttype = 1,
                    power = 6175,
                    powerregen = 130,
                    powerregenenergy = 562.5,
                    radius = 550,
                    repulser = false,
                    smart = true,
                    startingpower = 2090,
                    visiblerepulse = true,
                    badcolor = {1, 0.2, 0.2, 0.2},
                    goodcolor = {0.2, 1, 0.2, 0.17},
                },
            }
        end
    end
end
