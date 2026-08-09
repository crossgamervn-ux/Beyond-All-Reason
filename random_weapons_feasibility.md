# Phân tích tính khả thi: Mod "Gun Game / Randomizer" (BAR / Spring Engine)

Ý tưởng làm chế độ **Gun Game / Randomizer** cho Beyond All Reason (BAR) là vô cùng thú vị. Bất kỳ unit nào cũng có thể bắn ra vũ khí ngẫu nhiên (từ súng lục Peewee đến Tên lửa hạt nhân), tạo nên gameplay cực kỳ hỗn loạn và khó đoán.

Dưới đây là phân tích kỹ thuật về tính khả thi, các thách thức và giải pháp cụ thể trong môi trường Spring Engine, sử dụng cơ chế `tweakdefs`.

---

## 1. Tính khả thi và Giới hạn cốt lõi của Tweakdefs

*   **Có khả thi không?** **Có**, nhưng có những giới hạn đặc thù về mặt kỹ thuật.
*   **Vấn đề UnitDef vs. Unit Instance:**
    *   `tweakdefs` hoạt động bằng cách sửa đổi bảng **`UnitDefs` toàn cục** ngay từ khi game đang nạp (loading/parsing). Nó định nghĩa các thông số *gốc* của mỗi class unit.
    *   **Hệ quả:** Bạn **không thể** làm cho mỗi con Peewee sinh ra trong trận đấu có một vũ khí khác nhau. Việc random vũ khí diễn ra ở cấp độ **Class (Loại quân)**, không phải ở cấp độ **Instance (Từng con lính riêng biệt)**.
    *   Ví dụ: Nếu Peewee được random trúng Nuke, thì **tất cả** lính Peewee của mọi người chơi trong trận đấu đó sẽ bắn Nuke. Tàu Battleship nếu bị gán súng lục thì mọi tàu Battleship sẽ bắn súng lục.

## 2. Thách thức lớn nhất: Multiplayer Desync (Mất đồng bộ)

*   **Tuyệt đối KHÔNG dùng hàm `math.random()` trong tweakdefs.**
*   **Lý do:** Các script `tweakdefs` được chạy độc lập trên máy tính của từng người chơi. Nếu dùng `math.random()`, máy người A có thể chọn Nuke cho Peewee, trong khi máy người B chọn Plasma Cannon. Điều này dẫn đến tình trạng game không thể đồng bộ và sẽ văng ngay lập tức (Desync Crash) khi bắt đầu trận.
*   **Giải pháp (Pseudo-random / Hash):**
    Phải xây dựng một thuật toán tạo số ngẫu nhiên có tính xác định (Deterministic) để đảm bảo mọi máy đều ra chung một kết quả.
    Cách phổ biến là lấy **Tên của Unit (ví dụ: `armpw`) kết hợp với một Seed tĩnh (hoặc tên map)** để băm (Hash) ra một chỉ số, sau đó dùng chỉ số đó để chọn vũ khí.

## 3. Quản lý Kho Vũ khí (Weapon Pool)

Việc gán một vũ khí bất kỳ đòi hỏi bạn phải có danh sách toàn bộ vũ khí của game.

1.  **Quét (Iterate) toàn bộ WeaponDefs:** Trong `UnitDefs`, Spring Engine lưu trữ vũ khí. Bạn cần chạy một vòng lặp để gom tất cả vũ khí vào một mảng.
2.  **Lọc Vũ khí Rác:** Rất nhiều vũ khí trong game không phải vũ khí bắn thật, bao gồm:
    *   `death_explosion` (Vụ nổ khi unit chết).
    *   `Shield` (Khiên bảo vệ).
    *   Các fake weapon dùng cho script animation.
    *   Cần loại trừ các vũ khí này để tránh lỗi.
3.  **Sắp xếp Mảng (Sort):** Do thứ tự duyệt bảng (table iteration) bằng `pairs` trong Lua là không cố định (mỗi máy có thể ra một thứ tự khác nhau), bạn bắt buộc phải **sắp xếp mảng (table.sort) theo tên Alphabet** để đảm bảo kho vũ khí trên mọi máy đều có chỉ mục (index) y hệt nhau.

## 4. Vấn đề Animations và Góc bắn (Tolerance & Firing Arcs)

*   **Vũ khí không bắn được:** Khi gắn súng lớn (ví dụ: ụ pháo tĩnh cần quay nòng, hoặc robot cần giơ tay ngắm) vào một con bọ nhỏ, con bọ đó có thể sẽ chạy loanh quanh mà không chịu bắn.
*   **Nguyên nhân:** Engine kiểm tra `tolerance` (dung sai góc ngắm). Nếu xe tank không thể nâng nòng súng đủ cao để khớp với yêu cầu của vũ khí (ví dụ tên lửa phòng không), nó sẽ không bắn. Tương tự, một số unit có `maxangledif` (góc giới hạn) hẹp.
*   **Giải pháp:**
    Khi thay vũ khí ngẫu nhiên, bạn phải đè luôn các thông số ngắm bắn trong bảng `weapons` của unit đó:
    *   Xóa `maxangledif` (hoặc set bằng 360) để unit bắn được mọi hướng.
    *   Xóa hoặc chỉnh các mục tiêu được ưu tiên (`onlytargetcategory`, `badtargetcategory`) để nó có thể bắn cả không, đất, nước mà không bị hạn chế.

---

## Tóm lược giải pháp Script

Nếu tiến hành, bạn sẽ cần một file script `.lua` chạy dưới dạng `tweakdefs` có cấu trúc:

1. Duyệt `WeaponDefs` toàn cục, lọc và lưu tên các vũ khí thật vào một mảng `ValidWeapons`.
2. Sort mảng `ValidWeapons` theo A-Z.
3. Tạo một hàm Pseudo-random đơn giản dựa vào chuỗi (String Hash).
4. Duyệt toàn bộ `UnitDefs` toàn cục (chỉ lấy các unit chiến đấu).
5. Băm tên của từng unit -> tính toán ra một chỉ số -> gán vũ khí ngẫu nhiên tương ứng từ `ValidWeapons`.
6. Cập nhật `weapondefs` và `weapons` của unit, đồng thời nới lỏng các giới hạn nhắm bắn (như góc độ).

Việc này hoàn toàn khả thi và có thể thực hiện thông qua `gamedata/alldefs_post.lua` hoặc dưới dạng một file Mod Option `tweakdefs`.