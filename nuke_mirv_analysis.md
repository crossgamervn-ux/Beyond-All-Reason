# Phân tích việc tạo Nuke theo dạng MIRV (Tên lửa phân hướng)

Chào bạn, dựa vào source code của BAR, việc tạo một tên lửa nuke có khả năng bay nửa đường rồi tách thành nhiều quả đạn nhỏ xung quanh (MIRV - Multiple Independently targetable Reentry Vehicle) là **HOÀN TOÀN KHẢ THI**.

Trong Spring Engine (và được tích hợp sẵn trong bộ mã nguồn của BAR), có một gadget tên là `unit_custom_weapons_cluster.lua`. Gadget này chuyên xử lý các vũ khí nổ chùm (Cluster weapons) bằng cách dựa vào các thẻ `customparams` mà bạn gắn vào trong khối định nghĩa vũ khí (WeaponDefs).

## Cách hoạt động của Cluster Weapon trong BAR:
Để một vũ khí nổ chùm và tách ra thành các đầu đạn nhỏ, bạn cần làm 2 việc trong `UnitDefs`:
1. Định nghĩa một vũ khí là đạn nhỏ (Submunition / Cluster).
2. Thêm `customparams` vào vũ khí chính (ở đây là Nuke/ICBM) báo cho hệ thống biết nó sẽ tách ra đạn nào, và tách thành bao nhiêu quả.

Ví dụ, nếu chúng ta thêm vào file vũ khí của ICBM đoạn code như sau:
```lua
wDef.customparams = wDef.customparams or {}
wDef.customparams.cluster_def = "tên_vũ_khí_đạn_nhỏ" -- Tên đạn con
wDef.customparams.cluster_number = 6                 -- Tách thành 6 quả
wDef.customparams.cluster_timer = 200                -- Thời gian (frames) trước khi tách (nửa đường bay)
```

## Giải pháp triển khai cụ thể
Để làm MIRV cho Nuke mà không sửa mã gốc của game, bạn có thể bổ sung đoạn mã sau vào Mutator của bạn (chạy chung với Script Antinuke lúc nãy):

1. **Tạo vũ khí đạn con (MIRV Warhead):** Bằng cách sao chép thuộc tính của nuke hiện tại nhưng làm kích thước (AoE, Damage) nhỏ hơn 1 chút.
2. **Kích hoạt tính năng Cluster cho Nuke Mẹ:** Thêm `cluster_def` và `cluster_number` vào `customparams` của vũ khí Nuke, đồng thời gắn một biến đếm thời gian phân tách sao cho nó nổ giữa không trung (ví dụ: khi rớt xuống độ cao nhất định, hoặc dựa theo `flighttime`).

Khi Nuke mẹ bay lên cao rồi bắt đầu chu kỳ rơi xuống, gadget `unit_custom_weapons_cluster.lua` sẽ bắt được tín hiệu và tự động xóa bỏ nuke mẹ, sinh ra 6 tia lửa nuke con bay tỏa ra các hướng xung quanh mục tiêu chính.

*Lưu ý: Mặc dù hoàn toàn có thể làm được bằng file lua ngoài, tính năng này đòi hỏi phải tạo ra một WeaponDef "ảo" mới tinh chuyên dùng làm đạn con, và cần thiết lập cẩn thận góc tỏa (scatter/sprayangle) để 6 quả đạn rơi đều xung quanh chứ không rơi chụm vào 1 điểm.*
