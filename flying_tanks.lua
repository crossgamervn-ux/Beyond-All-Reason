-- by CrossGamer -- Flying Tanks & Walking Planes Mod
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
            if wDef.waterweapon then
                wDef.waterweapon = nil
            end

            if wDef.weapontype == "MissileLauncher" or wDef.weapontype == "StarburstLauncher" then
                wDef.tolerance = 32000
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
