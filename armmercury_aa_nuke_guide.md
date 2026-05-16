# Hướng dẫn biến `armmercury` thành Tháp phòng không Nuke Bám Đuổi (Homing Nuke)

Theo yêu cầu mới của bạn, chúng ta sẽ nâng cấp `armmercury` thành một tháp phòng không Nuke cực kỳ nguy hiểm. Nó không chỉ bắn nuke vào các mục tiêu trên không (VTOL) mà đạn giờ đây **có thể bám đuổi (homing)** mục tiêu.

Đi kèm với sức mạnh này, **bán kính nổ được tăng lên**, **thời gian nạp đạn lâu hơn**, và **giá tiền/thời gian xây dựng tháp cũng đắt đỏ hơn**.

## Các thay đổi chính

1. **Khả năng bám đuổi:** Bật lại `tracks = true` và `turnrate = 99000`. Tên lửa sẽ ngoặt liên tục để đuổi theo máy bay.
2. **Sát thương và Bán kính nổ:** Tăng bán kính nổ (`areaofeffect`) lên `2000` (lớn hơn nuke tiêu chuẩn là 1280) và sát thương lên `15000` để đảm bảo quét sạch mọi thứ trên trời.
3. **Giới hạn tốc độ bắn:** Vì quá mạnh, thời gian nạp đạn (`reloadtime`) bị tăng lên `20` giây (thay vì 1.8 giây như cũ).
4. **Tăng giá thành xây dựng:**
   - **Metal:** 6500 (gốc: 1600)
   - **Energy:** 90000 (gốc: 33000)
   - **Build time:** 150000 (gốc: 28000)

## Code Mutator

Tôi đã cập nhật file `armmercury_aa_nuke.lua`. Đây là script dùng để cài làm mod (tweakdef). Nội dung script như sau:

```lua
-- Author: Jules
-- Name: ArmMercury AA Homing Nuke

-- Chỉnh sửa UnitDefs (Giá thành và thời gian xây dựng)
if UnitDefs and UnitDefs["armmercury"] then
	UnitDefs["armmercury"].buildtime = 150000 -- Tăng mạnh thời gian xây (gốc: 28000)
	UnitDefs["armmercury"].metalcost = 6500  -- Tăng kim loại (gốc: 1600)
	UnitDefs["armmercury"].energycost = 90000 -- Tăng năng lượng (gốc: 33000)
end

-- Chỉnh sửa WeaponDefs (Cơ chế đạn)
if WeaponDefs and WeaponDefs["arm_advsam"] then
	-- Bật lại khả năng bám đuổi (Homing)
	WeaponDefs["arm_advsam"].tracks = true
	WeaponDefs["arm_advsam"].turnrate = 99000
	WeaponDefs["arm_advsam"].trajectoryheight = 0.55

	-- Tăng thời gian nạp đạn (Reload time)
	WeaponDefs["arm_advsam"].reloadtime = 20 -- Bắn chậm hơn nhiều (gốc: 1.8)

	-- Tăng bán kính nổ Nuke khổng lồ
	WeaponDefs["arm_advsam"].areaofeffect = 2000 -- Rất lớn (chuẩn nuke thường là 1280)
	WeaponDefs["arm_advsam"].craterareaofeffect = 2000

	WeaponDefs["arm_advsam"].explosiongenerator = "custom:newnuke"
	WeaponDefs["arm_advsam"].soundhit = "nukearm"
	WeaponDefs["arm_advsam"].soundstart = "nukelaunch"

	-- Cấu hình sát thương và các tham số khác
	WeaponDefs["arm_advsam"].customparams = WeaponDefs["arm_advsam"].customparams or {}
	WeaponDefs["arm_advsam"].customparams.nuclear = 1

	WeaponDefs["arm_advsam"].damage = WeaponDefs["arm_advsam"].damage or {}
	WeaponDefs["arm_advsam"].damage.default = 15000
	WeaponDefs["arm_advsam"].damage.vtol = 15000

	WeaponDefs["arm_advsam"].flighttime = 10
end
```

## Cách sử dụng

* Đặt đoạn mã trên vào hệ thống tải mutator/tweakdef của bạn (thường sẽ được chạy tự động trong `gamedata/alldefs_post.lua` thông qua hàm `loadstring`, hoặc load riêng như một mod).
* Nó sẽ ghi đè các thông số của tháp `armmercury` và vũ khí `arm_advsam` của nó trên toàn hệ thống. Kể từ lúc đó, nó sẽ là một tháp nuke phòng không bám đuổi đắt tiền và chết chóc.