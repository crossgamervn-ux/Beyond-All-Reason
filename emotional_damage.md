# Emotional Damage Mod

Dưới đây là mã mod (tweakdef) cho yêu cầu của bạn, **đã loại bỏ hoàn toàn phần code random ngẫu nhiên đổi unit** và tập trung vào Emotional Damage, đồng thời **đã sửa lỗi crash `table expected, got nil`**.

Cơ chế hoạt động:
1. Nó lặp qua toàn bộ `WeaponDefs`. Đã thêm `if WeaponDefs then` và `type(wDef) == "table"` để chống lỗi crash game khi hệ thống trả về bảng rỗng hoặc nil.
2. Tính toán DPS (Sát thương mỗi giây) dựa trên `damage.default`, `reloadtime`, `burst`, và `projectiles`.
3. Tính một hệ số giảm sát thương (`damageMult`) theo công thức `100 / (100 + DPS)`. Công thức này đảm bảo vũ khí DPS càng cao thì hệ số nhân càng nhỏ (sát thương giảm càng nhiều).
4. Tăng mạnh giá trị `impulsefactor` và `impulseboost` (lực đẩy/knockback) đối với tất cả các vũ khí để hiệu ứng knockback cực kỳ mạnh, kể cả với vũ khí hạt nhân hay vũ khí laser.

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

            -- Strongly increase knockback (impulsefactor)
            wDef.impulsefactor = (wDef.impulsefactor or 0) * 5 + 5
            wDef.impulseboost = (wDef.impulseboost or 0) * 5 + 2
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
ICAgICAgIGVuZAoKICAgICAgICAgICAgLS0gU3Ryb25nbHkgaW5jcmVhc2Uga25vY2tiYWNrIChp
bXB1bHNlZmFjdG9yKQogICAgICAgICAgICB3RGVmLmltcHVsc2VmYWN0b3IgPSAod0RlZi5pbXB1
bHNlZmFjdG9yIG9yIDApICogNSArIDUKICAgICAgICAgICAgd0RlZi5pbXB1bHNlYm9vc3QgPSAo
d0RlZi5pbXB1bHNlYm9vc3Qgb3IgMCkgKiA1ICsgMgogICAgICAgIGVuZAogICAgZW5kCmVuZAo=
```
