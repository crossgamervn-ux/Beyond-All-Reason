-- Author: Jules
-- Name: AdvSAM AA Homing Nuke

if UnitDefs then
	-- Chỉnh sửa UnitDefs (Giá thành và thời gian xây dựng)
	if UnitDefs["armmercury"] then
		UnitDefs["armmercury"].buildtime = 150000
		UnitDefs["armmercury"].metalcost = 8000
		UnitDefs["armmercury"].energycost = 120000

		-- Chỉnh sửa trực tiếp weapondefs nằm trong UnitDefs
		if UnitDefs["armmercury"].weapondefs and UnitDefs["armmercury"].weapondefs["arm_advsam"] then
			local wDef = UnitDefs["armmercury"].weapondefs["arm_advsam"]
			wDef.tracks = true
			wDef.turnrate = 99000
			wDef.trajectoryheight = 0.55
			wDef.reloadtime = 20
			wDef.areaofeffect = 1500
			wDef.craterareaofeffect = 1500
			wDef.explosiongenerator = "custom:newnuke"
			wDef.soundhit = "nukearm"
			wDef.soundstart = "nukelaunch"
			wDef.customparams = wDef.customparams or {}
			wDef.customparams.nuclear = 1
			wDef.damage = wDef.damage or {}
			wDef.damage.default = 11000
			wDef.damage.vtol = 11000
			wDef.flighttime = 10
		end
	end

	if UnitDefs["corscreamer"] then
		UnitDefs["corscreamer"].buildtime = 150000
		UnitDefs["corscreamer"].metalcost = 8000
		UnitDefs["corscreamer"].energycost = 120000

		-- Chỉnh sửa trực tiếp weapondefs nằm trong UnitDefs
		if UnitDefs["corscreamer"].weapondefs and UnitDefs["corscreamer"].weapondefs["cor_advsam"] then
			local wDef = UnitDefs["corscreamer"].weapondefs["cor_advsam"]
			wDef.tracks = true
			wDef.turnrate = 99000
			wDef.trajectoryheight = 0.55
			wDef.reloadtime = 20
			wDef.areaofeffect = 1500
			wDef.craterareaofeffect = 1500
			wDef.explosiongenerator = "custom:newnuke"
			wDef.soundhit = "nukearm"
			wDef.soundstart = "nukelaunch"
			wDef.customparams = wDef.customparams or {}
			wDef.customparams.nuclear = 1
			wDef.damage = wDef.damage or {}
			wDef.damage.default = 11000
			wDef.damage.vtol = 11000
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
			WeaponDefs[wName].areaofeffect = 1500
			WeaponDefs[wName].craterareaofeffect = 1500
			WeaponDefs[wName].explosiongenerator = "custom:newnuke"
			WeaponDefs[wName].soundhit = "nukearm"
			WeaponDefs[wName].soundstart = "nukelaunch"
			WeaponDefs[wName].customparams = WeaponDefs[wName].customparams or {}
			WeaponDefs[wName].customparams.nuclear = 1
			WeaponDefs[wName].damage = WeaponDefs[wName].damage or {}
			WeaponDefs[wName].damage.default = 11000
			WeaponDefs[wName].damage.vtol = 11000
			WeaponDefs[wName].flighttime = 10
		end
	end
end
