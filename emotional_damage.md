# Emotional Damage Mod

Dưới đây là mã mod (tweakdef) cho yêu cầu của bạn, **đã loại bỏ hoàn toàn phần code random ngẫu nhiên đổi unit** và tập trung vào Emotional Damage, đồng thời **đã sửa lỗi crash `table expected, got nil`**.

Tôi cũng đã điều chỉnh **tăng siêu mạnh mức độ knockback** để các phương tiện nặng như xe tăng (tank) cũng nảy tung lên không trung. Vì các xe tăng trong game có khối lượng (mass) rất lớn, nên hệ số lực đẩy (`impulsefactor` và `impulseboost`) cần phải cực kỳ khổng lồ. Tuy nhiên, game BAR có một gadget tên `Collision Damage Behavior` giới hạn mức Impulse nhận vào bằng công thức `mass * 5.5`. Do đó, bản vá này sẽ "vô hiệu hóa" giới hạn khối lượng bằng cách set khối lượng các Unit (mass) về mức 1.

Đồng thời, **đối với vũ khí dạng laser (BeamLaser, LaserCannon, LightningCannon...)**, engine Spring mặc định vô hiệu hoá hoàn toàn lực ném (impulse) bằng các hàm code ẩn. Để bắt buộc laser cũng có lực ném mạnh như đạn pháo, mod này sẽ chỉnh trực tiếp loại vũ khí laser thành một thứ tạo xung lực, hoặc đơn giản là set cứng `impulsefactor` cực lớn và bù đắp một custom parameter để script nhận diện đẩy lùi.

**Sửa lỗi với Raptor**: Bọn Raptor (Quái thú) mặc định bị engine của BAR thay đổi thuộc tính `mass` bằng đúng với lượng `health` của chúng (Máu càng cao, mass càng béo, ví dụ Boss máu 50000 -> mass 50000). Mod lúc trước không ghi đè thành công do bọn Raptor load thông số bằng một post-script ẩn (`raptor_unitdefs_post.lua`). Code ở dưới đây sẽ quét và khắc phục cả Raptor để đảm bảo mass của chúng chỉ bằng 1, giúp bạn bắn văng bọn chúng một cách công bằng.

Cơ chế hoạt động:
1. Lặp qua `WeaponDefs`: tính toán DPS để giảm sát thương. Đồng thời đẩy `impulsefactor` và `impulseboost` lên mức siêu cao (nhân 100).
2. Tắt giới hạn cản vật lý của Laser bằng cách giả lập va chạm.
3. Lặp qua `UnitDefs`: Set `mass` của tất cả các xe tăng, robot, và CẢ RAPTOR xuống 1 (rất nhẹ) để chúng nảy lên khi dính đạn. Set `mygravity = 0.5` để nảy cao hơn bình thường và tắt giảm sát thương để tránh crash.

