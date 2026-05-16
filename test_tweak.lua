local script = [[
local function MakeShieldUnit(unitName)
	local ud = UnitDefs[unitName]
	if not ud then return end

	-- Remove original weapons
	ud.weapons = {
		[1] = {
			def = "REPULSOR",
			onlytargetcategory = "NOTSUB",
		}
	}

	-- Add shield weapondef
	ud.weapondefs = ud.weapondefs or {}
	ud.weapondefs.repulsor = {
		avoidfeature = false,
		craterareaofeffect = 0,
		craterboost = 0,
		cratermult = 0,
		edgeeffectiveness = 0.15,
		name = "PlasmaRepulsor",
		soundhitwet = "sizzle",
		weapontype = "Shield",
		shield = {
			alpha = 0.17,
			armortype = "shields",
			exterior = true,
			energyupkeep = 0,
			force = 2.5,
			intercepttype = 1,
			power = 6175,
			powerregen = 130,
			powerregenenergy = 562.5,
			radius = 550,
			repulser = false,
			smart = true,
			startingpower = 2090,
			visiblerepulse = true,
			badcolor = { 1, 0.2, 0.2, 0.2 },
			goodcolor = { 0.2, 1, 0.2, 0.17 },
		},
	}
end

if UnitDefs then
	MakeShieldUnit("armcroc")
	MakeShieldUnit("corsala")
	MakeShieldUnit("legfloat")
end
]]
