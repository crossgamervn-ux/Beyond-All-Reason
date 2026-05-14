-- by CrossGamer -- Antinuke to ICBM Visuals & Stats
for n, d in pairs(UnitDefs) do
    if d.weapondefs then
        for _, wDef in pairs(d.weapondefs) do
            -- 1. Sửa Antinuke
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

                -- Thời gian nạp Antinuke (tính bằng giây)
                wDef.stockpiletime = 36

                wDef.areaofeffect = 1000
                wDef.edgeeffectiveness = 0.3

                if not wDef.damage then
                    wDef.damage = {}
                end
                wDef.damage.default = 5500
                wDef.damage.commanders = 1200

            -- 2. Sửa thời gian nạp cho ICBM thật
            elseif wDef.customparams and (wDef.customparams.nuclear == "1" or wDef.customparams.nuclear == 1) then
                -- Thay đổi thời gian nạp ICBM tại đây (tính bằng giây, mặc định là 180s)
                wDef.stockpiletime = 90
            end
        end
    end
end
