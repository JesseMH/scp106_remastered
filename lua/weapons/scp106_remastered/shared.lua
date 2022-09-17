AddCSLuaFile()

SWEP.Category = "SCP_106v2";
SWEP.PrintName = "scp106_remastered";
SWEP.Author = "JesseMH";
SWEP.Contact = "github.com/JesseMH";
SWEP.Purpose = "SCP 106 Abilities";
SWEP.Instructions = "RMB: Set Exit point \nReload: Lunge into walls/floors/ceilings to enter Pocket Dimension \nLMB: Exit Pocket Dimension to Exit Point";
SWEP.ViewModel = "";
SWEP.WorldModel = "";
SWEP.DrawAmmo = false;
SWEP.Rendergroup = RENDERGROUP_OTHER;
SWEP.SlotPos = 3;
SWEP.Weight = 0;
SWEP.Primary.Ammo = "none";
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = false;
SWEP.Secondary.Ammo = "none";
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.AdminSpawnable = true;
SWEP.Spawnable = true;

--[[
CUSTOM VARIABLES & TABLES
]]--
SWEP.oldCollisionGroup = ""
SWEP.laughsound = "weapons/laugh.mp3"
SWEP.corrosionsound = "weapons/corrosion.mp3"
SWEP.scp106DefaultConfig =
{
	["pd_dist"] = 640000,
	["spawn_dist"] = 90000,
	["primaryattack_delay"] = 4,
	["secondaryattack_delay"] = 0.25,
	["lunge_delay"] = 1,
	["bc_dist"] = 80,
	["bc_delay"] = 0.1,
	["flashlight_dist"] = 10000,
	["cs_delay"] = 1
}
SWEP.uncollideEnt =
{
	["func_door"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["prop_dynamic"] = true,
	["prop_static"] = true,
	["prop_door_rotating"] = true,
	["prop_vehicle_jeep"] = true,
	["func_breakable"] = true
}
--[[
	SWEP Functions
]]--
function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "BubbleCheckerIdle")
	self:NetworkVar("Float", 1, "LungeTiming")
	self:NetworkVar("Float", 2, "TeleportTiming")
	self:NetworkVar("Float", 3, "CollisionSoundDelay")
	self:NetworkVar("Vector", 0, "SCP106SavedPos")
	self:NetworkVar("Vector", 1, "SCP106PocketDimension")
	self:NetworkVar("Vector", 2, "SCP106Spawn")
end
function SWEP:Initialize()
	if not file.Exists("scp106_remastered", "DATA") then
		file.CreateDir("scp106_remastered")
	end
	if not file.Exists("scp106_remastered/scp106_config.json", "DATA") then
		file.Write("scp106_remastered/scp106_config.json", util.TableToJSON(self.scp106DefaultConfig, true))
		print("Default SCP 106 Config written")
	end
	if file.Exists("scp106_remastered/scp106_config.json", "DATA") then
		self.scp106_configTable = util.JSONToTable(file.Read("scp106_remastered/scp106_config.json", "DATA"))
		print("SCP 106 Config Loaded")
	end
	if file.Exists("scp106_remastered/scp106_spawn.txt", "DATA") then
		self:SetSCP106Spawn(util.JSONToTable(file.Read("scp106_remastered/scp106_spawn.txt", "DATA"))[game.GetMap()])
		print("SCP 106 Spawnpoint Loaded")
	end
	if file.Exists("scp106_remastered/scp106_pocketdimension.txt", "DATA") then
		self:SetSCP106PocketDimension(util.JSONToTable(file.Read("scp106_remastered/scp106_pocketdimension.txt", "DATA"))[game.GetMap()])
		print("SCP 106 Pocket Dimension Loaded")
	end
end
function SWEP:PrimaryAttack()
	if IsFirstTimePredicted() then
		self:TPtoPoint()
	end
end
function SWEP:SecondaryAttack()
	-- Saves a teleport point 
	if IsFirstTimePredicted() then
		self:SetNextSecondaryFire(CurTime() + self.scp106_configTable["secondaryattack_delay"])
		self:SetNextPrimaryFire(CurTime() + self.scp106_configTable.primaryattack_delay)
		self:CreateTeleportPoint()
	end
end
function SWEP:Reload()
	-- This function is going to teleport the player forwards a short ways. 
	self:Lunge()
end
function SWEP:Think()
	if self:GetSCP106PocketDimension() == nil or self:GetSCP106Spawn() == nil or self.scp106_configTable == nil then
		self:Initialize()
	end
	if self.scp106_configTable != nil then
		self:BubbleChecker()
	end
end

function SWEP:Deploy()
	local scp106 = self:GetOwner()
	self:SetHoldType("normal")
	scp106:SetRunSpeed(120)
	scp106:SetWalkSpeed(120)
	scp106:SetJumpPower(150)
	scp106:SetSolidFlags(4)
