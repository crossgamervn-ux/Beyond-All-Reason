-- by CrossGamer -- Gravity Inversion Mod
for n, d in pairs(UnitDefs) do
    local isModified = false

    if d.canfly then
        d.canfly = false
        d.cruisealtitude = nil
        d.hoverattack = false
        d.movementclass = "TANK3"
        d.collide = true
        d.maxslope = 15
        d.maxwaterdepth = 15
        d.upright = true
        d.turnrate = 350
        d.turninplace = true
        d.turninplaceanglelimit = 90
        isModified = true
    elseif not d.canfly and (tonumber(d.speed) or 0) > 0 then
        d.canfly = true
        d.cruisealtitude = 150
        d.hoverattack = true
        d.upright = true
        d.movementclass = nil
        d.turnrate = (tonumber(d.turnrate) or 500) * 1.5
        d.acceleration = (tonumber(d.acceleration) or 0.1) * 2
        isModified = true
    end

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
                if wDef.weaponvelocity then
                    wDef.weaponvelocity = (tonumber(wDef.weaponvelocity) or 100) * 4
                end
                if wDef.damage and wDef.damage.default then
                    wDef.damage.vtol = wDef.damage.default
                end
            end
        end
    end
end
