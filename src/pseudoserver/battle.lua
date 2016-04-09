local Time = require "src.pseudoserver.time"
local NetCmd = require "src.net.NetCmd"
local Sche = require "src.pseudoserver.sche"
local Avatar = require "src.pseudoserver.avatar"
local BattleTeam = require "src.pseudoserver.battleteam"
local Map = require "src.pseudoserver.map"

local battle = {}

--local skill_useable = 1
--local skill_disable = 2
--local skill_pending = 3

local attack_team = 1
local defend_team = 2

function battle:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self

	o.m = Map.New(o,22)
	o.counter = 1
	o.avatars={}
	o.round = 1
	o.central = 5
	o.start = false
	o.attackteam = BattleTeam.New(o,attack_team)
	o.defendteam = BattleTeam.New(o,defend_team)
	return o
end

function battle:notifySkillState()
	--notify skill state change
	if self.skill_state then
		--print("NotifySkillState")
    	local wpk = CPacket.NewWPacket()
   		wpk:Write_uint16(NetCmd.CMD_SC_SKILL_STATE)
   		wpk:Write_table(self.skill_state)    		
		Send2Client(wpk)
		self.skill_state = nil
	end
end

function battle:ProcessTick()
	if self.start and self.ready then
		local now = Time.SysTick()
		for k,v in pairs(self.avatars) do
			v:process(now)
		end	
		self:notifySkillState()
		if self.winteam then
			return
		end			
		local winteam = 0
		if #self.team[1] == 0 then
			winteam = 2
		elseif #self.team[2] == 0 then
			winteam = 1
		end
		if winteam > 0 then
			self.winteam = winteam		
			Sche.Spawn(function ()
				Sche.Sleep(2000)
		    	local wpk = CPacket.NewWPacket()
		    	wpk:Write_uint16(NetCmd.CMD_SC_BATTLE_RETSULT)			
				wpk:Write_uint8(winteam)
				Send2Client(wpk)
				self.start = false					
			end)			
		end
	end
end

function battle:NewUid()
	local uid = self.counter
	self.counter = self.counter+1
	return uid
end

function battle:StartBattle(mapid)
	if not self.start then
		--battle = {m = map:new(22),avatars={},round = 1,central = 5}
		local offset = {50,150,250}
		local baseY = {160,180,170}
		battle.map_central = 1000--2688.0/2
		self.start = true
		local avatids = {1002,1001,1003}
		self.team = {{},{}}
		for j = 1,#avatids do
			local i = avatids[j]
			local avat = Avatar.New(self,i,1200)
			self.attackteam:AddMember(avat)
			avat.team = self.attackteam
			avat.enemyteam = self.defendteam
			--avat.atkdis = TableAvatar[i].Line
			avat.beginpos = battle.map_central - (offset[j] + math.random(10,50))
			avat.baseY = baseY[j]

			--self.m:enterMap(avat,self.central-TableAvatar[i].Line)
			avat.teamid = 1
			table.insert(self.avatars,avat)
			table.insert(self.team[1],avat)
		end

		avatids = {1004,1004}
		for j = 1,#avatids do
			local i = avatids[j]
			local avat = Avatar.New(self, i, 5000)
			self.defendteam:AddMember(avat)
			avat.team = self.defendteam
			avat.enemyteam = self.attackteam
			--avat.atkdis = TableAvatar[i].Line
			avat.beginpos = battle.map_central + (offset[j] + math.random(10,50))
			avat.baseY = baseY[j]
			--self.m:enterMap(avat,self.central+TableAvatar[i].Line)
			avat.teamid = 2
			table.insert(self.avatars,avat)
			table.insert(self.team[2],avat)
		end

    	local wpk = CPacket.NewWPacket()
   		wpk:Write_uint16(NetCmd.CMD_SC_BATTLE_START)
   		wpk:Write_double(battle.map_central)
   		wpk:Write_uint8(#self.avatars)
		for k,v in pairs(self.avatars) do   			
			wpk:Write_uint8(v.uid)
			wpk:Write_uint16(v.avatid)
			wpk:Write_uint8(v.teamid)
			wpk:Write_double(v.beginpos)
			wpk:Write_double(v.baseY)
			wpk:Write_uint32(v.hp)
		end	
		Send2Client(wpk)
	end
end

-- 选择位置最靠前的目标
function battle:GetFrontTargetByTeam(team)
	local target = nil
	if team == self.attackteam then
		for k,v in pairs(self.attackteam.members) do
			if target then
				if target:GetPositionX() < v:GetPositionX() then
					target = v
				end
			else
				target = v
			end
		end
	elseif team == self.defendteam then
		for k,v in pairs(self.defendteam.members) do
			if target then
				if target:GetPositionX() > v:GetPositionX() then
					target = v
				end
			else
				target = v
			end
		end
	end
	return target
end

function battle:Ready()
	self.ready = true
	local now = Time.SysTick()
	for k,v in pairs(self.avatars) do
		v.common_cd = now + math.random(1, 500)
	end
	self:notifySkillState()
	print("Ready")
end

function battle:UseSkill(rpk)
	if self.start then
		local uid = rpk:Read_uint8()
		local avat
		for k,v in pairs(self.avatars) do
			if uid == v.uid then
				avat = v
			end
		end
		if avat then
			avat:UseSkill(rpk)
		end
	end
end

function battle:SelectTarget(rpk)
	--[[
	if self.start then
		local uid = rpk:Read_uint8()
		for k,v in pairs(battle.team[2]) do
			if uid == v.uid and v.alive then
				local avat = v
				for k,v in pairs(battle.team[1]) do
						v.target = avat
				end
				break
			end
		end
	end]]--
end

return {
	New = function() return battle:new() end
	--[[
	ProcessTick = ProcessTick,
	StartBattle = StartBattle,
	Ready = Ready,
	UseSkill = UseSkill,
	SelectTarget = SelectTarget
	]]
}




