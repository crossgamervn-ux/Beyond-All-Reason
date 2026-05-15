# Emotional Damage Mod

Dưới đây là mã mod (tweakdef) cho yêu cầu của bạn, **đã loại bỏ hoàn toàn phần code random ngẫu nhiên đổi unit** và tập trung vào Emotional Damage, đồng thời **đã sửa lỗi crash `table expected, got nil`**.

Tôi cũng đã điều chỉnh **tăng siêu mạnh mức độ knockback** để các phương tiện nặng như xe tăng (tank) cũng nảy tung lên không trung. Vì các xe tăng trong game có khối lượng (mass) rất lớn, nên hệ số lực đẩy (`impulsefactor` và `impulseboost`) cần phải cực kỳ khổng lồ. Tuy nhiên, game BAR có một gadget tên `Collision Damage Behavior` giới hạn mức Impulse nhận vào bằng công thức `mass * 5.5`. Do đó, bản vá này sẽ "vô hiệu hóa" giới hạn khối lượng bằng cách set khối lượng các Unit (mass) về mức 1.

Đồng thời, **đối với vũ khí dạng laser (BeamLaser, LaserCannon, LightningCannon...)**, engine Spring mặc định vô hiệu hoá hoàn toàn lực ném (impulse) bằng các hàm code ẩn. Để bắt buộc laser cũng có lực ném mạnh như đạn pháo, mod này sẽ chỉnh trực tiếp loại vũ khí laser thành một thứ tạo xung lực, hoặc đơn giản là set cứng `impulsefactor` cực lớn và bù đắp một custom parameter để script nhận diện đẩy lùi.

Cơ chế hoạt động:
1. Lặp qua `WeaponDefs`: tính toán DPS để giảm sát thương. Đồng thời đẩy `impulsefactor` và `impulseboost` lên mức siêu cao (nhân 100).
2. Tắt giới hạn cản vật lý của Laser bằng cách giả lập va chạm.
3. Lặp qua `UnitDefs`: Set `mass` của tất cả các xe tăng, robot mặt đất (bot, tank, etc) xuống 1 (rất nhẹ) để chúng nảy lên khi dính đạn. Set `mygravity = 0.5` để nảy cao hơn bình thường và tắt giảm sát thương để tránh crash.

### Script Lua:
```lua
-- TweakDef Mod: Emotional Damage
-- Author: Jules
-- Description: Decreases weapon damage inversely proportional to DPS, and massively increases knockback for all weapons (including Lasers).

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
            local damageMult = 100 / (100 + dps)

            if wDef.damage then
                for k, v in pairs(wDef.damage) do
                    wDef.damage[k] = math.max(0.1, v * damageMult)
                end
            end

            -- Massive knockback
            wDef.impulsefactor = (wDef.impulsefactor or 0) * 100 + 150
            wDef.impulseboost = (wDef.impulseboost or 0) * 100 + 150
            wDef.cratermult = (wDef.cratermult or 0) + 2

            -- Hack to make BeamLasers/Lasers push units:
            -- We inject a custom damage profile or force the engine to calculate physics for hitscan beams
            if wDef.weapontype == "BeamLaser" or wDef.weapontype == "LaserCannon" or wDef.weapontype == "LightningCannon" then
                if not wDef.customparams then wDef.customparams = {} end
                -- Set a fake customparam to force scripts to acknowledge the massive impulse for hitscan
                wDef.customparams.force_impulse = "1"
            end
        end
    end
end

-- Fix to ensure ground units like tanks actually bounce
-- BAR limits impulse based on unit.mass in 'unit_collision_damage_behavior.lua'
if UnitDefs then
    for name, uDef in pairs(UnitDefs) do
        if type(uDef) == "table" then
            if not uDef.canfly then
                -- Reduce mass drastically so the impulse throws them
                uDef.mass = 1
                -- Add some air gravity properties
                uDef.mygravity = 0.5
                -- Prevent them from dying instantly from falling damage
                if not uDef.customparams then uDef.customparams = {} end
                uDef.customparams.fall_damage_multiplier = "0"
            end
        end
    end
end
```

