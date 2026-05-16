# Hướng dẫn biến `armmercury` và `corscreamer` thành Tháp phòng không Nuke Bám Đuổi (Homing Nuke)

Theo yêu cầu mới của bạn, chúng ta sẽ mở rộng bản mod để bao gồm cả unit **Cor Screamer (corscreamer)** - phiên bản tháp phòng không T2 của phe Core, bên cạnh `armmercury` của phe Arm. Cả hai tháp này sẽ được nâng cấp thành các tháp phòng không Nuke cực kỳ nguy hiểm.

Đạn giờ đây **có thể bám đuổi (homing)** mục tiêu thay vì bay thẳng.
Đi kèm với sức mạnh này, **bán kính nổ được tăng lên**, **thời gian nạp đạn lâu hơn**, và **giá tiền/thời gian xây dựng tháp cũng đắt đỏ hơn**.

## Các thay đổi chính (áp dụng cho cả `armmercury` và `corscreamer`)

1. **Khả năng bám đuổi:** Bật lại `tracks = true` và `turnrate = 99000`. Tên lửa sẽ ngoặt liên tục để đuổi theo máy bay.
2. **Sát thương và Bán kính nổ:** Tăng bán kính nổ (`areaofeffect`) lên `2000` (lớn hơn nuke tiêu chuẩn là 1280) và sát thương lên `15000` để đảm bảo quét sạch mọi thứ trên trời.
3. **Giới hạn tốc độ bắn:** Vì quá mạnh, thời gian nạp đạn (`reloadtime`) bị tăng lên `20` giây (thay vì 1.8 giây như cũ).
4. **Tăng giá thành xây dựng:**
   - **Metal:** 6500 (gốc: 1600~1650)
   - **Energy:** 90000 (gốc: 32000~33000)
   - **Build time:** 150000 (gốc: 28000)

## Code Mutator

Tôi đã cập nhật file `advsam_aa_nuke.lua`. Đây là script dùng để cài làm mod (tweakdef). Nội dung script như sau:

```lua
-- Author: Jules
-- Name: AdvSAM AA Homing Nuke

-- Chỉnh sửa UnitDefs (Giá thành và thời gian xây dựng)
if UnitDefs then
	if UnitDefs["armmercury"] then
		UnitDefs["armmercury"].buildtime = 150000
		UnitDefs["armmercury"].metalcost = 6500
		UnitDefs["armmercury"].energycost = 90000
	end
	if UnitDefs["corscreamer"] then
		UnitDefs["corscreamer"].buildtime = 150000
		UnitDefs["corscreamer"].metalcost = 6500
		UnitDefs["corscreamer"].energycost = 90000
	end
end

-- Chỉnh sửa WeaponDefs (Cơ chế đạn)
if WeaponDefs then
	local targetWeapons = { "arm_advsam", "cor_advsam" }

	for _, wName in ipairs(targetWeapons) do
		if WeaponDefs[wName] then
			WeaponDefs[wName].tracks = true
			WeaponDefs[wName].turnrate = 99000
			WeaponDefs[wName].trajectoryheight = 0.55

			WeaponDefs[wName].reloadtime = 20

			WeaponDefs[wName].areaofeffect = 2000
			WeaponDefs[wName].craterareaofeffect = 2000

			WeaponDefs[wName].explosiongenerator = "custom:newnuke"
			WeaponDefs[wName].soundhit = "nukearm"
			WeaponDefs[wName].soundstart = "nukelaunch"

			WeaponDefs[wName].customparams = WeaponDefs[wName].customparams or {}
			WeaponDefs[wName].customparams.nuclear = 1

			WeaponDefs[wName].damage = WeaponDefs[wName].damage or {}
			WeaponDefs[wName].damage.default = 15000
			WeaponDefs[wName].damage.vtol = 15000

			WeaponDefs[wName].flighttime = 10
		end
	end
end
```

## Cách sử dụng

* Đặt đoạn mã trên vào hệ thống tải mutator/tweakdef của bạn (thường sẽ được chạy tự động trong `gamedata/alldefs_post.lua` thông qua hàm `loadstring`, hoặc load riêng như một mod).
* Nó sẽ tự động áp dụng các thay đổi cho vũ khí và unit của cả hai tháp `armmercury` và `corscreamer` trên toàn hệ thống. Kể từ lúc đó, chúng sẽ trở thành các tháp phòng không Nuke tối thượng.