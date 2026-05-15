# Phân tích cơ chế ra đạn của `armmercury` và Hướng dẫn thay thế bằng Nuke bay thẳng

Unit `armmercury` (Long Range Anti-Air Tower) trong Spring Engine (BAR) là một tháp phòng không tầm xa. Dưới đây là phân tích về cơ chế hoạt động hiện tại của nó và cách bạn có thể biến đổi vũ khí của nó thành một quả Nuke (tên lửa hạt nhân) bắn thẳng.

## 1. Phân tích cơ chế ra đạn hiện tại của `armmercury`

Dựa trên file định nghĩa `units/ArmBuildings/LandDefenceOffence/armmercury.lua`, vũ khí của unit này có các đặc điểm sau:

* **Loại vũ khí (Weapon Type):** Sử dụng `weapontype = "MissileLauncher"`. Đây là loại vũ khí bắn tên lửa có thể tự cấp động năng sau khi rời bệ phóng.
* **Cơ chế bám mục tiêu (Tracking):** Vũ khí (có tên là `arm_advsam`) có thuộc tính `tracks = true` và tốc độ chuyển hướng rất cao `turnrate = 99000`. Điều này cho phép tên lửa ngoặt gấp để bám theo các mục tiêu không quân đang di chuyển.
* **Hạn chế mục tiêu (Targeting restrictions):**
  * Trong phần cấu hình `weapons`, nó được giới hạn chỉ bắn mục tiêu bay: `onlytargetcategory = "VTOL"`.
  * Nó cũng có thuộc tính `canattackground = false` trong `weapondefs`, ngăn chặn việc nó bắn vào các mục tiêu trên mặt đất.
* **Sát thương (Damage):** Gây sát thương chỉ định cho máy bay thông qua bảng sát thương `damage = { vtol = 750 }`.

---

## 2. Cách thay thế bằng Nuke bắn theo đường thẳng

Để `armmercury` bắn ra một quả Nuke bay theo đường thẳng (không bay lên cao rồi rớt xuống như ICBM thông thường - `StarburstLauncher`) và phát nổ thành Nuke, bạn cần điều chỉnh các thông số trong `weapondefs` và `weapons`.

Dưới đây là các bước sửa đổi cụ thể:

### A. Gỡ bỏ giới hạn phòng không
* Đổi `onlytargetcategory` trong bảng `weapons` thành `NOTSUB` (để có thể bắn các mục tiêu trên mặt đất và mặt nước).
* Chuyển `canattackground = true` để cho phép nó nhắm vào mặt đất.

### B. Làm cho đạn bay thẳng và không tự đuổi mục tiêu
* Sửa `tracks = false` và `turnrate = 0` (hoặc rất thấp) để tên lửa bay thẳng theo hướng được nhắm ban đầu, không tự động ngoặt đuổi theo mục tiêu.
* Đảm bảo `trajectoryheight = 0` để nó không bay theo đường vòng cung.
* _Mẹo:_ Bạn cũng có thể đổi `weapontype = "Cannon"` nếu muốn nó hoạt động giống như một phát đại bác đường thẳng hoàn toàn, tuy nhiên dùng `MissileLauncher` với `tracks = false` sẽ cho phép bạn sử dụng các hiệu ứng vệt khói đằng sau tên lửa (`smoketrail = true`).

### C. Gắn hiệu ứng và sát thương của Nuke
* Tăng `areaofeffect` (bán kính nổ) lên một con số lớn, ví dụ: `1280` (chuẩn của Nuke).
* Đổi cấu hình `damage` để áp dụng sát thương khủng lên mọi mục tiêu: `damage = { default = 9500 }`.
* Sử dụng `explosiongenerator = "custom:newnuke"` để tạo ra hiệu ứng đám mây hình nấm đặc trưng của Nuke khi nổ.

### D. Mã nguồn minh họa (cập nhật file `armmercury.lua`)

Bạn có thể tạo một mutator hoặc sửa trực tiếp block định nghĩa vũ khí của `armmercury` như sau:

```lua
		weapondefs = {
			arm_advsam = {
				name = "Straight-line Nuke",
				weapontype = "MissileLauncher",

				-- Chuyển thành vũ khí tấn công mặt đất
				canattackground = true,

				-- Cấu hình bay thẳng
				tracks = false,
				turnrate = 0,
				trajectoryheight = 0,
				weaponvelocity = 1000,
				startvelocity = 400,
				weaponacceleration = 100,
				flighttime = 10,

				-- Thông số Nuke
				areaofeffect = 1280,
				craterareaofeffect = 1280,
				explosiongenerator = "custom:newnuke",
				soundhit = "nukearm",
				soundstart = "nukelaunch",

				-- Tùy chọn: Để người chơi tự ra lệnh bắn giống silo nuke
				commandfire = true,
				stockpile = true,
				stockpiletime = 60,

				-- Sát thương
				damage = {
					default = 9500, -- Sát thương Nuke cho mục tiêu chung
					commanders = 2500,
				},
				customparams = {
					nuclear = 1,
				},
			},
		},
		weapons = {
			[1] = {
				def = "ARM_ADVSAM",
				-- Bắn mọi thứ (trừ tàu ngầm)
				onlytargetcategory = "NOTSUB",
			},
		},
```

### Tóm tắt
Với cấu hình này, `armmercury` sẽ hoạt động giống như một Nuke Silo bắn ngang. Nó sẽ phóng một tên lửa nổ mạnh diện rộng `custom:newnuke`, nhưng quả đạn bay thẳng đến tọa độ mục tiêu (theo kiểu `MissileLauncher` không có tracking) thay vì phóng vút lên bầu trời (như `StarburstLauncher`).