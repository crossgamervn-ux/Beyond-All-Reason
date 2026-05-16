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
-- Trong Spring/BAR, tên weapondefs thường được tiền tố bằng tên unit
-- (ví dụ: armmercury_arm_advsam) do quá trình xử lý của gamedata/weapondefs_post.lua
if WeaponDefs then
	local targetWeapons = { "armmercury_arm_advsam", "corscreamer_cor_advsam" }

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
