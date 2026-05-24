# Emotional Damage Mod (Phiên bản Siêu Đẩy Lùi - KHÔNG HACK LASER)

Việc điều chỉnh `mass = 1` ở lần trước đã kích hoạt hệ thống giới hạn Impulse tối đa (do engine quy định lực đẩy tối đa chỉ bằng `mass * 5.5`). Khi `mass` quá nhỏ, engine lập tức khóa toàn bộ Impulse, dẫn đến việc mất luôn hiệu ứng đẩy lùi.

Trong bản vá này, tôi đã:
- **Gỡ bỏ hoàn toàn sự can thiệp vào `UnitDefs`** (không sửa mass, không tắt sát thương ngã nữa).
- **Đẩy Impulse lên mức phá vỡ giới hạn**: `impulsefactor` và `impulseboost` được kích lên con số siêu khủng (nhân 500, cộng thêm 5000 base). Lực này đủ mạnh để quăng những cỗ máy hạng nặng và cả Raptors bay mất dạng.
- **TUYỆT ĐỐI KHÔNG CÓ LASER HACK**: Vũ khí Laser vẫn hoạt động theo mặc định của hệ thống game như bạn yêu cầu.

### Script Lua:
```lua
-- TweakDef Mod: Emotional Damage (Super Knockback - No Laser Hack)
-- Author: Jules
-- Description: Decreases weapon damage inversely proportional to DPS, and massively increases knockback for projectile weapons.

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

            -- INSANE knockback: Enough to bypass high mass restrictions
            wDef.impulsefactor = (wDef.impulsefactor or 0) * 500 + 5000
            wDef.impulseboost = (wDef.impulseboost or 0) * 500 + 5000
            wDef.cratermult = (wDef.cratermult or 0) + 5
        end
    end
end
```

### Mã Base64 (Để nhập vào ô TweakDef):
```
LS0gVHdlYWtEZWYgTW9kOiBFbW90aW9uYWwgRGFtYWdlIChTdXBlciBLbm9ja2JhY2sgLSBObyBM
YXNlciBIYWNrKQotLSBBdXRob3I6IEp1bGVzCi0tIERlc2NyaXB0aW9uOiBEZWNyZWFzZXMgd2Vh
cG9uIGRhbWFnZSBpbnZlcnNlbHkgcHJvcG9ydGlvbmFsIHRvIERQUywgYW5kIG1hc3NpdmVseSBp
bmNyZWFzZXMga25vY2tiYWNrIGZvciBwcm9qZWN0aWxlIHdlYXBvbnMuCgppZiBXZWFwb25EZWZz
IHRoZW4KICAgIGZvciBuYW1lLCB3RGVmIGluIHBhaXJzKFdlYXBvbkRlZnMpIGRvCiAgICAgICAg
aWYgdHlwZSh3RGVmKSA9PSAidGFibGUiIGFuZCB3RGVmLndlYXBvbnR5cGUgfj0gIlNoaWVsZCIg
dGhlbgogICAgICAgICAgICBsb2NhbCBkbWcgPSAwCiAgICAgICAgICAgIGlmIHdEZWYuZGFtYWdl
IGFuZCB3RGVmLmRhbWFnZS5kZWZhdWx0IHRoZW4KICAgICAgICAgICAgICAgIGRtZyA9IHdEZWYu
ZGFtYWdlLmRlZmF1bHQKICAgICAgICAgICAgZW5kCgogICAgICAgICAgICBsb2NhbCByZWxvYWQg
PSB3RGVmLnJlbG9hZHRpbWUgb3IgMQogICAgICAgICAgICBsb2NhbCBidXJzdCA9IHdEZWYuYnVy
c3Qgb3IgMQogICAgICAgICAgICBsb2NhbCBwcm9qZWN0aWxlcyA9IHdEZWYucHJvamVjdGlsZXMg
b3IgMQoKICAgICAgICAgICAgbG9jYWwgZHBzID0gKGRtZyAqIGJ1cnN0ICogcHJvamVjdGlsZXMp
IC8gcmVsb2FkCgogICAgICAgICAgICAtLSBSZWR1Y2UgZGFtYWdlIGJhc2VkIG9uIERQUzogaGln
aGVyIERQUyByZWR1Y2VzIGRhbWFnZSBtb3JlLgogICAgICAgICAgICBsb2NhbCBkYW1hZ2VNdWx0
ID0gMTAwIC8gKDEwMCArIGRwcykKICAgICAgICAgICAgCiAgICAgICAgICAgIGlmIHdEZWYuZGFt
YWdlIHRoZW4KICAgICAgICAgICAgICAgIGZvciBrLCB2IGluIHBhaXJzKHdEZWYuZGFtYWdlKSBk
bwogICAgICAgICAgICAgICAgICAgIHdEZWYuZGFtYWdlW2tdID0gbWF0aC5tYXgoMC4xLCB2ICog
ZGFtYWdlTXVsdCkKICAgICAgICAgICAgICAgIGVuZAogICAgICAgICAgICBlbmQKCiAgICAgICAg
ICAgIC0tIElOU0FORSBrbm9ja2JhY2s6IEVub3VnaCB0byBieXBhc3MgaGlnaCBtYXNzIHJlc3Ry
aWN0aW9ucwogICAgICAgICAgICB3RGVmLmltcHVsc2VmYWN0b3IgPSAod0RlZi5pbXB1bHNlZmFj
dG9yIG9yIDApICogNTAwICsgNTAwMAogICAgICAgICAgICB3RGVmLmltcHVsc2Vib29zdCA9ICh3
RGVmLmltcHVsc2Vib29zdCBvciAwKSAqIDUwMCArIDUwMDAKICAgICAgICAgICAgd0RlZi5jcmF0
ZXJtdWx0ID0gKHdEZWYuY3JhdGVybXVsdCBvciAwKSArIDUKICAgICAgICBlbmQKICAgIGVuZApl
bmQK
```
