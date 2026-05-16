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
