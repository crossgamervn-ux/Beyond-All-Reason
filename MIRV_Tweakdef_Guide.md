# Phân tích và Hướng dẫn tạo Mod Tên lửa MIRV (Tweakdef)

Dựa trên việc phân tích mã nguồn của trò chơi (cụ thể trong file `luarules/gadgets/unit_custom_weapons_behaviours.lua`), bạn **HOÀN TOÀN CÓ THỂ** tạo một mod dạng tweakdef để làm hiệu ứng tên lửa phân tách (MIRV).

## 1. Cơ chế có sẵn trong Engine
Spring Engine / BAR đã được tích hợp sẵn một hiệu ứng vũ khí (Weapon Custom Param) tên là **`split`**.
Cơ chế hoạt động của nó như sau:
- Khi tên lửa mẹ được phóng lên và đạt đến điểm cao nhất của quỹ đạo bay (bắt đầu rơi xuống - `isProjectileFalling`).
- Trò chơi sẽ tự động **xóa tên lửa mẹ**.
- Ngay tại vị trí đó, nó sẽ tạo ra (`spSpawnProjectile`) một chùm các tên lửa con bay rải rác xuống mục tiêu.

## 2. Giải pháp cho ý tưởng của bạn
Vì cơ chế `split` mặc định sẽ xóa tên lửa mẹ, để có được hiệu ứng "5 tên lửa con bay cùng tên lửa mẹ" (tổng cộng 6 tên lửa bay tới mục tiêu), bạn sẽ thiết lập số lượng đạn con sinh ra là **6**.

Tất cả 6 tên lửa con này sẽ dùng chung một hình dáng (model) của tên lửa mẹ, nhưng bạn có thể chia nhỏ lượng sát thương của chúng ra. Vì hàm `split` chỉ nhận 1 loại `speceffect_def` (định nghĩa đạn con), nên 6 quả đạn được tách ra sẽ giống hệt nhau về chỉ số. Nếu muốn chính xác 1 quả có sát thương và 5 quả mồi nhử không có sát thương, bạn sẽ cần tạo một gadget mới viết bằng Lua thay vì dùng tweakdef đơn thuần. Nhưng nếu chỉ cần "chùm 6 quả đạn", cơ chế mặc định đã hỗ trợ hoàn hảo.

## 3. Cách viết Tweakdef (Mutator Mod)

Để làm được điều này, bạn cần thêm một đoạn code vào một mutator ở file `gamedata/alldefs_post.lua`.

Đầu tiên, bạn cần sao chép định nghĩa vũ khí nuke gốc và tạo ra một vũ khí nuke con (Child Nuke). Sau đó áp dụng thuộc tính `split` vào nuke mẹ.

**Ví dụ đoạn mã bạn có thể viết ở cuối file `gamedata/alldefs_post.lua`:**

```lua
-- Ví dụ: Giả sử vũ khí nuke tên là "crblmssl" (Nuclear Missile của Armada)

if WeaponDefs["crblmssl"] then
    -- 1. Định nghĩa Tên lửa con (Child Missile)
    local childNuke = table.copy(WeaponDefs["crblmssl"])
    childNuke.name = "mirv_child"

    -- Đảm bảo đạn con KHÔNG CÓ hiệu ứng split để tránh vòng lặp tách vô hạn
    if childNuke.customparams then
        childNuke.customparams.speceffect = nil
    end

    -- Tùy chỉnh sát thương đạn con (ví dụ: chia sát thương cho 6 quả)
    if childNuke.damage then
        for k, v in pairs(childNuke.damage) do
            childNuke.damage[k] = v / 6
        end
    end

    -- Đăng ký đạn con vào danh sách WeaponDefs
    WeaponDefs["mirv_child"] = childNuke

    -- 2. Chỉnh sửa Tên lửa mẹ (Mother ICBM) thêm hiệu ứng Split
    local motherNuke = WeaponDefs["crblmssl"]
    motherNuke.customparams = motherNuke.customparams or {}

    -- Kích hoạt hiệu ứng "split"
    motherNuke.customparams.speceffect = "split"
    -- Tên đạn con sẽ được sinh ra
    motherNuke.customparams.speceffect_def = "mirv_child"
    -- Số lượng tên lửa sinh ra (1 mẹ + 5 con = 6)
    motherNuke.customparams.number = "6"
    -- (Tùy chọn) Hiệu ứng hạt khi tách đạn
    motherNuke.customparams.splitexplosionceg = "custom:puff_smoke"
end
```

## Tổng kết
- Bạn **hoàn toàn có thể** làm được mod này chỉ bằng TweakDef (chỉnh sửa bảng `WeaponDefs`).
- Sử dụng cấu hình `customParams` với thông số `speceffect = "split"`.
- Engine đã lo toàn bộ phần vật lý phân tách đạn, bạn không cần phải viết thêm logic phức tạp nào khác.