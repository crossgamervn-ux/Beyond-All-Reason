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
    local isModified = false

    if tanks[n] and not d.canfly then
        d.canfly, d.cruisealtitude, d.hoverattack, d.upright, d.movementclass = true, 150, true, true, nil
        d.turnrate = (tonumber(d.turnrate) or 500) * 1.5
        d.acceleration = (tonumber(d.acceleration) or 0.1) * 2
        isModified = true
    elseif planes[n] and d.canfly then
        d.canfly, d.cruisealtitude, d.hoverattack, d.movementclass = false, nil, false, "TANK3"
        d.collide, d.maxslope, d.maxwaterdepth, d.upright = true, 15, 15, true
        d.turnrate, d.turninplace, d.turninplaceanglelimit = 350, true, 90
        isModified = true
    end

    if isModified then
        if d.weapons then
            for _, weapon in pairs(d.weapons) do
                if weapon.badtargetcategory == "VTOL" or weapon.badtargetcategory == "NOTAIR" then
                    weapon.badtargetcategory = nil
                end

                if weapon.onlytargetcategory == "VTOL" then
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

                if wDef.canattackground == false then
                    wDef.canattackground = true
                end

                if wDef.waterweapon then
                    wDef.waterweapon = nil
                end
            end
        end
    end
end
