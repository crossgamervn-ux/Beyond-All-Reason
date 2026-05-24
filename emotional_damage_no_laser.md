# Emotional Damage Mod (Phiên bản giảm Mass, tăng siêu Knockback, chưa có phần hack Laser)

Đây là phiên bản bạn yêu cầu, trước khi tôi đưa vào các xử lý ép force cho Laser.
Bản này giữ nguyên các tính năng:
- **Giảm sát thương theo DPS**.
- Tăng `impulsefactor` và `impulseboost` lên mức siêu cao (x100 + 100) để knockback cực mạnh.
- Giảm `mass = 1` cho tất cả các đơn vị mặt đất (**bao gồm cả Xe Tăng và RAPTOR** vốn bị engine tự gán mass bằng đúng lượng máu) để vượt qua rào cản cản lực văng của Engine.
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
aWYgV2VhcG9uRGVmcyB0aGVuCiAgICBmb3IgbmFtZSwgd0RlZiBpbiBwYWlycyhXZWFwb25EZWZz
KSBkbwogICAgICAgIGlmIHR5cGUod0RlZikgPT0gInRhYmxlIiBhbmQgd0RlZi53ZWFwb250eXBl
IH49ICJTaGllbGQiIHRoZW4KICAgICAgICAgICAgbG9jYWwgZG1nID0gMAogICAgICAgICAgICBp
ZiB3RGVmLmRhbWFnZSBhbmQgd0RlZi5kYW1hZ2UuZGVmYXVsdCB0aGVuCiAgICAgICAgICAgICAg
ICBkbWcgPSB3RGVmLmRhbWFnZS5kZWZhdWx0CiAgICAgICAgICAgIGVuZAoKICAgICAgICAgICAg
bG9jYWwgcmVsb2FkID0gd0RlZi5yZWxvYWR0aW1lIG9yIDEKICAgICAgICAgICAgbG9jYWwgYnVy
c3QgPSB3RGVmLmJ1cnN0IG9yIDEKICAgICAgICAgICAgbG9jYWwgcHJvamVjdGlsZXMgPSB3RGVm
LnByb2plY3RpbGVzIG9yIDEKCiAgICAgICAgICAgIGxvY2FsIGRwcyA9IChkbWcgKiBidXJzdCAq
IHByb2plY3RpbGVzKSAvIHJlbG9hZAoKICAgICAgICAgICAgbG9jYWwgZGFtYWdlTXVsdCA9IDEw
MCAvICgxMDAgKyBkcHMpCiAgICAgICAgICAgIAogICAgICAgICAgICBpZiB3RGVmLmRhbWFnZSB0
aGVuCiAgICAgICAgICAgICAgICBmb3IgaywgdiBpbiBwYWlycyh3RGVmLmRhbWFnZSkgZG8KICAg
ICAgICAgICAgICAgICAgICB3RGVmLmRhbWFnZVtrXSA9IG1hdGgubWF4KDAuMSwgdiAqIGRhbWFn
ZU11bHQpCiAgICAgICAgICAgICAgICBlbmQKICAgICAgICAgICAgZW5kCgogICAgICAgICAgICB3
RGVmLmltcHVsc2VmYWN0b3IgPSAod0RlZi5pbXB1bHNlZmFjdG9yIG9yIDApICogMTAwICsgMTAw
CiAgICAgICAgICAgIHdEZWYuaW1wdWxzZWJvb3N0ID0gKHdEZWYuaW1wdWxzZWJvb3N0IG9yIDAp
ICogMTAwICsgMTAwCiAgICAgICAgICAgIHdEZWYuY3JhdGVybXVsdCA9ICh3RGVmLmNyYXRlcm11
bHQgb3IgMCkgKyAyCiAgICAgICAgZW5kCiAgICBlbmQKZW5kCgppZiBVbml0RGVmcyB0aGVuCiAg
ICBmb3IgbmFtZSwgdURlZiBpbiBwYWlycyhVbml0RGVmcykgZG8KICAgICAgICBpZiB0eXBlKHVE
ZWYpID09ICJ0YWJsZSIgdGhlbgogICAgICAgICAgICBpZiBub3QgdURlZi5jYW5mbHkgdGhlbgog
ICAgICAgICAgICAgICAgdURlZi5tYXNzID0gMQogICAgICAgICAgICAgICAgdURlZi5teWdyYXZp
dHkgPSAwLjUKICAgICAgICAgICAgICAgIGlmIG5vdCB1RGVmLmN1c3RvbXBhcmFtcyB0aGVuIHVE
ZWYuY3VzdG9tcGFyYW1zID0ge30gZW5kCiAgICAgICAgICAgICAgICB1RGVmLmN1c3RvbXBhcmFt
cy5mYWxsX2RhbWFnZV9tdWx0aXBsaWVyID0gIjAiCiAgICAgICAgICAgIGVuZAogICAgICAgIGVu
ZAogICAgZW5kCmVuZAo=
```
