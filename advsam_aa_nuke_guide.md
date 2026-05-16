# Hướng dẫn biến `armmercury` và `corscreamer` thành Tháp phòng không Nuke Bám Đuổi (Homing Nuke)

Theo yêu cầu mới của bạn, chúng ta sẽ mở rộng bản mod để bao gồm cả unit **Cor Screamer (corscreamer)** - phiên bản tháp phòng không T2 của phe Core, bên cạnh `armmercury` của phe Arm. Cả hai tháp này sẽ được nâng cấp thành các tháp phòng không Nuke cực kỳ nguy hiểm.

Đạn giờ đây **có thể bám đuổi (homing)** mục tiêu thay vì bay thẳng.
Đi kèm với sức mạnh này, **bán kính nổ được tăng lên**, **thời gian nạp đạn lâu hơn**, và **giá tiền/thời gian xây dựng tháp cũng đắt đỏ hơn**.

## Các thay đổi chính (áp dụng cho cả `armmercury` và `corscreamer`)

1. **Khả năng bám đuổi:** Bật lại `tracks = true` và `turnrate = 99000`. Tên lửa sẽ ngoặt liên tục để đuổi theo máy bay.
2. **Sát thương và Bán kính nổ:** Dù đã bị giảm nhẹ để cân bằng, bán kính nổ (`areaofeffect`) vẫn ở mức `1400` (lớn hơn nuke tiêu chuẩn là 1280) và sát thương là `10000`, quá đủ để hủy diệt các phi đội lớn.
3. **Giới hạn tốc độ bắn:** Vì quá mạnh, thời gian nạp đạn (`reloadtime`) bị tăng lên `20` giây (thay vì 1.8 giây như cũ).
4. **Tăng giá thành xây dựng:**
   - **Metal:** 7000 (gốc: 1600~1650)
   - **Energy:** 100000 (gốc: 32000~33000)
   - **Build time:** 150000 (gốc: 28000)

## Code Mutator

Tôi đã cập nhật file `advsam_aa_nuke.lua`. Đây là script dùng để cài làm mod (tweakdef). Nội dung script như sau:

```lua
-- Author: Jules
-- Name: AdvSAM AA Homing Nuke

if UnitDefs then
	-- Chỉnh sửa UnitDefs (Giá thành và thời gian xây dựng)
	if UnitDefs["armmercury"] then
		UnitDefs["armmercury"].buildtime = 150000
		UnitDefs["armmercury"].metalcost = 7000
		UnitDefs["armmercury"].energycost = 100000

		-- Chỉnh sửa trực tiếp weapondefs nằm trong UnitDefs
		if UnitDefs["armmercury"].weapondefs and UnitDefs["armmercury"].weapondefs["arm_advsam"] then
			local wDef = UnitDefs["armmercury"].weapondefs["arm_advsam"]
			wDef.tracks = true
			wDef.turnrate = 99000
			wDef.trajectoryheight = 0.55
			wDef.reloadtime = 20
			wDef.areaofeffect = 1400
			wDef.craterareaofeffect = 1400
			wDef.explosiongenerator = "custom:newnuke"
			wDef.soundhit = "nukearm"
			wDef.soundstart = "nukelaunch"
			wDef.customparams = wDef.customparams or {}
			wDef.customparams.nuclear = 1
			wDef.damage = wDef.damage or {}
			wDef.damage.default = 10000
			wDef.damage.vtol = 10000
			wDef.flighttime = 10
		end
	end

	if UnitDefs["corscreamer"] then
		UnitDefs["corscreamer"].buildtime = 150000
		UnitDefs["corscreamer"].metalcost = 7000
		UnitDefs["corscreamer"].energycost = 100000

		-- Chỉnh sửa trực tiếp weapondefs nằm trong UnitDefs
		if UnitDefs["corscreamer"].weapondefs and UnitDefs["corscreamer"].weapondefs["cor_advsam"] then
			local wDef = UnitDefs["corscreamer"].weapondefs["cor_advsam"]
			wDef.tracks = true
			wDef.turnrate = 99000
			wDef.trajectoryheight = 0.55
			wDef.reloadtime = 20
			wDef.areaofeffect = 1400
			wDef.craterareaofeffect = 1400
			wDef.explosiongenerator = "custom:newnuke"
			wDef.soundhit = "nukearm"
			wDef.soundstart = "nukelaunch"
			wDef.customparams = wDef.customparams or {}
			wDef.customparams.nuclear = 1
			wDef.damage = wDef.damage or {}
			wDef.damage.default = 10000
			wDef.damage.vtol = 10000
			wDef.flighttime = 10
		end
	end
end

-- Chỉnh sửa WeaponDefs (Cơ chế đạn) cho an toàn nếu engine tách rời sớm
if WeaponDefs then
	local targetWeapons = { "armmercury_arm_advsam", "corscreamer_cor_advsam", "arm_advsam", "cor_advsam" }

	for _, wName in ipairs(targetWeapons) do
		if WeaponDefs[wName] then
			WeaponDefs[wName].tracks = true
			WeaponDefs[wName].turnrate = 99000
			WeaponDefs[wName].trajectoryheight = 0.55
			WeaponDefs[wName].reloadtime = 20
			WeaponDefs[wName].areaofeffect = 1400
			WeaponDefs[wName].craterareaofeffect = 1400
			WeaponDefs[wName].explosiongenerator = "custom:newnuke"
			WeaponDefs[wName].soundhit = "nukearm"
			WeaponDefs[wName].soundstart = "nukelaunch"
			WeaponDefs[wName].customparams = WeaponDefs[wName].customparams or {}
			WeaponDefs[wName].customparams.nuclear = 1
			WeaponDefs[wName].damage = WeaponDefs[wName].damage or {}
			WeaponDefs[wName].damage.default = 10000
			WeaponDefs[wName].damage.vtol = 10000
			WeaponDefs[wName].flighttime = 10
		end
	end
end
```

## Cách sử dụng

* Đặt đoạn mã trên vào hệ thống tải mutator/tweakdef của bạn (thường sẽ được chạy tự động trong `gamedata/alldefs_post.lua` thông qua hàm `loadstring`, hoặc load riêng như một mod).
* Nó sẽ tự động áp dụng các thay đổi cho vũ khí và unit của cả hai tháp `armmercury` và `corscreamer` trên toàn hệ thống. Kể từ lúc đó, chúng sẽ trở thành các tháp phòng không Nuke tối thượng.