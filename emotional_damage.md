# Emotional Damage + Random Mutations Mod

Dưới đây là mã mod (tweakdef) đã được cập nhật thêm theo yêu cầu của bạn.

Cơ chế hoạt động mới:
1. **Giảm sát thương theo DPS và tăng knockback**: Lặp qua toàn bộ `WeaponDefs` để giảm sát thương vũ khí dựa trên dps và tăng rất mạnh lực đẩy (knockback).
2. **Đột biến ngẫu nhiên**: Lặp qua tất cả các `UnitDefs` bằng một hàm Random tất định (tránh lỗi Desync khi chơi Multi):
    - Với tỉ lệ 50%, một máy bay sẽ bị "ép đi bộ" (mất khả năng bay, biến thành TANK, di chuyển trên mặt đất). Khi đó, các vũ khí của nó sẽ được tăng x1.5 sát thương.
    - Với tỉ lệ 50%, một đơn vị đi bộ sẽ được "cấp phép bay" (nhận khả năng bay, di chuyển trên không, đánh lừa widget là máy bay chiến đấu).
3. **Mở khóa và tăng cường vũ khí**:
    - Nhận diện các vũ khí phòng không (AA) và tăng x2 sát thương cho chúng (nếu gắn trên máy bay đi bộ, hệ số cộng dồn là x3).
    - Xóa bỏ mọi hạn chế mục tiêu của vũ khí (`badtargetcategory`, `onlytargetcategory`), cho phép vũ khí phòng không bắn xuống đất.
    - Tăng mạnh tốc độ đạn (x4) và độ chính xác (tolerance, flighttime, turnrate) cho tên lửa/ngư lôi để đảm bảo bắn trúng mục tiêu dù có thay đổi trên không hay dưới đất.
    - **Cập nhật sửa lỗi cú pháp**: Đã sửa lỗi thiếu kí tự `>` trong phép so sánh `chance > 0.5` ở phiên bản trước.

### Script Lua:
```lua
local function getDeterministicChance(name)
    local hash = 0
    if name then
        for i = 1, #name do
            hash = (hash + string.byte(name, i) * i) % 100
        end
    end
    return hash / 100.0
end

if WeaponDefs then
    for name, wDef in pairs(WeaponDefs) do
        if type(wDef) == "table" and wDef.weapontype ~= "Shield" then
            local dmg = 0
            if wDef.damage and wDef.damage.default then
                dmg = wDef.damage.default
            end

            local reload = wDef.reloadtime or 1
            local burst = wDef.burst or 1
            local projectiles = wDef.projectiles or 1

            local dps = (dmg * burst * projectiles) / reload

            local damageMult = 100 / (100 + dps)

            if wDef.damage then
                for k, v in pairs(wDef.damage) do
                    wDef.damage[k] = math.max(0.1, v * damageMult)
                end
            end

            wDef.impulsefactor = (wDef.impulsefactor or 0) * 5 + 5
            wDef.impulseboost = (wDef.impulseboost or 0) * 5 + 2
        end
    end
end

if UnitDefs then
    for n, d in pairs(UnitDefs) do
        if type(d) == "table" then
            local isCom = d.customparams and d.customparams.iscommander
            local chance = getDeterministicChance(n)

            local isExFlyer = false

            if d.canfly and d.health and d.health > 0 and not isCom then
                if chance > 0.5 then
                    isExFlyer = true
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

            elseif not d.canfly and d.health and d.health > 0 and (tonumber(d.speed) or 0) > 0 and not isCom then
                if chance > 0.5 then
                    d.canfly = true
                    d.cruisealtitude = 150
                    d.hoverattack = true
                    d.upright = true
                    d.turnrate = (tonumber(d.turnrate) or 500) * 1.5
                    d.acceleration = (tonumber(d.acceleration) or 0.1) * 2
                    d.floater = false
                    d.waterline = 0
                    d.minwaterdepth = 0

                    if not d.customparams then
                        d.customparams = {}
                    end
                    d.customparams.fighter = "1"
                end
            end

            local aaWeapons = {}
            if d.weapons then
                for _, weapon in pairs(d.weapons) do
                    if type(weapon) == "table" and (weapon.onlytargetcategory == "VTOL"
                       or weapon.badtargetcategory == "NOTAIR"
                       or weapon.badtargetcategory == "NOTAIR LIGHTAIRSCOUT") then

                       if weapon.def then
                           aaWeapons[string.lower(weapon.def)] = true
                       end
                    end

                    if type(weapon) == "table" then
                        weapon.badtargetcategory = nil
                        weapon.onlytargetcategory = nil
                        weapon.maxangledif = 360
                    end
                end
            end

            if d.weapondefs then
                for wName, wDef in pairs(d.weapondefs) do
                    if type(wDef) == "table" then
                        local isAA = aaWeapons[string.lower(wName)] or (wDef.canattackground == false)

                        local baseDam = 0
                        if wDef.damage then
                            local dDef = tonumber(wDef.damage.default) or 0
                            local dVtol = tonumber(wDef.damage.vtol) or 0
                            baseDam = math.max(dDef, dVtol)
                        end

                        local multiplier = 1
                        if isExFlyer then
                            multiplier = multiplier * 1.5
                        end
                        if isAA then
                            multiplier = multiplier * 2.0
                        end

                        if wDef.damage and baseDam > 0 then
                            local finalDam = baseDam * multiplier
                            wDef.damage.default = finalDam
                            wDef.damage.vtol = finalDam
                            wDef.damage.subs = finalDam
                        end

                        if wDef.weaponvelocity then
                            wDef.weaponvelocity = (tonumber(wDef.weaponvelocity) or 100) * 4
                        end

                        wDef.canattackground = true

                        if wDef.waterweapon then
                            wDef.waterweapon = nil
                        end

                        wDef.badtargetcategory = nil
                        wDef.onlytargetcategory = nil

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
        end
    end
end
```

