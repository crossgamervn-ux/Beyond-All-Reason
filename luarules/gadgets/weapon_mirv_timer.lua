local gadget = gadget ---@type Gadget

function gadget:GetInfo()
	return {
		name    = 'MIRV Timer Logic',
		desc    = 'Splits a missile towards a target after a set flight time.',
		author  = 'Custom',
		version = '1.0',
		date    = '2024-05-13',
		license = 'GNU GPL, v2 or later',
		layer   = 0,
		enabled = true
	}
end

if not gadgetHandler:IsSyncedCode() then return false end

local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileTarget = Spring.GetProjectileTarget
local spSpawnProjectile = Spring.SpawnProjectile
local spDeleteProjectile = Spring.DeleteProjectile
local spGetGroundHeight = Spring.GetGroundHeight

local targetedUnit = string.byte('u')
local targetedGround = string.byte('g')

local mirvWeapons = {}
local activeMirvs = {}

function gadget:Initialize()
	for weaponDefID, weaponDef in pairs(WeaponDefs) do
		if weaponDef.customParams and weaponDef.customParams.mirv_split_time then
			local splitTime = tonumber(weaponDef.customParams.mirv_split_time)
			local childWeaponName = weaponDef.customParams.mirv_child_def

			if splitTime and childWeaponName then
				local childWeaponID
				for cID, cDef in pairs(WeaponDefs) do
					if cDef.name == childWeaponName then
						childWeaponID = cID
						break
					end
				end
				if childWeaponID then
					mirvWeapons[weaponDefID] = {
						time = splitTime * Game.gameSpeed,
						childID = childWeaponID,
						count = tonumber(weaponDef.customParams.mirv_child_count) or 6
					}
					Script.SetWatchProjectile(weaponDefID, true)
				end
			end
		end
	end
end

function gadget:ProjectileCreated(projectileID, ownerID, weaponDefID)
	if mirvWeapons[weaponDefID] then
		local targetType, target = spGetProjectileTarget(projectileID)
		activeMirvs[projectileID] = {
			def = mirvWeapons[weaponDefID],
			frame = Spring.GetGameFrame(),
			targetType = targetType,
			target = target,
			ownerID = ownerID
		}
	end
end

function gadget:ProjectileDestroyed(projectileID)
	activeMirvs[projectileID] = nil
end

function gadget:GameFrame(frame)
	for projectileID, data in pairs(activeMirvs) do
		if frame >= data.frame + data.def.time then
			-- Time to split
			local px, py, pz = spGetProjectilePosition(projectileID)

			if px then
				local tx, ty, tz
				if data.targetType == targetedGround then
					tx, ty, tz = data.target[1], data.target[2], data.target[3]
				elseif data.targetType == targetedUnit then
					tx, ty, tz = Spring.GetUnitPosition(data.target)
				end

				if tx then
					local dx = tx - px
					local dz = tz - pz
					local dist = math.sqrt(dx*dx + dz*dz)

					-- Basic ballistic arc calculation (assumes Cannon type child)
					-- g = gravity, v = sqrt(dist * g) is for 45 degree angle optimal
					local g = math.abs(Game.gravity / (Game.gameSpeed * Game.gameSpeed)) * 100 -- approximate scaling
					local speed = math.sqrt(dist * g) * 0.8

					local dirX = dx / dist
					local dirZ = dz / dist

					spDeleteProjectile(projectileID)

					for i = 1, data.def.count do
						local randX = dirX * speed + (math.random() - 0.5) * 50
						local randZ = dirZ * speed + (math.random() - 0.5) * 50
						local randY = speed * 0.5 + (math.random() - 0.5) * 50

						spSpawnProjectile(data.def.childID, {
							pos = {px, py, pz},
							speed = {randX, randY, randZ},
							owner = data.ownerID
						})
					end
				end
			end
			activeMirvs[projectileID] = nil
		end
	end
end
