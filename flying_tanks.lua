-- Flying Tanks Mod
for unitName, unitDef in pairs(UnitDefs) do
    if unitDef.movementclass and string.find(unitDef.movementclass, "TANK") then
        unitDef.canfly = true
        unitDef.cruisealt = 150
        unitDef.hoverattack = true
        unitDef.upright = true
        unitDef.movementclass = nil
    end
end
Spring.Echo("Flying tanks mod applied!")
