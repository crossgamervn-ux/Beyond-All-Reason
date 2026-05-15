# Emotional Damage Mod (Phiên bản giảm Mass, tăng siêu Knockback, chưa có phần hack Laser)

Đây là phiên bản bạn yêu cầu, trước khi tôi đưa vào các xử lý ép force cho Laser.
Bản này giữ nguyên các tính năng:
- **Giảm sát thương theo DPS**.
- Tăng `impulsefactor` và `impulseboost` lên x100 để knockback cực mạnh.
- Giảm `mass = 1` cho tất cả các đơn vị mặt đất để vượt qua rào cản cản lực văng của Engine.
- Tắt tính năng nhận sát thương khi rớt từ trên cao xuống (`fall_damage_multiplier = "0"`).

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

            local damageMult = 100 / (100 + dps)

            if wDef.damage then
                for k, v in pairs(wDef.damage) do
                    wDef.damage[k] = math.max(0.1, v * damageMult)
                end
            end

            wDef.impulsefactor = (wDef.impulsefactor or 0) * 100 + 50
            wDef.impulseboost = (wDef.impulseboost or 0) * 100 + 50
            wDef.cratermult = (wDef.cratermult or 0) + 2
        end
    end
end

if UnitDefs then
    for name, uDef in pairs(UnitDefs) do
        if type(uDef) == "table" then
            if not uDef.canfly then
                uDef.mass = 1
                uDef.mygravity = 0.5
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
dCAqIHByb2plY3RpbGVzKSAvIHJlbG9hZAoKICAgICAgICAgICAgbG9jYWwgZGFtYWdlTXVsdCA9
IDEwMCAvICgxMDAgKyBkcHMpCiAgICAgICAgICAgIAogICAgICAgICAgICBpZiB3RGVmLmRhbWFn
ZSB0aGVuCiAgICAgICAgICAgICAgICBmb3IgaywgdiBpbiBwYWlycyh3RGVmLmRhbWFnZSkgZG8K
ICAgICAgICAgICAgICAgICAgICB3RGVmLmRhbWFnZVtrXSA9IG1hdGgubWF4KDAuMSwgdiAqIGRh
bWFnZU11bHQpCiAgICAgICAgICAgICAgICBlbmQKICAgICAgICAgICAgZW5kCgogICAgICAgICAg
ICB3RGVmLmltcHVsc2VmYWN0b3IgPSAod0RlZi5pbXB1bHNlZmFjdG9yIG9yIDApICogMTAwICsg
NTAKICAgICAgICAgICAgd0RlZi5pbXB1bHNlYm9vc3QgPSAod0RlZi5pbXB1bHNlYm9vc3Qgb3Ig
MCkgKiAxMDAgKyA1MAogICAgICAgICAgICB3RGVmLmNyYXRlcm11bHQgPSAod0RlZi5jcmF0ZXJt
dWx0IG9yIDApICsgMgogICAgICAgIGVuZAogICAgZW5kCmVuZAoKaWYgVW5pdERlZnMgdGhlbgog
ICAgZm9yIG5hbWUsIHVEZWYgaW4gcGFpcnMoVW5pdERlZnMpIGRvCiAgICAgICAgaWYgdHlwZSh1
RGVmKSA9PSAidGFibGUiIHRoZW4KICAgICAgICAgICAgaWYgbm90IHVEZWYuY2FuZmx5IHRoZW4K
ICAgICAgICAgICAgICAgIHVEZWYubWFzcyA9IDEKICAgICAgICAgICAgICAgIHVEZWYubXlncmF2
aXR5ID0gMC41CiAgICAgICAgICAgICAgICBpZiBub3QgdURlZi5jdXN0b21wYXJhbXMgdGhlbiB1
RGVmLmN1c3RvbXBhcmFtcyA9IHt9IGVuZAogICAgICAgICAgICAgICAgdURlZi5jdXN0b21wYXJh
bXMuZmFsbF9kYW1hZ2VfbXVsdGlwbGllciA9ICIwIgogICAgICAgICAgICBlbmQKICAgICAgICBl
bmQKICAgIGVuZAplbmQK
```