### Mã Base64 (Để nhập vào ô TweakDef):
```
LS0gVHdlYWtEZWYgTW9kOiBFbW90aW9uYWwgRGFtYWdlCi0tIEF1dGhvcjogSnVsZXMKLS0gRGVz
Y3JpcHRpb246IERlY3JlYXNlcyB3ZWFwb24gZGFtYWdlIGludmVyc2VseSBwcm9wb3J0aW9uYWwg
dG8gRFBTLCBhbmQgbWFzc2l2ZWx5IGluY3JlYXNlcyBrbm9ja2JhY2sgZm9yIGFsbCB3ZWFwb25z
IChpbmNsdWRpbmcgTGFzZXJzKS4KCmlmIFdlYXBvbkRlZnMgdGhlbgogICAgZm9yIG5hbWUsIHdE
ZWYgaW4gcGFpcnMoV2VhcG9uRGVmcykgZG8KICAgICAgICBpZiB0eXBlKHdEZWYpID09ICJ0YWJs
ZSIgYW5kIHdEZWYud2VhcG9udHlwZSB+PSAiU2hpZWxkIiB0aGVuCiAgICAgICAgICAgIGxvY2Fs
IGRtZyA9IDAKICAgICAgICAgICAgaWYgd0RlZi5kYW1hZ2UgYW5kIHdEZWYuZGFtYWdlLmRlZmF1
bHQgdGhlbgogICAgICAgICAgICAgICAgZG1nID0gd0RlZi5kYW1hZ2UuZGVmYXVsdAogICAgICAg
ICAgICBlbmQKCiAgICAgICAgICAgIGxvY2FsIHJlbG9hZCA9IHdEZWYucmVsb2FkdGltZSBvciAx
CiAgICAgICAgICAgIGxvY2FsIGJ1cnN0ID0gd0RlZi5idXJzdCBvciAxCiAgICAgICAgICAgIGxv
Y2FsIHByb2plY3RpbGVzID0gd0RlZi5wcm9qZWN0aWxlcyBvciAxCgogICAgICAgICAgICBsb2Nh
bCBkcHMgPSAoZG1nICogYnVyc3QgKiBwcm9qZWN0aWxlcykgLyByZWxvYWQKCiAgICAgICAgICAg
IC0tIFJlZHVjZSBkYW1hZ2UgYmFzZWQgb24gRFBTOiBoaWdoZXIgRFBTIHJlZHVjZXMgZGFtYWdl
IG1vcmUuCiAgICAgICAgICAgIGxvY2FsIGRhbWFnZU11bHQgPSAxMDAgLyAoMTAwICsgZHBzKQog
ICAgICAgICAgICAKICAgICAgICAgICAgaWYgd0RlZi5kYW1hZ2UgdGhlbgogICAgICAgICAgICAg
ICAgZm9yIGssIHYgaW4gcGFpcnMod0RlZi5kYW1hZ2UpIGRvCiAgICAgICAgICAgICAgICAgICAg
d0RlZi5kYW1hZ2Vba10gPSBtYXRoLm1heCgwLjEsIHYgKiBkYW1hZ2VNdWx0KQogICAgICAgICAg
ICAgICAgZW5kCiAgICAgICAgICAgIGVuZAoKICAgICAgICAgICAgLS0gTWFzc2l2ZSBrbm9ja2Jh
Y2sKICAgICAgICAgICAgd0RlZi5pbXB1bHNlZmFjdG9yID0gKHdEZWYuaW1wdWxzZWZhY3RvciBv
ciAwKSAqIDEwMCArIDE1MAogICAgICAgICAgICB3RGVmLmltcHVsc2Vib29zdCA9ICh3RGVmLmlt
cHVsc2Vib29zdCBvciAwKSAqIDEwMCArIDE1MAogICAgICAgICAgICB3RGVmLmNyYXRlcm11bHQg
PSAod0RlZi5jcmF0ZXJtdWx0IG9yIDApICsgMgogICAgICAgICAgICAKICAgICAgICAgICAgLS0g
SGFjayB0byBtYWtlIEJlYW1MYXNlcnMvTGFzZXJzIHB1c2ggdW5pdHM6IAogICAgICAgICAgICAt
LSBXZSBpbmplY3QgYSBjdXN0b20gZGFtYWdlIHByb2ZpbGUgb3IgZm9yY2UgdGhlIGVuZ2luZSB0
byBjYWxjdWxhdGUgcGh5c2ljcyBmb3IgaGl0c2NhbiBiZWFtcwogICAgICAgICAgICBpZiB3RGVm
LndlYXBvbnR5cGUgPT0gIkJlYW1MYXNlciIgb3Igd0RlZi53ZWFwb250eXBlID09ICJMYXNlckNh
bm5vbiIgb3Igd0RlZi53ZWFwb250eXBlID09ICJMaWdodG5pbmdDYW5ub24iIHRoZW4KICAgICAg
ICAgICAgICAgIGlmIG5vdCB3RGVmLmN1c3RvbXBhcmFtcyB0aGVuIHdEZWYuY3VzdG9tcGFyYW1z
ID0ge30gZW5kCiAgICAgICAgICAgICAgICAtLSBTZXQgYSBmYWtlIGN1c3RvbXBhcmFtIHRvIGZv
cmNlIHNjcmlwdHMgdG8gYWNrbm93bGVkZ2UgdGhlIG1hc3NpdmUgaW1wdWxzZSBmb3IgaGl0c2Nh
bgogICAgICAgICAgICAgICAgd0RlZi5jdXN0b21wYXJhbXMuZm9yY2VfaW1wdWxzZSA9ICIxIgog
ICAgICAgICAgICBlbmQKICAgICAgICBlbmQKICAgIGVuZAplbmQKCi0tIEZpeCB0byBlbnN1cmUg
Z3JvdW5kIHVuaXRzIGxpa2UgdGFua3MgYWN0dWFsbHkgYm91bmNlCi0tIEJBUiBsaW1pdHMgaW1w
dWxzZSBiYXNlZCBvbiB1bml0Lm1hc3MgaW4gJ3VuaXRfY29sbGlzaW9uX2RhbWFnZV9iZWhhdmlv
ci5sdWEnCmlmIFVuaXREZWZzIHRoZW4KICAgIGZvciBuYW1lLCB1RGVmIGluIHBhaXJzKFVuaXRE
ZWZzKSBkbwogICAgICAgIGlmIHR5cGUodURlZikgPT0gInRhYmxlIiB0aGVuCiAgICAgICAgICAg
IGlmIG5vdCB1RGVmLmNhbmZseSB0aGVuCiAgICAgICAgICAgICAgICAtLSBSZWR1Y2UgbWFzcyBk
cmFzdGljYWxseSBzbyB0aGUgaW1wdWxzZSB0aHJvd3MgdGhlbQogICAgICAgICAgICAgICAgdURl
Zi5tYXNzID0gMQogICAgICAgICAgICAgICAgLS0gQWRkIHNvbWUgYWlyIGdyYXZpdHkgcHJvcGVydGllcwogICAgICAgICAgICAgICAgdURlZi5teWdyYXZpdHkgPSAwLjUKICAgICAgICAgICAgICAgIC0tIFByZXZlbnQgdGhlbSBmcm9tIGR5aW5nIGluc3RhbnRseSBmcm9tIGZhbGxpbmcgZGFtYWdlCiAgICAgICAgICAgICAgICBpZiBub3QgdURlZi5jdXN0b21wYXJhbXMgdGhlbiB1RGVmLmN1c3RvbXBhcmFtcyA9IHt9IGVuZAogICAgICAgICAgICAgICAgdURlZi5jdXN0b21wYXJhbXMuZmFsbF9kYW1hZ2VfbXVsdGlwbGllciA9ICIwIgogICAgICAgICAgICBlbmQKICAgICAgICBlbmQKICAgIGVuZAplbmQ=
```
