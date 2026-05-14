# Emotional Damage Mod

Dưới đây là mã mod (tweakdef) cho yêu cầu của bạn.

Cơ chế hoạt động:
1. Nó lặp qua toàn bộ `WeaponDefs`.
2. Tính toán DPS (Sát thương mỗi giây) dựa trên `damage.default`, `reloadtime`, `burst`, và `projectiles`.
3. Tính một hệ số giảm sát thương (`damageMult`) theo công thức `100 / (100 + DPS)`. Công thức này đảm bảo vũ khí DPS càng cao thì hệ số nhân càng nhỏ (sát thương giảm càng nhiều).
4. Tăng mạnh giá trị `impulsefactor` và `impulseboost` (lực đẩy/knockback) đối với tất cả các vũ khí để hiệu ứng knockback cực kỳ mạnh, kể cả với vũ khí hạt nhân hay vũ khí laser. Vũ khí không tạo knockback trước đó cũng sẽ bị ép có knockback lớn.

### Script Lua:
```lua
-- TweakDef Mod: Emotional Damage
-- Author: Jules
-- Description: Decreases weapon damage inversely proportional to DPS, and massively increases knockback for all weapons.

for name, wDef in pairs(WeaponDefs) do
    if wDef.weapontype ~= "Shield" then
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
        -- Normal impulsefactor is small (around 0.1 - 0.5).
        -- By adding a flat value and multiplying, we ensure even weapons with 0 knockback (like nukes) get it.
        wDef.impulsefactor = (wDef.impulsefactor or 0) * 5 + 5
        wDef.impulseboost = (wDef.impulseboost or 0) * 5 + 2
    end
end
```

### Mã Base64 (Để nhập vào ô TweakDef):
```
LS0gVHdlYWtEZWYgTW9kOiBFbW90aW9uYWwgRGFtYWdlCi0tIEF1dGhvcjogSnVsZXMKLS0gRGVz
Y3JpcHRpb246IERlY3JlYXNlcyB3ZWFwb24gZGFtYWdlIGludmVyc2VseSBwcm9wb3J0aW9uYWwg
dG8gRFBTLCBhbmQgbWFzc2l2ZWx5IGluY3JlYXNlcyBrbm9ja2JhY2sgZm9yIGFsbCB3ZWFwb25z
LgoKZm9yIG5hbWUsIHdEZWYgaW4gcGFpcnMoV2VhcG9uRGVmcykgZG8KICAgIGlmIHdEZWYud2Vh
cG9udHlwZSB+PSAiU2hpZWxkIiB0aGVuCiAgICAgICAgbG9jYWwgZG1nID0gMAogICAgICAgIGlm
IHdEZWYuZGFtYWdlIGFuZCB3RGVmLmRhbWFnZS5kZWZhdWx0IHRoZW4KICAgICAgICAgICAgZG1n
ID0gd0RlZi5kYW1hZ2UuZGVmYXVsdAogICAgICAgIGVuZAoKICAgICAgICBsb2NhbCByZWxvYWQg
PSB3RGVmLnJlbG9hZHRpbWUgb3IgMQogICAgICAgIGxvY2FsIGJ1cnN0ID0gd0RlZi5idXJzdCBv
ciAxCiAgICAgICAgbG9jYWwgcHJvamVjdGlsZXMgPSB3RGVmLnByb2plY3RpbGVzIG9yIDEKCiAg
ICAgICAgbG9jYWwgZHBzID0gKGRtZyAqIGJ1cnN0ICogcHJvamVjdGlsZXMpIC8gcmVsb2FkCgog
ICAgICAgIC0tIFJlZHVjZSBkYW1hZ2UgYmFzZWQgb24gRFBTOiBoaWdoZXIgRFBTIHJlZHVjZXMg
ZGFtYWdlIG1vcmUuCiAgICAgICAgLS0gVXNpbmcgYSBjdXJ2ZTogbXVsdGlwbGllciA9IDEwMCAv
ICgxMDAgKyBkcHMpCiAgICAgICAgbG9jYWwgZGFtYWdlTXVsdCA9IDEwMCAvICgxMDAgKyBkcHMp
CiAgICAgICAgCiAgICAgICAgaWYgd0RlZi5kYW1hZ2UgdGhlbgogICAgICAgICAgICBmb3Igaywg
diBpbiBwYWlycyh3RGVmLmRhbWFnZSkgZG8KICAgICAgICAgICAgICAgIHdEZWYuZGFtYWdlW2td
ID0gbWF0aC5tYXgoMC4xLCB2ICogZGFtYWdlTXVsdCkKICAgICAgICAgICAgZW5kCiAgICAgICAg
ZW5kCgogICAgICAgIC0tIFN0cm9uZ2x5IGluY3JlYXNlIGtub2NrYmFjayAoaW1wdWxzZWZhY3Rv
cikKICAgICAgICAtLSBOb3JtYWwgaW1wdWxzZWZhY3RvciBpcyBzbWFsbCAoYXJvdW5kIDAuMSAt
IDAuNSkuIAogICAgICAgIC0tIEJ5IGFkZGluZyBhIGZsYXQgdmFsdWUgYW5kIG11bHRpcGx5aW5n
LCB3ZSBlbnN1cmUgZXZlbiB3ZWFwb25zIHdpdGggMCBrbm9ja2JhY2sgKGxpa2UgbnVrZXMpIGdl
dCBpdC4KICAgICAgICB3RGVmLmltcHVsc2VmYWN0b3IgPSAod0RlZi5pbXB1bHNlZmFjdG9yIG9y
IDApICogNSArIDUKICAgICAgICB3RGVmLmltcHVsc2Vib29zdCA9ICh3RGVmLmltcHVsc2Vib29z
dCBvciAwKSAqIDUgKyAyCiAgICBlbmQKZW5kCg==
```
