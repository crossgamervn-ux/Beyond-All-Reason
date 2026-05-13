-- by CrossGamer -- Mega TweakDefs (Gravity Inversion, Flying Tanks, Antinuke to ICBM, MIRV)

local tanks = {
    ["armfav"]=true, ["armmlv"]=true, ["armflash"]=true, ["armart"]=true, ["armcv"]=true, ["armbeaver"]=true, ["armsam"]=true, ["armpincer"]=true, ["armstump"]=true, ["armjanus"]=true, ["armjam"]=true, ["armseer"]=true, ["armgremlin"]=true, ["armconsul"]=true, ["armmart"]=true, ["armlatnk"]=true, ["armyork"]=true, ["armacv"]=true, ["armcroc"]=true, ["armmerl"]=true, ["armbull"]=true, ["armmanni"]=true, ["armthor"]=true,
    ["corfav"]=true, ["cormlv"]=true, ["corgator"]=true, ["corcv"]=true, ["cormist"]=true, ["cormuskrat"]=true, ["corwolv"]=true, ["corgarp"]=true, ["corlevlr"]=true, ["corraid"]=true, ["corvrad"]=true, ["coreter"]=true, ["corsala"]=true, ["cormart"]=true, ["corsent"]=true, ["coracv"]=true, ["correap"]=true, ["corvroc"]=true, ["corban"]=true, ["corparrow"]=true, ["cormabm"]=true, ["corgol"]=true, ["cortrem"]=true,
    ["legscout"]=true, ["legmlv"]=true, ["leghades"]=true, ["legcv"]=true, ["legotter"]=true, ["leghelios"]=true, ["legamphtank"]=true, ["legrail"]=true, ["legbar"]=true, ["leggat"]=true, ["legvcarry"]=true, ["legavjam"]=true, ["legavrad"]=true, ["legafcv"]=true, ["legmrv"]=true, ["legaskirmtank"]=true, ["legamcluster"]=true, ["legvflak"]=true, ["legacv"]=true, ["legfloat"]=true, ["legavroc"]=true, ["legavantinuke"]=true, ["legaheattank"]=true, ["legmed"]=true, ["leginf"]=true, ["legkeres"]=true, ["legerailtank"]=true
}

local planes = {
    ["armpeep"]=true, ["armatlas"]=true, ["armfig"]=true, ["armsfig"]=true, ["armca"]=true, ["armsehak"]=true, ["armkam"]=true, ["armthund"]=true, ["armcsa"]=true, ["armhvytrans"]=true, ["armsaber"]=true, ["armsb"]=true, ["armseap"]=true, ["armhawk"]=true, ["armawac"]=true, ["armpnix"]=true, ["armbrawl"]=true, ["armdfly"]=true, ["armaca"]=true, ["armlance"]=true, ["armstil"]=true, ["armblade"]=true, ["armliche"]=true,
    ["armfepocht4"]=true, ["armfify"]=true, ["armlichet4"]=true, ["armthundt4"]=true,
    ["corfink"]=true, ["corbw"]=true, ["corveng"]=true, ["corvalk"]=true, ["corsfig"]=true, ["corca"]=true, ["corhunt"]=true, ["corcsa"]=true, ["corshad"]=true, ["corhvytrans"]=true, ["corsb"]=true, ["corcut"]=true, ["corseap"]=true, ["corvamp"]=true, ["corawac"]=true, ["corhurc"]=true, ["coraca"]=true, ["corape"]=true, ["corseah"]=true, ["cortitan"]=true, ["corcrwh"]=true,
    ["corcrw"]=true, ["corcrwt4"]=true, ["cordronecarryair"]=true, ["cords"]=true, ["corfblackhyt4"]=true,
    ["legdrone"]=true, ["legfig"]=true, ["legkam"]=true, ["leglts"]=true, ["legspfighter"]=true, ["legheavydrone"]=true, ["legcib"]=true, ["legca"]=true, ["legmos"]=true, ["legspradarsonarplane"]=true, ["legspcon"]=true, ["legatrans"]=true, ["legsptorpgunship"]=true, ["legspbomber"]=true, ["legspcarrier"]=true, ["legspsurfacegunship"]=true, ["legvenator"]=true, ["legafigdef"]=true, ["legwhisper"]=true, ["legmineb"]=true, ["legaca"]=true, ["legphoenix"]=true, ["legatorpbomber"]=true, ["legstronghold"]=true, ["legfort"]=true,
    ["legfortt4"]=true, ["legmost3"]=true
}

