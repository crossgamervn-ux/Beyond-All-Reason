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
    - **Cập nhật sửa lỗi**: Mã đã bổ sung kiểm tra `if WeaponDefs then`, `if UnitDefs then` và `type(x) == "table"` chặt chẽ để tránh lỗi `bad argument #1 to '(for generator)'` do game truyền dữ liệu không đầy đủ trong một số ngữ cảnh.

### Script Lua:
```lua
-- TweakDef Mod: Emotional Damage + Random Mutations
-- Author: Jules
-- Description: Decreases weapon damage inversely proportional to DPS, increases knockback. Also deterministically swaps air and ground units, applying specific buffs.

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

            -- Reduce damage based on DPS: higher DPS reduces damage more.
            -- Using a curve: multiplier = 100 / (100 + dps)
            local damageMult = 100 / (100 + dps)

            if wDef.damage then
                for k, v in pairs(wDef.damage) do
                    wDef.damage[k] = math.max(0.1, v * damageMult)
                end
            end

            -- Strongly increase knockback (impulsefactor)
            wDef.impulsefactor = (wDef.impulsefactor or 0) * 5 + 5
            wDef.impulseboost = (wDef.impulseboost or 0) * 5 + 2
        end
    end
end

-- Deterministic pseudo-random chance function based on unit name
local function getDeterministicChance(name)
    local hash = 0
    if name then
        for i = 1, #name do
            hash = (hash + string.byte(name, i) * i) % 100
        end
    end
    return hash / 100.0
end

if UnitDefs then
    for n, d in pairs(UnitDefs) do
        if type(d) == "table" then
            local isCom = d.customparams and d.customparams.iscommander
            local chance = getDeterministicChance(n)

            -- Cờ đánh dấu unit là "Máy bay bị bắt đi bộ"
            local isExFlyer = false

            -- 1. Xử lý unit bay ngẫu nhiên biến thành mặt đất (tỉ lệ 50%)
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

            -- 2. Xử lý unit mặt đất ngẫu nhiên biến thành bay (tỉ lệ 50%)
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

                    -- Đánh lừa Widget để unit tự bay ngay khi vừa ra lò
                    if not d.customparams then
                        d.customparams = {}
                    end
                    d.customparams.fighter = "1"
                end
            end

            -- Tạo danh sách để "nhớ" tên các vũ khí phòng không
            local aaWeapons = {}
            if d.weapons then
                for _, weapon in pairs(d.weapons) do
                    -- Nhận diện nòng súng nào được sinh ra để bắn máy bay
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
                        -- Kiểm tra xem đạn này có phải là đạn phòng không không?
                        local isAA = aaWeapons[string.lower(wName)] or (wDef.canattackground == false)

                        -- Lấy mức sát thương chuẩn gốc (ưu tiên số cao nhất giữa đánh đất và đánh không)
                        local baseDam = 0
                        if wDef.damage then
                            local dDef = tonumber(wDef.damage.default) or 0
                            local dVtol = tonumber(wDef.damage.vtol) or 0
                            baseDam = math.max(dDef, dVtol)
                        end

                        -- Tính hệ số nhân sát thương (Multiplier)
                        local multiplier = 1
                        if isExFlyer then
                            multiplier = multiplier * 1.5  -- Tăng 1.5x DPS cho máy bay đi bộ
                        end
                        if isAA then
                            multiplier = multiplier * 2.0  -- Tăng 2x sát thương cho súng phòng không
                        end

                        -- Áp dụng sát thương mới và đồng bộ cho mọi mục tiêu
                        if wDef.damage and baseDam > 0 then
                            local finalDam = baseDam * multiplier
                            wDef.damage.default = finalDam
                            wDef.damage.vtol = finalDam
                            wDef.damage.subs = finalDam
                        end

                        -- Tăng tốc độ bay của đạn để trúng mục tiêu trên không dễ hơn
                        if wDef.weaponvelocity then
                            wDef.weaponvelocity = (tonumber(wDef.weaponvelocity) or 100) * 4
                        end

                        -- Cho phép bắn xuống đất
                        wDef.canattackground = true

                        if wDef.waterweapon then
                            wDef.waterweapon = nil
                        end

                        wDef.badtargetcategory = nil
                        wDef.onlytargetcategory = nil

                        -- Tăng cường khả năng theo dấu cho các loại tên lửa
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
LS0gVHdlYWtEZWYgTW9kOiBFbW90aW9uYWwgRGFtYWdlICsgUmFuZG9tIE11dGF0aW9ucwotLSBB
dXRob3I6IEp1bGVzCi0tIERlc2NyaXB0aW9uOiBEZWNyZWFzZXMgd2VhcG9uIGRhbWFnZSBpbnZl
cnNlbHkgcHJvcG9ydGlvbmFsIHRvIERQUywgaW5jcmVhc2VzIGtub2NrYmFjay4gQWxzbyBkZXRl
cm1pbmlzdGljYWxseSBzd2FwcyBhaXIgYW5kIGdyb3VuZCB1bml0cywgYXBwbHlpbmcgc3BlY2lm
aWMgYnVmZnMuCgppZiBXZWFwb25EZWZzIHRoZW4KICAgIGZvciBuYW1lLCB3RGVmIGluIHBhaXJz
KFdlYXBvbkRlZnMpIGRvCiAgICAgICAgaWYgdHlwZSh3RGVmKSA9PSAidGFibGUiIGFuZCB3RGVm
LndlYXBvbnR5cGUgfj0gIlNoaWVsZCIgdGhlbgogICAgICAgICAgICBsb2NhbCBkbWcgPSAwCiAg
ICAgICAgICAgIGlmIHdEZWYuZGFtYWdlIGFuZCB3RGVmLmRhbWFnZS5kZWZhdWx0IHRoZW4KICAg
ICAgICAgICAgICAgIGRtZyA9IHdEZWYuZGFtYWdlLmRlZmF1bHQKICAgICAgICAgICAgZW5kCgog
ICAgICAgICAgICBsb2NhbCByZWxvYWQgPSB3RGVmLnJlbG9hZHRpbWUgb3IgMQogICAgICAgICAg
ICBsb2NhbCBidXJzdCA9IHdEZWYuYnVyc3Qgb3IgMQogICAgICAgICAgICBsb2NhbCBwcm9qZWN0
aWxlcyA9IHdEZWYucHJvamVjdGlsZXMgb3IgMQoKICAgICAgICAgICAgbG9jYWwgZHBzID0gKGRt
ZyAqIGJ1cnN0ICogcHJvamVjdGlsZXMpIC8gcmVsb2FkCgogICAgICAgICAgICAtLSBSZWR1Y2Ug
ZGFtYWdlIGJhc2VkIG9uIERQUzogaGlnaGVyIERQUyByZWR1Y2VzIGRhbWFnZSBtb3JlLgogICAg
ICAgICAgICAtLSBVc2luZyBhIGN1cnZlOiBtdWx0aXBsaWVyID0gMTAwIC8gKDEwMCArIGRwcykK
ICAgICAgICAgICAgbG9jYWwgZGFtYWdlTXVsdCA9IDEwMCAvICgxMDAgKyBkcHMpCiAgICAgICAg
ICAgIAogICAgICAgICAgICBpZiB3RGVmLmRhbWFnZSB0aGVuCiAgICAgICAgICAgICAgICBmb3Ig
aywgdiBpbiBwYWlycyh3RGVmLmRhbWFnZSkgZG8KICAgICAgICAgICAgICAgICAgICB3RGVmLmRh
bWFnZVtrXSA9IG1hdGgubWF4KDAuMSwgdiAqIGRhbWFnZU11bHQpCiAgICAgICAgICAgICAgICBl
bmQKICAgICAgICAgICAgZW5kCgogICAgICAgICAgICAtLSBTdHJvbmdseSBpbmNyZWFzZSBrbm9j
a2JhY2sgKGltcHVsc2VmYWN0b3IpCiAgICAgICAgICAgIHdEZWYuaW1wdWxzZWZhY3RvciA9ICh3
RGVmLmltcHVsc2VmYWN0b3Igb3IgMCkgKiA1ICsgNQogICAgICAgICAgICB3RGVmLmltcHVsc2Vi
b29zdCA9ICh3RGVmLmltcHVsc2Vib29zdCBvciAwKSAqIDUgKyAyCiAgICAgICAgZW5kCiAgICBl
bmQKZW5kCgotLSBEZXRlcm1pbmlzdGljIHBzZXVkby1yYW5kb20gY2hhbmNlIGZ1bmN0aW9uIGJh
c2VkIG9uIHVuaXQgbmFtZQpsb2NhbCBmdW5jdGlvbiBnZXREZXRlcm1pbmlzdGljQ2hhbmNlKG5h
bWUpCiAgICBsb2NhbCBoYXNoID0gMAogICAgaWYgbmFtZSB0aGVuCiAgICAgICAgZm9yIGkgPSAx
LCAjbmFtZSBkbwogICAgICAgICAgICBoYXNoID0gKGhhc2ggKyBzdHJpbmcuYnl0ZShuYW1lLCBp
KSAqIGkpICUgMTAwCiAgICAgICAgZW5kCiAgICBlbmQKICAgIHJldHVybiBoYXNoIC8gMTAwLjAK
ZW5kCgppZiBVbml0RGVmcyB0aGVuCiAgICBmb3IgbiwgZCBpbiBwYWlycyhVbml0RGVmcykgZG8g
CiAgICAgICAgaWYgdHlwZShkKSA9PSAidGFibGUiIHRoZW4KICAgICAgICAgICAgbG9jYWwgaXND
b20gPSBkLmN1c3RvbXBhcmFtcyBhbmQgZC5jdXN0b21wYXJhbXMuaXNjb21tYW5kZXIgCiAgICAg
ICAgICAgIGxvY2FsIGNoYW5jZSA9IGdldERldGVybWluaXN0aWNDaGFuY2UobikKICAgICAgICAg
ICAgCiAgICAgICAgICAgIC0tIEPhu50gxJHDoW5oIGThuqV1IHVuaXQgbMOgICJNw6F5IGJheSBi
4buLIGLhuq90IMSRaSBi4buZIgogICAgICAgICAgICBsb2NhbCBpc0V4Rmx5ZXIgPSBmYWxzZSAK
ICAgICAgICAgICAgIAogICAgICAgICAgICAtLSAxLiBY4butIGzDvSB1bml0IGJheSBuZ+G6q3Ug
bmhpw6puIGJp4bq/biB0aMOgbmggbeG6t3QgxJHhuqV0ICh04buJIGzhu4cgNTAlKQogICAgICAg
ICAgICBpZiBkLmNhbmZseSBhbmQgZC5oZWFsdGggYW5kIGQuaGVhbHRoID4gMCBhbmQgbm90IGlz
Q29tIHRoZW4KICAgICAgICAgICAgICAgIGlmIGNoYW5jZSA+IDAuNSB0aGVuCiAgICAgICAgICAg
ICAgICAgICAgaXNFeEZseWVyID0gdHJ1ZSAKICAgICAgICAgICAgICAgICAgICBkLmNhbmZseSA9
IGZhbHNlIAogICAgICAgICAgICAgICAgICAgIGQuY3J1aXNlYWx0aXR1ZGUgPSBuaWwgCiAgICAg
ICAgICAgICAgICAgICAgZC5ob3ZlcmF0dGFjayA9IGZhbHNlIAogICAgICAgICAgICAgICAgICAg
IGQubW92ZW1lbnRjbGFzcyA9ICJUQU5LMyIgCiAgICAgICAgICAgICAgICAgICAgZC5jb2xsaWRl
ID0gdHJ1ZSAKICAgICAgICAgICAgICAgICAgICBkLm1heHNsb3BlID0gMTUgCiAgICAgICAgICAg
ICAgICAgICAgZC5tYXh3YXRlcmRlcHRoID0gMTUgCiAgICAgICAgICAgICAgICAgICAgZC51cHJp
Z2h0ID0gdHJ1ZSAKICAgICAgICAgICAgICAgICAgICBkLnR1cm5yYXRlID0gMzUwIAogICAgICAg
ICAgICAgICAgICAgIGQudHVybmlucGxhY2UgPSB0cnVlIAogICAgICAgICAgICAgICAgICAgIGQu
dHVybmlucGxhY2VhbmdsZWxpbWl0ID0gOTAgCiAgICAgICAgICAgICAgICBlbmQKICAgICAgICAg
ICAgICAgIAogICAgICAgICAgICAtLSAyLiBY4butIGzDvSB1bml0IG3hurd0IMSR4bqldCBuZ+G6
q3Ugbmhpw6puIGJp4bq/biB0aMOgbmggYmF5ICh04buJIGzhu4cgNTAlKQogICAgICAgICAgICBl
bHNlaWYgbm90IGQuY2FuZmx5IGFuZCBkLmhlYWx0aCBhbmQgZC5oZWFsdGggPiAwIGFuZCAodG9u
dW1iZXIoZC5zcGVlZCkgb3IgMCkgPiAwIGFuZCBub3QgaXNDb20gdGhlbiAKICAgICAgICAgICAg
ICAgIGlmIGNoYW5jZSA+IDAuNSB0aGVuCiAgICAgICAgICAgICAgICAgICAgZC5jYW5mbHkgPSB0
cnVlIAogICAgICAgICAgICAgICAgICAgIGQuY3J1aXNlYWx0aXR1ZGUgPSAxNTAgCiAgICAgICAg
ICAgICAgICAgICAgZC5ob3ZlcmF0dGFjayA9IHRydWUgCiAgICAgICAgICAgICAgICAgICAgZC51
cHJpZ2h0ID0gdHJ1ZSAKICAgICAgICAgICAgICAgICAgICBkLnR1cm5yYXRlID0gKHRvbnVtYmVy
KGQudHVybnJhdGUpIG9yIDUwMCkgKiAxLjUgCiAgICAgICAgICAgICAgICAgICAgZC5hY2NlbGVy
YXRpb24gPSAodG9udW1iZXIoZC5hY2NlbGVyYXRpb24pIG9yIDAuMSkgKiAyIAogICAgICAgICAg
ICAgICAgICAgIGQuZmxvYXRlciA9IGZhbHNlIAogICAgICAgICAgICAgICAgICAgIGQud2F0ZXJs
aW5lID0gMCAKICAgICAgICAgICAgICAgICAgICBkLm1pbndhdGVyZGVwdGggPSAwIAogICAgICAg
ICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgIC0tIMSQw6FuaCBs4burYSBXaWRnZXQg
xJHhu4MgdW5pdCB04buxIGJheSBuZ2F5IGtoaSB24burYSByYSBsw7IKICAgICAgICAgICAgICAg
ICAgICBpZiBub3QgZC5jdXN0b21wYXJhbXMgdGhlbgogICAgICAgICAgICAgICAgICAgICAgICBk
LmN1c3RvbXBhcmFtcyA9IHt9CiAgICAgICAgICAgICAgICAgICAgZW5kCiAgICAgICAgICAgICAg
ICAgICAgZC5jdXN0b21wYXJhbXMuZmlnaHRlciA9ICIxIgogICAgICAgICAgICAgICAgZW5kCiAg
ICAgICAgICAgIGVuZCAKICAgICAgICAgICAgIAogICAgICAgICAgICAtLSBU4bqhbyBkYW5oIHPD
oWNoIMSR4buDICJuaOG7myIgdMOqbiBjw6FjIHbFqSBraMOtIHBow7JuZyBraMO0bmcKICAgICAg
ICAgICAgbG9jYWwgYWFXZWFwb25zID0ge30KICAgICAgICAgICAgaWYgZC53ZWFwb25zIHRoZW4g
CiAgICAgICAgICAgICAgICBmb3IgXywgd2VhcG9uIGluIHBhaXJzKGQud2VhcG9ucykgZG8gCiAg
ICAgICAgICAgICAgICAgICAgLS0gTmjhuq1uIGRp4buHbiBuw7JuZyBzw7puZyBuw6BvIMSRxrDh
u6NjIHNpbmggcmEgxJHhu4MgYuG6r24gbcOheSBiYXkKICAgICAgICAgICAgICAgICAgICBpZiB0
eXBlKHdlYXBvbikgPT0gInRhYmxlIiBhbmQgKHdlYXBvbi5vbmx5dGFyZ2V0Y2F0ZWdvcnkgPT0g
IlZUT0wiIAogICAgICAgICAgICAgICAgICAgICAgIG9yIHdlYXBvbi5iYWR0YXJnZXRjYXRlZ29y
eSA9PSAiTk9UQUlSIiAKICAgICAgICAgICAgICAgICAgICAgICBvciB3ZWFwb24uYmFkdGFyZ2V0
Y2F0ZWdvcnkgPT0gIk5PVEFJUiBMSUdIVEFJUlNDT1VUIikgdGhlbiAKICAgICAgICAgICAgICAg
ICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICBpZiB3ZWFwb24uZGVmIHRoZW4KICAgICAg
ICAgICAgICAgICAgICAgICAgICAgYWFXZWFwb25zW3N0cmluZy5sb3dlcih3ZWFwb24uZGVmKV0g
PSB0cnVlCiAgICAgICAgICAgICAgICAgICAgICAgZW5kCiAgICAgICAgICAgICAgICAgICAgZW5k
IAoKICAgICAgICAgICAgICAgICAgICBpZiB0eXBlKHdlYXBvbikgPT0gInRhYmxlIiB0aGVuCiAg
ICAgICAgICAgICAgICAgICAgICAgIHdlYXBvbi5iYWR0YXJnZXRjYXRlZ29yeSA9IG5pbCAKICAg
ICAgICAgICAgICAgICAgICAgICAgd2VhcG9uLm9ubHl0YXJnZXRjYXRlZ29yeSA9IG5pbCAKICAg
ICAgICAgICAgICAgICAgICAgICAgd2VhcG9uLm1heGFuZ2xlZGlmID0gMzYwIAogICAgICAgICAg
ICAgICAgICAgIGVuZAogICAgICAgICAgICAgICAgZW5kIAogICAgICAgICAgICBlbmQgCiAgICAg
ICAgICAgICAKICAgICAgICAgICAgaWYgZC53ZWFwb25kZWZzIHRoZW4gCiAgICAgICAgICAgICAg
ICBmb3Igd05hbWUsIHdEZWYgaW4gcGFpcnMoZC53ZWFwb25kZWZzKSBkbyAKICAgICAgICAgICAg
ICAgICAgICBpZiB0eXBlKHdEZWYpID09ICJ0YWJsZSIgdGhlbgogICAgICAgICAgICAgICAgICAg
ICAgICAtLSBLaeG7g20gdHJhIHhlbSDEkeG6oW4gbsOgeSBjw7MgcGjhuqNpIGzDoCDEkeG6oW4g
cGjDsm5nIGtow7RuZyBraMO0bmc/CiAgICAgICAgICAgICAgICAgICAgICAgIGxvY2FsIGlzQUEg
PSBhYVdlYXBvbnNbc3RyaW5nLmxvd2VyKHdOYW1lKV0gb3IgKHdEZWYuY2FuYXR0YWNrZ3JvdW5k
ID09IGZhbHNlKQoKICAgICAgICAgICAgICAgICAgICAgICAgLS0gTOG6pXkgbeG7qWMgc8OhdCB0
aMawxqFuZyBjaHXhuqluIGfhu5FjICjGsHUgdGnDqm4gc+G7kSBjYW8gbmjhuqV0IGdp4buvYSDE
kcOhbmggxJHhuqV0IHbDoCDEkcOhbmgga2jDtG5nKQogICAgICAgICAgICAgICAgICAgICAgICBs
b2NhbCBiYXNlRGFtID0gMAogICAgICAgICAgICAgICAgICAgICAgICBpZiB3RGVmLmRhbWFnZSB0
aGVuCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBsb2NhbCBkRGVmID0gdG9udW1iZXIod0Rl
Zi5kYW1hZ2UuZGVmYXVsdCkgb3IgMAogICAgICAgICAgICAgICAgICAgICAgICAgICAgbG9jYWwg
ZFZ0b2wgPSB0b251bWJlcih3RGVmLmRhbWFnZS52dG9sKSBvciAwCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICBiYXNlRGFtID0gbWF0aC5tYXgoZERlZiwgZFZ0b2wpCiAgICAgICAgICAgICAg
ICAgICAgICAgIGVuZAoKICAgICAgICAgICAgICAgICAgICAgICAgLS0gVMOtbmggaOG7hyBz4buR
IG5ow6JuIHPDoXQgdGjGsMahbmcgKE11bHRpcGxpZXIpCiAgICAgICAgICAgICAgICAgICAgICAg
IGxvY2FsIG11bHRpcGxpZXIgPSAxCiAgICAgICAgICAgICAgICAgICAgICAgIGlmIGlzRXhGbHll
ciB0aGVuCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBtdWx0aXBsaWVyID0gbXVsdGlwbGll
ciAqIDEuNSAgLS0gVMSDbmcgMS41eCBEUFMgY2hvIG3DoXkgYmF5IMSRaSBi4buZCiAgICAgICAg
ICAgICAgICAgICAgICAgIGVuZAogICAgICAgICAgICAgICAgICAgICAgICBpZiBpc0FBIHRoZW4K
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIG11bHRpcGxpZXIgPSBtdWx0aXBsaWVyICogMi4w
ICAtLSBUxINuZyAyeCBzw6F0IHRoxrDGoW5nIGNobyBzw7puZyBwaMOybmcga2jDtG5nCiAgICAg
ICAgICAgICAgICAgICAgICAgIGVuZAoKICAgICAgICAgICAgICAgICAgICAgICAgLS0gw4FwIGTh
u6VuZyBzw6F0IHRoxrDGoW5nIG3hu5tpIHbDoCDEkeG7k25nIGLhu5kgY2hvIG3hu41pIG3hu6Vj
IHRpw6p1CiAgICAgICAgICAgICAgICAgICAgICAgIGlmIHdEZWYuZGFtYWdlIGFuZCBiYXNlRGFt
ID4gMCB0aGVuIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgbG9jYWwgZmluYWxEYW0gPSBi
YXNlRGFtICogbXVsdGlwbGllcgogICAgICAgICAgICAgICAgICAgICAgICAgICAgd0RlZi5kYW1h
Z2UuZGVmYXVsdCA9IGZpbmFsRGFtIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgd0RlZi5k
YW1hZ2UudnRvbCA9IGZpbmFsRGFtIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgd0RlZi5k
YW1hZ2Uuc3VicyA9IGZpbmFsRGFtIAogICAgICAgICAgICAgICAgICAgICAgICBlbmQgCgogICAg
ICAgICAgICAgICAgICAgICAgICAtLSBUxINuZyB04buRYyDEkeG7mSBiYXkgY+G7p2EgxJHhuqFu
IMSR4buDIHRyw7puZyBt4bulYyB0acOqdSB0csOqbiBraMO0bmcgZOG7hSBoxqFuCiAgICAgICAg
ICAgICAgICAgICAgICAgIGlmIHdEZWYud2VhcG9udmVsb2NpdHkgdGhlbiAKICAgICAgICAgICAg
ICAgICAgICAgICAgICAgIHdEZWYud2VhcG9udmVsb2NpdHkgPSAodG9udW1iZXIod0RlZi53ZWFw
b252ZWxvY2l0eSkgb3IgMTAwKSAqIDQgCiAgICAgICAgICAgICAgICAgICAgICAgIGVuZCAKICAg
ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgIC0tIENobyBwaMOp
cCBi4bqvbiB4deG7kW5nIMSR4bqldAogICAgICAgICAgICAgICAgICAgICAgICB3RGVmLmNhbmF0
dGFja2dyb3VuZCA9IHRydWUgCiAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
ICAgICAgICAgICBpZiB3RGVmLndhdGVyd2VhcG9uIHRoZW4gCiAgICAgICAgICAgICAgICAgICAg
ICAgICAgICB3RGVmLndhdGVyd2VhcG9uID0gbmlsIAogICAgICAgICAgICAgICAgICAgICAgICBl
bmQgCgogICAgICAgICAgICAgICAgICAgICAgICB3RGVmLmJhZHRhcmdldGNhdGVnb3J5ID0gbmls
CiAgICAgICAgICAgICAgICAgICAgICAgIHdEZWYub25seXRhcmdldGNhdGVnb3J5ID0gbmlsCgog
ICAgICAgICAgICAgICAgICAgICAgICAtLSBUxINuZyBjxrDhu51uZyBraOG6oyBuxINuZyB0aGVv
IGThuqV1IGNobyBjw6FjIGxv4bqhaSB0w6puIGzhu61hCiAgICAgICAgICAgICAgICAgICAgICAg
IGlmIHdEZWYud2VhcG9udHlwZSA9PSAiTWlzc2lsZUxhdW5jaGVyIiBvciB3RGVmLndlYXBvbnR5
cGUgPT0gIlN0YXJidXJzdExhdW5jaGVyIiB0aGVuIAogICAgICAgICAgICAgICAgICAgICAgICAg
ICAgd0RlZi50b2xlcmFuY2UgPSAzMjAwMCAKICAgICAgICAgICAgICAgICAgICAgICAgICAgIGlm
IHdEZWYuZmxpZ2h0dGltZSB0aGVuIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHdE
ZWYuZmxpZ2h0dGltZSA9ICh0b251bWJlcih3RGVmLmZsaWdodHRpbWUpIG9yIDIpICogMiAKICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIGVuZCAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
IGlmIHdEZWYudHVybnJhdGUgdGhlbiAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB3
RGVmLnR1cm5yYXRlID0gKHRvbnVtYmVyKHdEZWYudHVybnJhdGUpIG9yIDEwMDApICogMiAKICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIGVuZCAKICAgICAgICAgICAgICAgICAgICAgICAgZW5k
IAogICAgICAgICAgICAgICAgICAgIGVuZAogICAgICAgICAgICAgICAgZW5kIAogICAgICAgICAg
ICBlbmQgCiAgICAgICAgZW5kCiAgICBlbmQgCmVuZAo=
```
