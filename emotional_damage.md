# Emotional Damage Mod (Phiên bản Siêu Đẩy Lùi)

Việc điều chỉnh `mass = 1` ở lần trước đã vô tình kích hoạt hệ thống cản lực (Impulse Limiter) của game, do engine quy định sức nảy tối đa phụ thuộc vào mass. Khi mass quá nhỏ, lực đẩy cũng bị khóa lại khiến tất cả súng đều mất tác dụng đẩy lùi.

Trong bản vá này, tôi đã:
- **Gỡ bỏ hoàn toàn sự can thiệp vào `UnitDefs`** (không sửa mass xe tăng hay raptor nữa).
- **Đẩy Impulse lên mức bạo chúa**: `impulsefactor` và `impulseboost` được kích lên con số siêu khủng khiếp (nhân 500, cộng thêm 5000 base). Mức xung lực khổng lồ này đủ để xuyên thủng hệ thống giới hạn cản lực của game, đảm bảo quăng văng mọi thứ kể cả những cỗ máy hạng nặng nhất.
- **Ép Laser tạo xung lực**: Bổ sung flag giả lập va chạm để ép các vũ khí dạng Beam/Laser cũng tạo ra lực ném.

### Script Lua:
```lua
-- TweakDef Mod: Emotional Damage (Super Knockback)
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

            -- INSANE knockback: Enough to bypass high mass restrictions and engine dampening
            wDef.impulsefactor = (wDef.impulsefactor or 0) * 500 + 5000
            wDef.impulseboost = (wDef.impulseboost or 0) * 500 + 5000
            wDef.cratermult = (wDef.cratermult or 0) + 5

            -- Force hitscan weapons (lasers) to apply impulse
            if wDef.weapontype == "BeamLaser" or wDef.weapontype == "LaserCannon" or wDef.weapontype == "LightningCannon" then
                if not wDef.customparams then wDef.customparams = {} end
                wDef.customparams.force_impulse = "1"
            end
        end
    end
end
```

### Mã Base64 (Để nhập vào ô TweakDef):
```
LS0gVHdlYWtEZWYgTW9kOiBFbW90aW9uYWwgRGFtYWdlIChTdXBlciBLbm9ja2JhY2spCi0tIEF1
dGhvcjogSnVsZXMKLS0gRGVzY3JpcHRpb246IERlY3JlYXNlcyB3ZWFwb24gZGFtYWdlIGludmVy
c2VseSBwcm9wb3J0aW9uYWwgdG8gRFBTLCBhbmQgbWFzc2l2ZWx5IGluY3JlYXNlcyBrbm9ja2Jh
Y2sgZm9yIGFsbCB3ZWFwb25zIChpbmNsdWRpbmcgTGFzZXJzKS4KCmlmIFdlYXBvbkRlZnMgdGhl
bgogICAgZm9yIG5hbWUsIHdEZWYgaW4gcGFpcnMoV2VhcG9uRGVmcykgZG8KICAgICAgICBpZiB0
eXBlKHdEZWYpID09ICJ0YWJsZSIgYW5kIHdEZWYud2VhcG9udHlwZSB+PSAiU2hpZWxkIiB0aGVu
CiAgICAgICAgICAgIGxvY2FsIGRtZyA9IDAKICAgICAgICAgICAgaWYgd0RlZi5kYW1hZ2UgYW5k
IHdEZWYuZGFtYWdlLmRlZmF1bHQgdGhlbgogICAgICAgICAgICAgICAgZG1nID0gd0RlZi5kYW1h
Z2UuZGVmYXVsdAogICAgICAgICAgICBlbmQKCiAgICAgICAgICAgIGxvY2FsIHJlbG9hZCA9IHdE
ZWYucmVsb2FkdGltZSBvciAxCiAgICAgICAgICAgIGxvY2FsIGJ1cnN0ID0gd0RlZi5idXJzdCBv
ciAxCiAgICAgICAgICAgIGxvY2FsIHByb2plY3RpbGVzID0gd0RlZi5wcm9qZWN0aWxlcyBvciAx
CgogICAgICAgICAgICBsb2NhbCBkcHMgPSAoZG1nICogYnVyc3QgKiBwcm9qZWN0aWxlcykgLyBy
ZWxvYWQKCiAgICAgICAgICAgIC0tIFJlZHVjZSBkYW1hZ2UgYmFzZWQgb24gRFBTOiBoaWdoZXIg
RFBTIHJlZHVjZXMgZGFtYWdlIG1vcmUuCiAgICAgICAgICAgIGxvY2FsIGRhbWFnZU11bHQgPSAx
MDAgLyAoMTAwICsgZHBzKQogICAgICAgICAgICAKICAgICAgICAgICAgaWYgd0RlZi5kYW1hZ2Ug
dGhlbgogICAgICAgICAgICAgICAgZm9yIGssIHYgaW4gcGFpcnMod0RlZi5kYW1hZ2UpIGRvCiAg
ICAgICAgICAgICAgICAgICAgd0RlZi5kYW1hZ2Vba10gPSBtYXRoLm1heCgwLjEsIHYgKiBkYW1h
Z2VNdWx0KQogICAgICAgICAgICAgICAgZW5kCiAgICAgICAgICAgIGVuZAoKICAgICAgICAgICAg
LS0gSU5TQU5FIGtub2NrYmFjazogRW5vdWdoIHRvIGJ5cGFzcyBoaWdoIG1hc3MgcmVzdHJpY3Rp
b25zIGFuZCBlbmdpbmUgZGFtcGVuaW5nCiAgICAgICAgICAgIHdEZWYuaW1wdWxzZWZhY3RvciA9
ICh3RGVmLmltcHVsc2VmYWN0b3Igb3IgMCkgKiA1MDAgKyA1MDAwCiAgICAgICAgICAgIHdEZWYu
aW1wdWxzZWJvb3N0ID0gKHdEZWYuaW1wdWxzZWJvb3N0IG9yIDApICogNTAwICsgNTAwMAogICAg
ICAgICAgICB3RGVmLmNyYXRlcm11bHQgPSAod0RlZi5jcmF0ZXJtdWx0IG9yIDApICsgNQogICAg
ICAgICAgICAKICAgICAgICAgICAgLS0gRm9yY2UgaGl0c2NhbiB3ZWFwb25zIChsYXNlcnMpIHRv
IGFwcGx5IGltcHVsc2UKICAgICAgICAgICAgaWYgd0RlZi53ZWFwb250eXBlID09ICJCZWFtTGFz
ZXIiIG9yIHdEZWYud2VhcG9udHlwZSA9PSAiTGFzZXJDYW5ub24iIG9yIHdEZWYud2VhcG9udHlw
ZSA9PSAiTGlnaHRuaW5nQ2Fubm9uIiB0aGVuCiAgICAgICAgICAgICAgICBpZiBub3Qgd0RlZi5j
dXN0b21wYXJhbXMgdGhlbiB3RGVmLmN1c3RvbXBhcmFtcyA9IHt9IGVuZAogICAgICAgICAgICAg
ICAgd0RlZi5jdXN0b21wYXJhbXMuZm9yY2VfaW1wdWxzZSA9ICIxIgogICAgICAgICAgICBlbmQK
ICAgICAgICBlbmQKICAgIGVuZAplbmQK
```