### Mã Base64 (Để nhập vào ô TweakDef):
```
bG9jYWwgZnVuY3Rpb24gZ2V0RGV0ZXJtaW5pc3RpY0NoYW5jZShuYW1lKQogICAgbG9jYWwgaGFz
aCA9IDAKICAgIGlmIG5hbWUgdGhlbgogICAgICAgIGZvciBpID0gMSwgI25hbWUgZG8KICAgICAg
ICAgICAgaGFzaCA9IChoYXNoICsgc3RyaW5nLmJ5dGUobmFtZSwgaSkgKiBpKSAlIDEwMAogICAg
ICAgIGVuZAogICAgZW5kCiAgICByZXR1cm4gaGFzaCAvIDEwMC4wCmVuZAoKaWYgV2VhcG9uRGVm
cyB0aGVuCiAgICBmb3IgbmFtZSwgd0RlZiBpbiBwYWlycyhXZWFwb25EZWZzKSBkbwogICAgICAg
IGlmIHR5cGUod0RlZikgPT0gInRhYmxlIiBhbmQgd0RlZi53ZWFwb250eXBlIH49ICJTaGllbGQi
IHRoZW4KICAgICAgICAgICAgbG9jYWwgZG1nID0gMAogICAgICAgICAgICBpZiB3RGVmLmRhbWFn
ZSBhbmQgd0RlZi5kYW1hZ2UuZGVmYXVsdCB0aGVuCiAgICAgICAgICAgICAgICBkbWcgPSB3RGVm
LmRhbWFnZS5kZWZhdWx0CiAgICAgICAgICAgIGVuZAoKICAgICAgICAgICAgbG9jYWwgcmVsb2Fk
ID0gd0RlZi5yZWxvYWR0aW1lIG9yIDEKICAgICAgICAgICAgbG9jYWwgYnVyc3QgPSB3RGVmLmJ1
cnN0IG9yIDEKICAgICAgICAgICAgbG9jYWwgcHJvamVjdGlsZXMgPSB3RGVmLnByb2plY3RpbGVz
IG9yIDEKCiAgICAgICAgICAgIGxvY2FsIGRwcyA9IChkbWcgKiBidXJzdCAqIHByb2plY3RpbGVz
KSAvIHJlbG9hZAoKICAgICAgICAgICAgbG9jYWwgZGFtYWdlTXVsdCA9IDEwMCAvICgxMDAgKyBk
cHMpCiAgICAgICAgICAgIAogICAgICAgICAgICBpZiB3RGVmLmRhbWFnZSB0aGVuCiAgICAgICAg
ICAgICAgICBmb3IgaywgdiBpbiBwYWlycyh3RGVmLmRhbWFnZSkgZG8KICAgICAgICAgICAgICAg
ICAgICB3RGVmLmRhbWFnZVtrXSA9IG1hdGgubWF4KDAuMSwgdiAqIGRhbWFnZU11bHQpCiAgICAg
ICAgICAgICAgICBlbmQKICAgICAgICAgICAgZW5kCgogICAgICAgICAgICB3RGVmLmltcHVsc2Vm
YWN0b3IgPSAod0RlZi5pbXB1bHNlZmFjdG9yIG9yIDApICogNSArIDUKICAgICAgICAgICAgd0Rl
Zi5pbXB1bHNlYm9vc3QgPSAod0RlZi5pbXB1bHNlYm9vc3Qgb3IgMCkgKiA1ICsgMgogICAgICAg
IGVuZAogICAgZW5kCmVuZAoKaWYgVW5pdERlZnMgdGhlbgogICAgZm9yIG4sIGQgaW4gcGFpcnMo
VW5pdERlZnMpIGRvIAogICAgICAgIGlmIHR5cGUoZCkgPT0gInRhYmxlIiB0aGVuCiAgICAgICAg
ICAgIGxvY2FsIGlzQ29tID0gZC5jdXN0b21wYXJhbXMgYW5kIGQuY3VzdG9tcGFyYW1zLmlzY29t
bWFuZGVyIAogICAgICAgICAgICBsb2NhbCBjaGFuY2UgPSBnZXREZXRlcm1pbmlzdGljQ2hhbmNl
KG4pCiAgICAgICAgICAgIAogICAgICAgICAgICBsb2NhbCBpc0V4Rmx5ZXIgPSBmYWxzZSAKICAg
ICAgICAgICAgIAogICAgICAgICAgICBpZiBkLmNhbmZseSBhbmQgZC5oZWFsdGggYW5kIGQuaGVh
bHRoID4gMCBhbmQgbm90IGlzQ29tIHRoZW4KICAgICAgICAgICAgICAgIGlmIGNoYW5jZSA+IDAu
NSB0aGVuCiAgICAgICAgICAgICAgICAgICAgaXNFeEZseWVyID0gdHJ1ZSAKICAgICAgICAgICAg
ICAgICAgICBkLmNhbmZseSA9IGZhbHNlIAogICAgICAgICAgICAgICAgICAgIGQuY3J1aXNlYWx0
aXR1ZGUgPSBuaWwgCiAgICAgICAgICAgICAgICAgICAgZC5ob3ZlcmF0dGFjayA9IGZhbHNlIAog
ICAgICAgICAgICAgICAgICAgIGQubW92ZW1lbnRjbGFzcyA9ICJUQU5LMyIgCiAgICAgICAgICAg
ICAgICAgICAgZC5jb2xsaWRlID0gdHJ1ZSAKICAgICAgICAgICAgICAgICAgICBkLm1heHNsb3Bl
ID0gMTUgCiAgICAgICAgICAgICAgICAgICAgZC5tYXh3YXRlcmRlcHRoID0gMTUgCiAgICAgICAg
ICAgICAgICAgICAgZC51cHJpZ2h0ID0gdHJ1ZSAKICAgICAgICAgICAgICAgICAgICBkLnR1cm5y
YXRlID0gMzUwIAogICAgICAgICAgICAgICAgICAgIGQudHVybmlucGxhY2UgPSB0cnVlIAogICAg
ICAgICAgICAgICAgICAgIGQudHVybmlucGxhY2VhbmdsZWxpbWl0ID0gOTAgCiAgICAgICAgICAg
ICAgICBlbmQKICAgICAgICAgICAgICAgIAogICAgICAgICAgICBlbHNlaWYgbm90IGQuY2FuZmx5
IGFuZCBkLmhlYWx0aCBhbmQgZC5oZWFsdGggPiAwIGFuZCAodG9udW1iZXIoZC5zcGVlZCkgb3Ig
MCkgPiAwIGFuZCBub3QgaXNDb20gdGhlbiAKICAgICAgICAgICAgICAgIGlmIGNoYW5jZSA+IDAu
NSB0aGVuCiAgICAgICAgICAgICAgICAgICAgZC5jYW5mbHkgPSB0cnVlIAogICAgICAgICAgICAg
ICAgICAgIGQuY3J1aXNlYWx0aXR1ZGUgPSAxNTAgCiAgICAgICAgICAgICAgICAgICAgZC5ob3Zl
cmF0dGFjayA9IHRydWUgCiAgICAgICAgICAgICAgICAgICAgZC51cHJpZ2h0ID0gdHJ1ZSAKICAg
ICAgICAgICAgICAgICAgICBkLnR1cm5yYXRlID0gKHRvbnVtYmVyKGQudHVybnJhdGUpIG9yIDUw
MCkgKiAxLjUgCiAgICAgICAgICAgICAgICAgICAgZC5hY2NlbGVyYXRpb24gPSAodG9udW1iZXIo
ZC5hY2NlbGVyYXRpb24pIG9yIDAuMSkgKiAyIAogICAgICAgICAgICAgICAgICAgIGQuZmxvYXRl
ciA9IGZhbHNlIAogICAgICAgICAgICAgICAgICAgIGQud2F0ZXJsaW5lID0gMCAKICAgICAgICAg
ICAgICAgICAgICBkLm1pbndhdGVyZGVwdGggPSAwIAogICAgICAgICAgICAgICAgICAgIAogICAg
ICAgICAgICAgICAgICAgIGlmIG5vdBkLmN1c3RvbXBhcmFtcyB0aGVuCiAgICAgICAgICAgICAg
ICAgICAgICAgIGQuY3VzdG9tcGFyYW1zID0ge30KICAgICAgICAgICAgICAgICAgICBlbmQKICAg
ICAgICAgICAgICAgICAgICBkLmN1c3RvbXBhcmFtcy5maWdodGVyID0gIjEiCiAgICAgICAgICAg
ICAgICBlbmQKICAgICAgICAgICAgZW5kIAogICAgICAgICAgICAgCiAgICAgICAgICAgIGxvY2Fs
IGFhV2VhcG9ucyA9IHt9CiAgICAgICAgICAgIGlmIGQud2VhcG9ucyB0aGVuIAogICAgICAgICAg
ICAgICAgZm9yIF8sIHdlYXBvbiBpbiBwYWlycyhkLndlYXBvbnMpIGRvIAogICAgICAgICAgICAg
ICAgICAgIGlmIHR5cGUod2VhcG9uKSA9PSAidGFibGUiIGFuZCAod2VhcG9uLm9ubHl0YXJnZXRj
YXRlZ29yeSA9PSAiVlRPTCIgCiAgICAgICAgICAgICAgICAgICAgICAgb3Igd2VhcG9uLmJhZHRh
cmdldGNhdGVnb3J5ID09ICJOT1RBSVIiIAogICAgICAgICAgICAgICAgICAgICAgIG9yIHdlYXBv
bi5iYWR0YXJnZXRjYXRlZ29yeSA9PSAiTk9UQUlSIExJR0hUQUlSU0NPVVQiKSB0aGVuIAogICAg
ICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgIGlmIHdlYXBvbi5kZWYg
dGhlbgogICAgICAgICAgICAgICAgICAgICAgICAgICBhYVdlYXBvbnNbc3RyaW5nLmxvd2VyKHdl
YXBvbi5kZWYpXSA9IHRydWUKICAgICAgICAgICAgICAgICAgICAgICBlbmQKICAgICAgICAgICAg
ICAgICAgICBlbmQgCgogICAgICAgICAgICAgICAgICAgIGlmIHR5cGUod2VhcG9uKSA9PSAidGFi
bGUiIHRoZW4KICAgICAgICAgICAgICAgICAgICAgICAgd2VhcG9uLmJhZHRhcmdldGNhdGVnb3J5
ID0gbmlsIAogICAgICAgICAgICAgICAgICAgICAgICB3ZWFwb24ub25seXRhcmdldGNhdGVnb3J5
ID0gbmlsIAogICAgICAgICAgICAgICAgICAgICAgICB3ZWFwb24ubWF4YW5nbGVkaWYgPSAzNjAg
CiAgICAgICAgICAgICAgICAgICAgZW5kCiAgICAgICAgICAgICAgICBlbmQgCiAgICAgICAgICAg
IGVuZCAKICAgICAgICAgICAgIAogICAgICAgICAgICBpZiBkLndlYXBvbmRlZnMgdGhlbiAKICAg
ICAgICAgICAgICAgIGZvciB3TmFtZSwgd0RlZiBpbiBwYWlycyhkLndlYXBvbmRlZnMpIGRvIAog
ICAgICAgICAgICAgICAgICAgIGlmIHR5cGUod0RlZikgPT0gInRhYmxlIiB0aGVuCiAgICAgICAg
ICAgICAgICAgICAgICAgIGxvY2FsIGlzQUEgPSBhYVdlYXBvbnNbc3RyaW5nLmxvd2VyKHdOYW1l
KV0gb3IgKHdEZWYuY2FuYXR0YWNrZ3JvdW5kID09IGZhbHNlKQoKICAgICAgICAgICAgICAgICAg
ICAgICAgbG9jYWwgYmFzZURhbSA9IDAKICAgICAgICAgICAgICAgICAgICAgICAgaWYgd0RlZi5k
YW1hZ2UgdGhlbgogICAgICAgICAgICAgICAgICAgICAgICAgICAgbG9jYWwgZERlZiA9IHRvbnVt
YmVyKHdEZWYuZGFtYWdlLmRlZmF1bHQpIG9yIDAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
IGxvY2FsIGRWdG9sID0gdG9udW1iZXIod0RlZi5kYW1hZ2UudnRvbCkgb3IgMAogICAgICAgICAg
ICAgICAgICAgICAgICAgICAgYmFzZURhbSA9IG1hdGgubWF4KGREZWYsIGRWdG9sKQogICAgICAg
ICAgICAgICAgICAgICAgICBlbmQKCiAgICAgICAgICAgICAgICAgICAgICAgIGxvY2FsIG11bHRp
cGxpZXIgPSAxCiAgICAgICAgICAgICAgICAgICAgICAgIGlmIGlzRXhGbHllciB0aGVuCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICBtdWx0aXBsaWVyID0gbXVsdGlwbGllciAqIDEuNQogICAg
ICAgICAgICAgICAgICAgICAgICBlbmQKICAgICAgICAgICAgICAgICAgICAgICAgaWYgaXNBQSB0
aGVuCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBtdWx0aXBsaWVyID0gbXVsdGlwbGllciAq
IDIuMAogICAgICAgICAgICAgICAgICAgICAgICBlbmQKCiAgICAgICAgICAgICAgICAgICAgICAg
IGlmIHdEZWYuZGFtYWdlIGFuZCBiYXNlRGFtID4gMCB0aGVuIAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgbG9jYWwgZmluYWxEYW0gPSBiYXNlRGFtICogbXVsdGlwbGllcgogICAgICAgICAg
ICAgICAgICAgICAgICAgICAgd0RlZi5kYW1hZ2UuZGVmYXVsdCA9IGZpbmFsRGFtIAogICAgICAg
ICAgICAgICAgICAgICAgICAgICAgd0RlZi5kYW1hZ2UudnRvbCA9IGZpbmFsRGFtIAogICAgICAg
ICAgICAgICAgICAgICAgICAgICAgd0RlZi5kYW1hZ2Uuc3VicyA9IGZpbmFsRGFtIAogICAgICAg
ICAgICAgICAgICAgICAgICBlbmQgCgogICAgICAgICAgICAgICAgICAgICAgICBpZiB3RGVmLndl
YXBvbnZlbG9jaXR5IHRoZW4gCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB3RGVmLndlYXBv
bnZlbG9jaXR5ID0gKHRvbnVtYmVyKHdEZWYud2VhcG9udmVsb2NpdHkpIG9yIDEwMCkgKiA0IAog
ICAgICAgICAgICAgICAgICAgICAgICBlbmQgCiAgICAgICAgICAgICAgICAgICAgICAgIAogICAg
ICAgICAgICAgICAgICAgICAgICB3RGVmLmNhbmF0dGFja2dyb3VuZCA9IHRydWUgCiAgICAgICAg
ICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICBpZiB3RGVmLndhdGVyd2Vh
cG9uIHRoZW4gCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB3RGVmLndhdGVyd2VhcG9uID0g
bmlsIAogICAgICAgICAgICAgICAgICAgICAgICBlbmQgCgogICAgICAgICAgICAgICAgICAgICAg
ICB3RGVmLmJhZHRhcmdldGNhdGVnb3J5ID0gbmlsCiAgICAgICAgICAgICAgICAgICAgICAgIHdE
ZWYub25seXRhcmdldGNhdGVnb3J5ID0gbmlsCgogICAgICAgICAgICAgICAgICAgICAgICBpZiB3
RGVmLndlYXBvbnR5cGUgPT0gIk1pc3NpbGVMYXVuY2hlciIgb3Igd0RlZi53ZWFwb250eXBlID09
ICJTdGFyYnVyc3RMYXVuY2hlciIgdGhlbiAKICAgICAgICAgICAgICAgICAgICAgICAgICAgIHdE
ZWYudG9sZXJhbmNlID0gMzIwMDAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBpZiB3RGVm
LmZsaWdodHRpbWUgdGhlbiAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB3RGVmLmZs
aWdodHRpbWUgPSAodG9udW1iZXIod0RlZi5mbGlnaHR0aW1lKSBvciAyKSAqIDIgCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICBlbmQgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBpZiB3
RGVmLnR1cm5yYXRlIHRoZW4gCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgd0RlZi50
dXJucmF0ZSA9ICh0b251bWJlcih3RGVmLnR1cm5yYXRlKSBvciAxMDAwKSAqIDIgCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICBlbmQgCiAgICAgICAgICAgICAgICAgICAgICAgIGVuZCAKICAg
ICAgICAgICAgICAgICAgICBlbmQKICAgICAgICAgICAgICAgIGVuZCAKICAgICAgICAgICAgZW5k
IAogICAgICAgIGVuZAogICAgZW5kIAplbmQK
```