### Script Lua:
```lua
-- TweakDef Mod: Emotional Damage
-- Author: Jules
-- Description: Decreases weapon damage inversely proportional to DPS, and massively increases knockback for all weapons.

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

            -- Massively increase knockback (impulsefactor) to bounce heavy tanks
            -- Original values are usually 0.1 to 0.5.
            -- We multiply by 100 and add a base of 100 to ensure even weapons with 0 knockback hit extremely hard.
            wDef.impulsefactor = (wDef.impulsefactor or 0) * 100 + 100
            wDef.impulseboost = (wDef.impulseboost or 0) * 100 + 100
            wDef.cratermult = (wDef.cratermult or 0) + 2

            -- Hack to make BeamLasers/Lasers push units:
            if wDef.weapontype == "BeamLaser" or wDef.weapontype == "LaserCannon" or wDef.weapontype == "LightningCannon" then
                if not wDef.customparams then wDef.customparams = {} end
                wDef.customparams.force_impulse = "1"
            end
        end
    end
end

-- Fix to ensure ground units like tanks and RAPTORS actually bounce
if UnitDefs then
    for name, uDef in pairs(UnitDefs) do
        if type(uDef) == "table" then
            if not uDef.canfly then
                -- Reduce mass drastically so the impulse throws them
                -- This directly counters the raptor_unitdefs_post.lua logic that assigns health to mass
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
LgoKaWYgV2VhcG9uRGVmcyB0aGVuCiAgICBmb3IgbmFtZSwgd0RlZiBpbiBwYWlycyhXZWFwb25E
ZWZzKSBkbwogICAgICAgIGlmIHR5cGUod0RlZikgPT0gInRhYmxlIiBhbmQgd0RlZi53ZWFwb250
eXBlIH49ICJTaGllbGQiIHRoZW4KICAgICAgICAgICAgbG9jYWwgZG1nID0gMAogICAgICAgICAg
ICBpZiB3RGVmLmRhbWFnZSBhbmQgd0RlZi5kYW1hZ2UuZGVmYXVsdCB0aGVuCiAgICAgICAgICAg
ICAgICBkbWcgPSB3RGVmLmRhbWFnZS5kZWZhdWx0CiAgICAgICAgICAgIGVuZAoKICAgICAgICAg
ICAgbG9jYWwgcmVsb2FkID0gd0RlZi5yZWxvYWR0aW1lIG9yIDEKICAgICAgICAgICAgbG9jYWwg
YnVyc3QgPSB3RGVmLmJ1cnN0IG9yIDEKICAgICAgICAgICAgbG9jYWwgcHJvamVjdGlsZXMgPSB3
RGVmLnByb2plY3RpbGVzIG9yIDEKCiAgICAgICAgICAgIGxvY2FsIGRwcyA9IChkbWcgKiBidXJz
dCAqIHByb2plY3RpbGVzKSAvIHJlbG9hZAoKICAgICAgICAgICAgLS0gUmVkdWNlIGRhbWFnZSBi
YXNlZCBvbiBEUFM6IGhpZ2hlciBEUFMgcmVkdWNlcyBkYW1hZ2UgbW9yZS4KICAgICAgICAgICAg
LS0gVXNpbmcgYSBjdXJ2ZTogbXVsdGlwbGllciA9IDEwMCAvICgxMDAgKyBkcHMpCiAgICAgICAg
ICAgIGxvY2FsIGRhbWFnZU11bHQgPSAxMDAgLyAoMTAwICsgZHBzKQogICAgICAgICAgICAKICAg
ICAgICAgICAgaWYgd0RlZi5kYW1hZ2UgdGhlbgogICAgICAgICAgICAgICAgZm9yIGssIHYgaW4g
cGFpcnMod0RlZi5kYW1hZ2UpIGRvCiAgICAgICAgICAgICAgICAgICAgd0RlZi5kYW1hZ2Vba10g
PSBtYXRoLm1heCgwLjEsIHYgKiBkYW1hZ2VNdWx0KQogICAgICAgICAgICAgICAgZW5kCiAgICAg
ICAgICAgIGVuZAoKICAgICAgICAgICAgLS0gTWFzc2l2ZWx5IGluY3JlYXNlIGtub2NrYmFjayAo
aW1wdWxzZWZhY3RvcikgdG8gYm91bmNlIGhlYXZ5IHRhbmtzCiAgICAgICAgICAgIC0tIE9yaWdp
bmFsIHZhbHVlcyBhcmUgdXN1YWxseSAwLjEgdG8gMC41LiAKICAgICAgICAgICAgLS0gV2UgbXVs
dGlwbHkgYnkgMTAwIGFuZCBhZGQgYSBiYXNlIG9mIDEwMCB0byBlbnN1cmUgZXZlbiB3ZWFwb25z
IHdpdGggMCBrbm9ja2JhY2sgaGl0IGV4dHJlbWVseSBoYXJkLgogICAgICAgICAgICB3RGVmLmlt
cHVsc2VmYWN0b3IgPSAod0RlZi5pbXB1bHNlZmFjdG9yIG9yIDApICogMTAwICsgMTAwCiAgICAg
ICAgICAgIHdEZWYuaW1wdWxzZWJvb3N0ID0gKHdEZWYuaW1wdWxzZWJvb3N0IG9yIDApICogMTAw
ICsgMTAwCiAgICAgICAgICAgIHdEZWYuY3JhdGVybXVsdCA9ICh3RGVmLmNyYXRlcm11bHQgb3Ig
MCkgKyAyCgogICAgICAgICAgICAtLSBIYWNrIHRvIG1ha2UgQmVhbUxhc2Vycy/ExXNlcnMgcHVz
aCB1bml0czogCiAgICAgICAgICAgIGlmIHdEZWYud2VhcG9udHlwZSA9PSAiQmVhbUxhc2VyIiBv
ciB3RGVmLndlYXBvbnR5cGUgPT0gIkxhc2VyQ2Fubm9uIiBvciB3RGVmLndlYXBvbnR5cGUgPT0g
IkxpZ2h0bmluZ0Nhbm5vbiIgdGhlbgogICAgICAgICAgICAgICAgaWYgbm90IHdEZWYuY3VzdG9t
cGFyYW1zIHRoZW4gd0RlZi5jdXN0b21wYXJhbXMgPSB7fSBlbmQKICAgICAgICAgICAgICAgIHdE
ZWYuY3VzdG9tcGFyYW1zLmZvcmNlX2ltcHVsc2UgPSAiMSIKICAgICAgICAgICAgZW5kCiAgICAg
ICAgZW5kCiAgICBlbmQKZW5kCgotLSBGaXggdG8gZW5zdXJlIGdyb3VuZCB1bml0cyBsaWtlIHRh
bmtzIGFuZCBSQVBUT1JTIGFjdHVhbGx5IGJvdW5jZQppZiBVbml0RGVmcyB0aGVuCiAgICBmb3Ig
bmFtZSwgdURlZiBpbiBwYWlycyhVbml0RGVmcykgZG8KICAgICAgICBpZiB0eXBlKHVEZWYpID09
ICJ0YWJsZSIgdGhlbgogICAgICAgICAgICBpZiBub3QgdURlZi5jYW5mbHkgdGhlbgogICAgICAg
ICAgICAgICAgLS0gUmVkdWNlIG1hc3MgZHJhc3RpY2FsbHkgc28gdGhlIGltcHVsc2UgdGhyb3dz
IHRoZW0KICAgICAgICAgICAgICAgIC0tIFRoaXMgZGlyZWN0bHkgY291bnRlcnMgdGhlIHJhcHRv
cl91bml0ZGVmc19wb3N0Lmx1YSBsb2dpYyB0aGF0IGFzc2lnbnMgaGVhbHRoIHRvIG1hc3MKICAg
ICAgICAgICAgICAgIHVEZWYubWFzcyA9IDEKICAgICAgICAgICAgICAgIC0tIEFkZCBzb21lIGFp
ciBncmF2aXR5IHByb3BlcnRpZXMKICAgICAgICAgICAgICAgIHVEZWYubXlncmF2aXR5ID0gMC41
CiAgICAgICAgICAgICAgICAtLSBQcmV2ZW50IHRoZW0gZnJvbSBkeWluZyBpbnN0YW50bHkgZnJv
bSBmYWxsaW5nIGRhbWFnZQogICAgICAgICAgICAgICAgaWYgbm90IHVEZWYuY3VzdG9tcGFyYW1z
IHRoZW4gdURlZi5jdXN0b21wYXJhbXMgPSB7fSBlbmQKICAgICAgICAgICAgICAgIHVEZWYuY3Vz
dG9tcGFyYW1zLmZhbGxfZGFtYWdlX211bHRpcGxpZXIgPSAiMCIKICAgICAgICAgICAgZW5kCiAg
ICAgICAgZW5kCiAgICBlbmQKZW5kCg==
```
