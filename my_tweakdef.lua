local modAuthor = "CrossGamer"
local modName = "Electric Splash All"

if WeaponDefs then
    for id, wDef in pairs(WeaponDefs) do
        if type(wDef) == "table" and wDef.type ~= "Shield" then
            if not wDef.customparams then wDef.customparams = {} end
            if not wDef.customparams.spark_forkdamage then
                wDef.customparams.spark_ceg = "genericshellexplosion-splash-lightning"
                wDef.customparams.spark_forkdamage = "0.2"
                wDef.customparams.spark_maxunits = "3"
                wDef.customparams.spark_range = "80"
            end
        end
    end
end