end
function SWEP:Holster()
end
--[[
RELOAD FUNCTIONS
]]--
function SWEP:Lunge()
	if CurTime() > self:GetLungeTiming() and self:GetPos():DistToSqr(self:GetSCP106Spawn()) > self.scp106_configTable.spawn_dist then
		self:SetLungeTiming(CurTime() + self.scp106_configTable.lunge_delay)
		local scp106 = self:GetOwner()
		scp106:SetPos(scp106:EyePos() + Vector(0, 0, -50) + scp106:GetAimVector() * math.random(50, 75))
	end
end
--[[
PRIMARY ATTACK FUNCTIONS, moves the player to the saved position set with Secondary Attack
]]--
function SWEP:TPtoPoint()
	local pos = self:GetOwner():GetPos()
	if self:GetSCP106SavedPos() == vector_origin then
		self:GetOwner():PrintMessage(HUD_PRINTTALK, "No Position Set! Use LMB to set an Exit!")
		return
	end
	if pos:DistToSqr(self:GetSCP106PocketDimension()) < self.scp106_configTable.pd_dist then -- Allows you to only use this within X distance of the pocket dimension. tpdelay is simply a 2 second cooldown that starts once SCP 106 gets to the pocket dimension. 
		self:GetOwner():SetPos(self:GetSCP106SavedPos())
		self:GetOwner():SetLocalVelocity(vector_origin)
		self:GetOwner():StopSound(self.corrosionsound)
		self:GetOwner():EmitSound(self.corrosionsound)
		self:SetSCP106SavedPos(vector_origin)
		return
	end
end
--[[
PASSIVE ABILITY FUNCTIONS, teleports anyone close to the player away to the "scp106pocketdimension" vector coord. Also handles the logic that plays a sound from entities that scp106 gets close to
]]--
function SWEP:BubbleChecker()
	if CurTime() > self:GetBubbleCheckerIdle() then
		self:SetBubbleCheckerIdle(CurTime() + self.scp106_configTable.bc_delay) -- limits checking the bubble around SCP 106 no more than ten times per second. 
		local scp106 = self:GetOwner()
		local scp106pos = scp106:GetPos()
		local mybubble = ents.FindInSphere(scp106pos, self.scp106_configTable.bc_dist) -- by default this checks within 100 units of the player
		for k, v in pairs(mybubble) do
			if v:IsPlayer() and v != scp106 then
				v:SetPos(self:GetSCP106PocketDimension())
				self:ActivateNoCollision(v, 1)
				v:TakeDamage(25)
			elseif CurTime() > self:GetCollisionSoundDelay() and self.uncollideEnt[v:GetClass()] and scp106pos:DistToSqr(v:GetPos()) < 3317.76 then
				if SERVER then
					v:StopSound(self.corrosionsound)
					v:EmitSound(self.corrosionsound)
					scp106:GetActiveWeapon():SetCollisionSoundDelay(CurTime() + self.scp106_configTable.cs_delay)
				end
			end
		end
	end
end
function SWEP:ActivateNoCollision(target, min) -- After a player is TP'd to the pocket dimension, this checks that they're not colliding with anyone else there. 
	local oldCollision = target:GetCollisionGroup() or COLLISION_GROUP_PLAYER
	local physobj = target:GetPhysicsObject()
	target:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) -- Players can walk through target
	if (min and (tonumber(min) > 0)) then
		timer.Simple(min, function() --after 'min' seconds start executing  
			timer.Create(target:GetName() .. "_checkBounds_cycle", 0.5, 0, function() -- check every half second
				local tooNearPlayer = false
				local myotherbubble = ents.FindInSphere(target:GetPos(), 80)
				for k, v in pairs(myotherbubble) do
					if v:IsPlayer() then
						tooNearPlayer = true
					end
				end
				if (not tooNearPlayer or not target:IsValid() or not physobj:IsValid() or not physobj:IsPenetrating()) then --if both false then 
					if target:IsValid() then
						target:SetCollisionGroup(oldCollision) -- Stop no-colliding by returning the original collision group (or default player collision)
					end
					timer.Remove(target:GetName() .. "_checkBounds_cycle")
				end
			end)
		end)
	end
