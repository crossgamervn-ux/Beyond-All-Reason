-- Author: Jules
-- Name: ArmMercury AA Straight Nuke

if WeaponDefs and WeaponDefs["arm_advsam"] then
	WeaponDefs["arm_advsam"].tracks = false
	WeaponDefs["arm_advsam"].turnrate = 0
	WeaponDefs["arm_advsam"].trajectoryheight = 0
	WeaponDefs["arm_advsam"].areaofeffect = 1280
	WeaponDefs["arm_advsam"].craterareaofeffect = 1280
	WeaponDefs["arm_advsam"].explosiongenerator = "custom:newnuke"
	WeaponDefs["arm_advsam"].soundhit = "nukearm"
	WeaponDefs["arm_advsam"].soundstart = "nukelaunch"
	WeaponDefs["arm_advsam"].customparams = WeaponDefs["arm_advsam"].customparams or {}
	WeaponDefs["arm_advsam"].customparams.nuclear = 1
	WeaponDefs["arm_advsam"].damage = WeaponDefs["arm_advsam"].damage or {}
	WeaponDefs["arm_advsam"].damage.default = 9500
	WeaponDefs["arm_advsam"].damage.vtol = 9500
	WeaponDefs["arm_advsam"].flighttime = 10
end
