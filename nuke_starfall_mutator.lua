-- Mod Author: CrossGamer
-- Mod Name: Nuke Starfall Mutator

if UnitDefs then
    local targetUnits = {"legministarfall", "legstarfall"}

    for _, unitName in ipairs(targetUnits) do
        local uDef = UnitDefs[unitName]
        if uDef and type(uDef) == "table" and uDef.weapondefs and uDef.weapondefs.starfire then
            local wDef = uDef.weapondefs.starfire

            wDef.weapontype = "MissileLauncher"
            wDef.tracks = true
            wDef.turnrate = 99000

            wDef.explosiongenerator = "custom:newnuke"

            wDef.customparams = wDef.customparams or {}
            wDef.customparams.nuclear = 1
        end
    end
end
