-- by CrossGamer -- Walking Planes Mod
for unitName, unitDef in pairs(UnitDefs) do
    if unitDef.canfly == true and not unitDef.builder then
        unitDef.canfly = false
        unitDef.cruisealtitude = nil
        unitDef.hoverattack = false
        unitDef.movementclass = "TANK3"
        unitDef.collide = true
        unitDef.maxslope = 15
        unitDef.maxwaterdepth = 15
        unitDef.upright = true
        unitDef.turnrate = 350
        unitDef.turninplace = true
        unitDef.turninplaceanglelimit = 90
    end
end
