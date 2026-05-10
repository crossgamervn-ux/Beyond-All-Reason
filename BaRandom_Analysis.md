# Phân Tích Mod "BaRandom v28 by LoH"

Đoạn mã bạn cung cấp là một **Mutator Script (Kịch bản biến đổi)** được thiết kế để chạy ở giai đoạn "Pre-game" hoặc "Post-Defs" của Spring Engine. Nó sẽ viết đè và thay đổi chỉ số của toàn bộ hệ thống Unit (đơn vị quân) trong game.

Dưới đây là vị trí và danh sách các thành phần cốt lõi mà Mod này can thiệp trực tiếp vào Game Engine.

---

## 1. Đối Tượng Can Thiệp Chính: `UnitDefs`
Mod này đọc toàn bộ dữ liệu game thông qua bảng toàn cục `UnitDefs`. Trong Spring Engine, `UnitDefs` chứa định nghĩa gốc của mọi đơn vị (bot, xe tăng, máy bay, công trình). Mod dùng vòng lặp `for N, O in pairs(UnitDefs) do ... end` để "hack" và chèn chỉ số mới.

## 2. Các Hệ Thống Được Thêm Vào Bằng Code:

### A. Hệ Thống Độ Hiếm (Rarity System)
Mod tự định nghĩa danh sách các bậc xếp hạng (từ `Uncommon`, `Rare` cho đến `Godlike`, `Beyond All Reason`).
- **Mã thực thi:** Hàm quay số ngẫu nhiên `l(m)` dùng thuật toán đệ quy.
- **Can thiệp:** Thay đổi chỉ số nhân (Multiplier) đối với hầu hết các chỉ số cơ bản của Unit. Các Unit càng hiếm thì hệ số nhân sẽ càng cao.

### B. Hệ Thống "Phân Lớp Nhóm" (Classes)
Dựa vào các danh sách tĩnh `B` và `C`, nó chia các Unit thành các Lớp:
- Lính di chuyển được (Có `speed`): **Glass Cannon, Tank, Sniper, Brawler.**
- Công trình phòng thủ (Không có `speed`, không phải Builder): **Fortress, Watchtower, Suppressor.**
Mỗi lớp (Class) có một bộ hệ số nhân chỉ số ưu tiên riêng (Ví dụ: Class Tank có máu x1.22, nhưng Tốc độ quay tháp pháo chậm đi).

### C. Hệ Thống Đặc Vụ / Đột Biến (Traits / Affixes)
Nằm trong biến `k`, Mod cấp thêm những năng lực đặc biệt cho từng Class với tỉ lệ 50% `e=0.5`. Ví dụ:
- **Phantom:** Can thiệp thêm thuộc tính Tàng Hình (`cancloak=true`), cấp chỉ số tốn năng lượng tàng hình (`cloakcost`, `cloakcostmoving`) vào `UnitDef`.
- **Drunk (Say xỉn):** Can thiệp vào súng, tăng độ giật/rung lắc (Wobble `wob`, Dance `dnc`).
- **Juggernaut / Swift / Bouncer / GravWell, v.v.**

---

## 3. Các File/Thuộc Tính Của Engine Bị Thay Đổi Chi Tiết

Mod không sửa file `.lua` vật lý trên ổ cứng của bạn (như file `armstump.lua`), mà nó ghi đè trực tiếp lên RAM của game sau khi game đã load các file gốc. Dưới đây là những thuộc tính trong `UnitDefs` mà nó ghi đè (thông qua hàm `v` và `x` tự viết):

### Các thông số Vỏ ngoài / Cấu trúc (UnitDef Table)
*   **Máu (Health / MaxDamage):** `Y = O.health or O.maxdamage`.
*   **Chi Phí Xây Dựng:** `metalcost`, `energycost`, `buildtime`.
*   **Di Chuyển:** `speed` (Tốc độ), `maxacc` (Gia tốc), `maxdec` (Phanh), `turnrate` (Tốc độ xoay).
*   **Tầm Nhìn:** `sightdistance`, `radardistance`.
*   **Kinh tế:** `idleautoheal`, `energymake`, `extractsmetal`, `energyupkeep`, `tidalgenerator`, `windgenerator`.
*   **Xây dựng:** `workertime` (Tốc độ xây), `builddistance`.
*   **CustomParams (Thông số tùy chỉnh):** Thay đổi công suất chuyển đổi năng lượng (`energyconv_efficiency`), sức mạnh Khiên bảo vệ (`shield_power`, `shield_radius`). Gán cờ `Z.rarity` và `Z.cursed`.

### Các thông số Súng Ống (WeaponDefs Table)
Mod đi sâu vào `O.weapondefs` (bảng định nghĩa súng của từng Unit) và thay đổi:
*   **Tầm Bắn:** `range`, `overrange_distance`, `engagementrange`.
*   **Tốc độ xả đạn:** `reloadtime` (Thời gian nạp), `burstrate` (Tốc độ xả Burst).
*   **Đạn đạo:** `weaponvelocity` (Tốc độ đạn bay), `startvelocity`, `weaponacceleration`.
*   **Độ chính xác:** `sprayangle`, `accuracy` (Độ tản mát đạn).
*   **Sát thương diện rộng:** `areaofeffect`.
*   **Đồ họa đạn:** `laserflaresize`, `size`, `thickness`.

### Các thông số Sát Thương (Damage Table)
Mod móc vào `a0.damage` (Bảng sát thương của súng) và thay đổi tất cả các loại sát thương (sát thương mặc định, sát thương lên không quân, lên chỉ huy).

---

## 4. Hệ Thống Đổi Tên Hiển Thị (Rename System)
*   Ở cuối mã, Mod sử dụng lệnh `Spring.Echo` để báo cho Giao diện người dùng (LuaUI Widget) biết rằng cấu hình đã xong.
*   Nó gửi các đoạn Log có dạng: `/([Legendary Swift Tank]/-Mk.6   /-)`
*   Mục đích: Viết một bộ parser cho giao diện trong game để hiển thị tên mới cho unit (Ví dụ: `[Legendary Swift Tank] T-100` thay vì tên gốc).

---

## TỔNG KẾT

1. **Vị Trí Sửa:** Nếu bạn muốn đưa đoạn code này vào làm Mod chính thức trong repo, nó phải được để ở trong **`gamedata/alldefs_post.lua`** (Hoặc tạo file rời rồi require() từ file này). Engine chỉ cho phép sửa bảng `UnitDefs` ở giai đoạn này.
2. **Quy Mô:** Nó thay đổi **gần như 95%** toàn bộ các thông số liên quan đến chiến đấu của mọi chiếc xe, lính, máy bay và công trình trong game.
3. **Cách Thức:** Bằng cách tung xúc xắc đệ quy (random) lúc khởi động trận, khiến cho mỗi trận đấu, các Unit lại mang một sức mạnh, chi phí và độ hiếm hoàn toàn ngẫu nhiên.