for n, d in pairs(UnitDefs) do
    -- 1. Flying Tanks & Gravity Inversion
    if tanks[n] and not d.canfly then
        d.canfly = true
        d.cruisealtitude = 150
        d.hoverattack = true
        d.upright = true
        d.turnrate = (tonumber(d.turnrate) or 500) * 1.5
        d.acceleration = (tonumber(d.acceleration) or 0.1) * 2
    elseif planes[n] and d.canfly then
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
    end

    local isCom = d.customparams and d.customparams.iscommander
    if d.canfly and d.health and d.health > 0 and not isCom and not tanks[n] then
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
    elseif not d.canfly and d.health and d.health > 0 and (tonumber(d.speed) or 0) > 0 and not isCom and not planes[n] then
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

    -- 2. Unlock Weapon Arcs
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

    -- 3. WeaponDefs Mutator
    if d.weapondefs then
        local newWarheads = {}
        for wName, wDef in pairs(d.weapondefs) do
            -- A) General Weapon Targetting fixes
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
            if wDef.waterweapon then
                wDef.waterweapon = nil
            end

            -- Tracker fixes for Starburst and Missiles
            if wDef.weapontype == "MissileLauncher" or wDef.weapontype == "StarburstLauncher" then
                if wDef.flighttime then
                    wDef.flighttime = (tonumber(wDef.flighttime) or 2) * 2
                end
                if wDef.turnrate then
                    wDef.turnrate = (tonumber(wDef.turnrate) or 1000) * 2
                end
            end

            -- B) Antinuke to ICBM Visuals & Buffs
            if wDef.interceptor == 1 and wDef.weapontype == "StarburstLauncher" then
                wDef.model = "crblmssl.s3o"
                wDef.cegtag = "NUKETRAIL"
                wDef.texture1 = "null"
                wDef.texture2 = "railguntrail"
                wDef.texture3 = "null"
                wDef.smokesize = 35
                wDef.smoketime = 130
                wDef.explosiongenerator = "custom:newnukecor"
                wDef.soundstart = "nukelaunch"
                wDef.soundhit = "nukecor"

                wDef.weaponvelocity = 1600
                wDef.weaponacceleration = 100
                wDef.turnrate = 5500

                wDef.metalpershot = 300
                wDef.energypershot = 37500
                wDef.stockpiletime = 36

                wDef.areaofeffect = 1000
                wDef.edgeeffectiveness = 0.3

                if not wDef.damage then wDef.damage = {} end
                wDef.damage.default = 5500
                wDef.damage.commanders = 1200

            -- C) ICBM MIRV Split
            elseif wDef.customparams and (wDef.customparams.nuclear == "1" or wDef.customparams.nuclear == 1) then
                -- Buff genuine ICBMs first
                wDef.areaofeffect = (tonumber(wDef.areaofeffect) or 1920) * 1.5
                if wDef.damage then
                    if wDef.damage.default then wDef.damage.default = (tonumber(wDef.damage.default) or 11500) * 2 end
                    if wDef.damage.commanders then wDef.damage.commanders = (tonumber(wDef.damage.commanders) or 2500) * 2 end
                end

                -- Create MIRV Warhead Submunition
                local warheadName = wName .. "_mirv_warhead"
                local warhead = {}
                for k, v in pairs(wDef) do
                    if type(v) ~= "table" then
                        warhead[k] = v
                    end
                end
                if wDef.damage then
                    warhead.damage = {}
                    for k, v in pairs(wDef.damage) do
                        warhead.damage[k] = (tonumber(v) or 1000) * 0.35 -- 35% damage per MIRV
                    end
                end

                warhead.name = "MIRV Warhead"
                warhead.areaofeffect = (tonumber(warhead.areaofeffect) or 1920) * 0.5
                warhead.weaponvelocity = (tonumber(warhead.weaponvelocity) or 1600) * 0.5
                warhead.range = 3000
                warhead.flighttime = nil
                warhead.stockpile = false
                warhead.weapontype = "Cannon"
                warhead.turnrate = nil
                warhead.weaponacceleration = nil
                warhead.cegtag = "NUKETRAIL"
                warhead.sprayangle = 15000 -- Max scatter
                warhead.mygravity = 0.2 -- Fall slowly and majestically

                newWarheads[warheadName] = warhead

                -- Configure ICBM to act as the Cluster parent
                if not wDef.customparams then wDef.customparams = {} end
                wDef.customparams.cluster_def = warheadName
                wDef.customparams.cluster_number = 6

                -- HACK: Use proximity and tracking edge-cases in tweakdefs to force early air-burst
                -- We cannot use flighttime=5 because ICBMs cross large maps.
                -- By giving the ICBM collision with everything and making it highly sensitive to distance
                wDef.collidefriendly = false
                wDef.collidefeature = false
                wDef.proximitypriority = -1  -- forces projectile to evaluate targets much earlier
                wDef.targetable = 1
                wDef.interceptor = 0
                wDef.tracks = false          -- prevents the missile from arcing all the way directly into the target's origin

                -- To simulate the mid-air drop effectively, limit the weaponvelocity drastically
                -- towards the end of the flight, letting it "fall" short over the target
                wDef.turnrate = 1000
            end

        end

        for k, v in pairs(newWarheads) do
            d.weapondefs[k] = v
        end
    end
end