end
--[[
SECONDARY ATTACK FUNCTIONS	
]]--
function SWEP:CreateTeleportPoint()
	local scp106 = self:GetOwner()
	self.startingpos = self:GetOwner():GetPos()
	if self.startingpos:DistToSqr(self:GetSCP106Spawn()) > self.scp106_configTable.spawn_dist and scp106:GetEyeTrace().HitPos:DistToSqr(self:GetSCP106Spawn()) > self.scp106_configTable.spawn_dist and self.startingpos:DistToSqr(self:GetSCP106PocketDimension()) > self.scp106_configTable.pd_dist and scp106:GetEyeTrace().HitPos:DistToSqr(self:GetSCP106PocketDimension()) > self.scp106_configTable.pd_dist then -- Simply prevents you from using this on/in spawn 1 and spawn 2.   
	  self:SetSCP106SavedPos(scp106:GetEyeTrace().HitPos)
	  	--if self:TPTraceHull(scp106, self:GetSCP106SavedPos(), self.startingpos) then
		local effectdata = EffectData()
		self:GetOwner():StopSound(self.laughsound)
		self:GetOwner():EmitSound(self.laughsound)
		effectdata:SetAngles(Angle(180,0,0))
		effectdata:SetStart(self:GetSCP106SavedPos())
		effectdata:SetOrigin(self:GetSCP106SavedPos())
		effectdata:SetScale(4)
		util.Effect("cball_bounce", effectdata) -- gives a visual indicator of where scp106 set their savedpos. 
		timer.Remove("InWorldCanTP")
		timer.Create("InWorldCanTP", 2, 1, function() -- the player needs to be stuck in the world entity before they will be TP'd to the point they set, and they have 2 seconds to get there. 
			if SERVER and not scp106:IsInWorld() then -- only allow the TP is scp106 is not InWorld. This is intentional. 
				scp106:SetPos(self:GetSCP106PocketDimension())
			end
		end)
	end
end
--[[ 
SERVER STUFF
 ]]--
if SERVER then
	local SCP106Spawn = {}
	local SCP106PocketDimension = {}
	concommand.Add("set_scp106_spawn", function(ply)
		if not ply:IsValid() and ply:IsSuperAdmin() then return end
		SCP106Spawn[game.GetMap()] = ply:GetPos()

		if not file.Exists("scp106_remastered", "DATA") then file.CreateDir("scp106_remastered") end
		file.Write("scp106_remastered/scp106_spawn.txt", util.TableToJSON(SCP106Spawn))
		ply:PrintMessage(HUD_PRINTCONSOLE, "SCP 106 Remastered - Spawn Point has been saved!")
	end )
	concommand.Add("set_scp106_pd", function(ply)
		if not ply:IsValid() and ply:IsSuperAdmin() then return end
		SCP106PocketDimension[game.GetMap()] = ply:GetPos()

		if not file.Exists("scp106_remastered", "DATA") then file.CreateDir("scp106_remastered") end
		file.Write("scp106_remastered/scp106_pocketdimension.txt", util.TableToJSON(SCP106PocketDimension))
		ply:PrintMessage(HUD_PRINTCONSOLE, "SCP 106 Remastered - Pocket Dimension has been saved!")
	end )
	function SCP106FlashlightDance(ply) --The TEAM_SCP106 player should be teleported back to  their "pocketdimension" coords if someone within ~100 units turns on their flashlight. Distance needs to be playtested. 
		if not team.GetPlayers(TEAM_SCP106)[1] or ply:Team() == TEAM_SCP106 or not ply:GetEyeTrace().Entity:IsPlayer() then return true end -- Ignores TEAM_SCP106 enabling their flashlight
		if ply:GetEyeTrace().Entity:Team() == TEAM_SCP106 then  --checks that the person using the flashlight is looking at a person and that person needs to be on TEAM_SCP106
			local scp106 = ply:GetEyeTrace().Entity
			local scp106weapon = scp106:GetActiveWeapon()
			if ply:GetPos():DistToSqr(scp106weapon:GetSCP106PocketDimension()) < scp106weapon.scp106_configTable.pd_dist then return end
			if ply:GetPos():DistToSqr(scp106:GetPos()) < scp106:GetActiveWeapon().scp106_configTable.flashlight_dist and scp106:GetEyeTrace().HitWorld then -- if SCP 106 is looking at the world, and if he's close enough, do the things
				scp106weapon:SetSCP106SavedPos(scp106:GetEyeTrace().HitPos) -- set the NetworkVar for saved pos so that SCP 106 can teleport back there later. 
				scp106:SetPos(scp106weapon:GetSCP106PocketDimension()) --send SCP 106 to the pocket dimension. 
			end
			return
		end
	end
--[[ 	function SCP106CheckCustomCollisions(playa) -- Checks for a player on TEAM_SCP106, if the player is on that team it will enable CustomCollisionChecks allowing the player to pass through Ent classes in local uncollideEnt
		if playa:Team() == TEAM_SCP106 then
			playa:SetCustomCollisionCheck(true)
		end
	end ]]
	hook.Add("PlayerSwitchFlashlight", "CheckFlashLight", SCP106FlashlightDance) -- check for people using their flashlights
	--[[ hook.Add("PlayerSpawn", "CheckForSCP106", SCP106CheckCustomCollisions) -- Sets to true for SCP106 when he spawns in, false for anyone spawning in as anything else ]]
end