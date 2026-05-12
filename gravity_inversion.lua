-- by CrossGamer -- Gravity Inversion Mod
for n, d in pairs(UnitDefs) do
    local isCom = d.customparams and d.customparams.iscommander

    if d.canfly and d.health and d.health > 0 and not isCom then
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
    elseif not d.canfly and d.health and d.health > 0 and (tonumber(d.speed) or 0) > 0 and not isCom then
        d.canfly = true
        d.cruisealtitude = 150
        d.hoverattack = true
        d.upright = true
        d.turnrate = (tonumber(d.turnrate) or 500) * 1.5
        d.acceleration = (tonumber(d.acceleration) or 0.1) * 2
        d.floater = false
        d.waterline = 0
        d.minwaterdepth = 0
    end

    if d.weapons then
        for _, weapon in pairs(d.weapons) do
            if weapon.badtargetcategory == "VTOL" or weapon.badtargetcategory == "NOTAIR" then
                weapon.badtargetcategory = nil
            end
            if weapon.onlytargetcategory == "VTOL" or weapon.onlytargetcategory == "NOTAIR" then
                weapon.onlytargetcategory = nil
            end
            weapon.maxangledif = 360
        end
    end

    if d.weapondefs then
        for _, wDef in pairs(d.weapondefs) do
            if wDef.weaponvelocity then
                wDef.weaponvelocity = (tonumber(wDef.weaponvelocity) or 100) * 4
            end
            if wDef.damage and wDef.damage.default then
                wDef.damage.vtol = wDef.damage.default
                wDef.damage.subs = wDef.damage.default
            end
            if wDef.canattackground == false then
                wDef.canattackground = true
            end

            wDef.waterweapon = true

            if wDef.weapontype ~= "BeamLaser" and wDef.weapontype ~= "LightningCannon" then
                wDef.tolerance = 32000
            end

            if wDef.weapontype == "MissileLauncher" or wDef.weapontype == "StarburstLauncher" then
                if wDef.flighttime then
                    wDef.flighttime = (tonumber(wDef.flighttime) or 2) * 2
                end
                if wDef.turnrate then
                    wDef.turnrate = (tonumber(wDef.turnrate) or 1000) * 2
                end
            end
        end
    end
end
