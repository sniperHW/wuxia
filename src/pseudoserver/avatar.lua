local Time = require "src.pseudoserver.time"
local NetCmd = require "src.net.NetCmd"
local Skill = require "src.pseudoserver.skill"
local Buff = require "src.pseudoserver.buff"
local Sche = require "src.pseudoserver.sche"
require "src.table.TableAvatar"

local avatar = {}

local mov_move = 1
local mov_jumpback = 2
local mov_jumpforward = 3
local mov_run = 4

local skill_useable = 1
local skill_disable = 2
local skill_pending = 3  

local mov_dis = 120.0 -- px
local backjump_dis = 120.0

function avatar:new(battle,avatid,hp)
	local o = o or {}   
	setmetatable(o, self)
	self.__index = self
	
	o.battle = battle
	o.uid = battle:NewUid()
	o.avatid = avatid
	o.hp = hp
	o.alive = true
	o.pos = 0
	o.common_cd = 0
	o.escape_cd = 0 -- 后跳逃离CD
  	o.move_cd = 0 
  	--o.pending_skills = {}
  	o.buff = Buff.New(o)
  	o.buff_stat = {}
  	
  	o.attackdis = TableAvatar[o.avatid].AttackDistance -- 攻击距离
  	o.modelradius = TableAvatar[o.avatid].ModelRadius -- 模型半径
  	-- 普通攻击
  	local attackskillid = TableAvatar[o.avatid].AttackSkill
	o.attackskill = Skill.New(attackskillid)
	
	-- 技能
	o.skills = {}
	local tmp = {}
	for k,v in pairs(TableAvatar[o.avatid].Skill) do
		o.skills[v] = Skill.New(v)
		o.skills[v].flag = skill_disable
		table.insert(tmp,{v,false})
	end
	o.battle.skill_state = o.battle.skill_state or {}
  	table.insert(o.battle.skill_state,{o.uid,tmp})	
	return o
end

function avatar:GetPositionX()
	return MgrPlayer[self.uid]:getPositionX()
end

function avatar:GetPositionY()
	return MgrPlayer[self.uid]:getPositionY()
end

function avatar:process(now)
	if not self.alive then 
		return
	end
	self.buff:Tick(now)
	if self.teamid == 1 then
		local tmp
		for k,v in pairs(self.skills) do
			if v.flag == skill_disable and v:IsUsable(now) then
				tmp = tmp or {}
				v.flag = skill_useable
				table.insert(tmp,{v.id,true})
			end
		end
		if tmp then
			self.battle.skill_state = self.battle.skill_state or {}
	  		table.insert(self.battle.skill_state,{self.uid,tmp})		
  		end
  	end
	if self.buff_stat[3002] then
		return
	end

	if self.common_cd > now then
		return
	end
	
	if not self.alive or self.moving or self.buff_stat[3001] then
		return
	end
	-- 
	-- 处理技能
	self:ProcessPendingSkills(now)


	if not self.alive or self.moving or self.buff_stat[3001] then
		return
	end

	self:Process(now)
end

function avatar:ProcessPendingSkills(now)
	if self.pending_skill then
		if self.skilltarget and self.skilltarget.alive then
			if self.team == self.battle.attackteam then
				if self:GetPositionX() >= self.skilltarget:GetPositionX() then
					self:BackJump()
					return
				end
			elseif self.team == self.battle.defendteam then
				if self:GetPositionX() <= self.skilltarget:GetPositionX() then
					self:BackJump()
					return
				end
			end

			local dis = self.skilltarget:GetPositionX() - self:GetPositionX()
			if math.abs(dis) > (self.attackdis + self.modelradius + self.skilltarget.modelradius) then
				local offsetX = math.abs(dis) - (self.attackdis + self.modelradius + self.skilltarget.modelradius)
				local posx = self:GetPositionX() + offsetX * dis/math.abs(dis) + self.modelradius
				self:MoveTo(posx, mov_run)
				return
			end

			if self:DoUseSkill(self.pending_skill, now) then
				self.pending_skill = nil
			end
		else
			self.pending_skill.flag = skill_disable
			self.pending_skill = nil
		end
		
	end
end

function avatar:DoUseSkill(skill, now)
	-- 使用技能
	if self.skilltarget and self.skilltarget.alive and skill then
		self.team.combonumber = self.team.combonumber + 1
		self.team.combotimeout = now + 5000

		local wpk = CPacket.NewWPacket()
		wpk:Write_uint16(NetCmd.CMD_SC_SKILLSUFFER)	
		local tmp = {atker=self.uid,suffer=self.skilltarget.uid,skill=skill.id,atks={}}
		local fly
		if skill.atkFly and self.skilltarget.hp > 0 and not self.skilltarget.moving then
			fly = true
		end
		local c = 1
		if skill.cd < 500 then
			c = math.random(2,4)
		end
		local timeout = 0
		for i=1,c do
			local damage = math.random(50,150)
			timeout = timeout + skill.cd 
			self.skilltarget:Suffer(damage)
			table.insert(tmp.atks,damage)
			if not self.skilltarget.alive then
				break
			end
		end
		tmp.hp = self.skilltarget.hp
		tmp.fly = fly
		if fly then
			self.skilltarget.buff:NewBuff(self,3001,1500)
			self.skilltarget.buff:NewBuff(self,3002,3000)
		elseif self.skilltarget.buff_stat[3001] then
			self.skilltarget.buff:NewBuff(self,3001,timeout)
			self.skilltarget.buff:NewBuff(self,3002,timeout+3000)
		end

		if skill.atkFly or self.skilltarget:GetPositionY() - self.baseY > 50 then
			self.buff:NewBuff(self,3001,800)
		end
		self.buff:NewBuff(self,3002,timeout > 1000 and timeout or 1000)
		wpk:Write_table(tmp)
		Send2Client(wpk)
		skill.timeout = now + timeout
		skill.flag = skill_disable
		self.common_cd = now + 3000
	end
	return true
end

function avatar:Process(now)
	local target = self.battle:GetFrontTargetByTeam(self.enemyteam)
	if not target then
		return
	end
	if self.team == self.battle.attackteam then
		if self:GetPositionX() >= target:GetPositionX() then
			self:BackJump()
			return
		end
	elseif self.team == self.battle.defendteam then
		if self:GetPositionX() <= target:GetPositionX() then
			self:BackJump()
			return
		end
	end

	if self.attackskill:IsUsable(now) then
		local dis = target:GetPositionX() - self:GetPositionX()
		if math.abs(dis) <=  (self.attackdis + self.modelradius + target.modelradius) then
			local skill = self.attackskill
			local wpk = CPacket.NewWPacket()
			wpk:Write_uint16(NetCmd.CMD_SC_SKILLSUFFER)				
			local tmp = {atker=self.uid,suffer=target.uid,skill=skill.id,atks={},normal_skill = true}
			local damage = math.random(50,100)
			table.insert(tmp.atks,damage)
			target:Suffer(damage)
			skill:Used(now)
			local backpos
			if self.attackdis > 200 and not target.buff_stat[3001] and not target.moving then
				if self.teamid == 1 then
					if math.random(1,100) > 90 then
						backpos = target:AttackBack(math.random(90,120))
					end
				else
					if math.random(1,100) > 90 then
						backpos = target:AttackBack(math.random(90,120))
					end					
				end
			end
			self.common_cd = now + math.random(1000,1200)
			tmp.backpos = backpos
			if backpos then
				target.common_cd = now + 1500
			end
			wpk:Write_table(tmp)
			Send2Client(wpk)
			return
		end
	end

	if target then
		if target.moving then
			self.common_cd = now + 100
			return
		end
		if self.attackdis < 200 and math.random(1,100) > 85 then
			self:BackJump()		
			return
		end
		--if now >= self.common_cd then
		local dis = target:GetPositionX() - self:GetPositionX()
		if math.abs(dis) > (self.attackdis + self.modelradius + target.modelradius) then
			--local pos = fronttarget.pos - dis/math.abs(dis)--self.atkdis*(dis/math.abs(dis))
			--if self.teamid == 1 then
			--	print("move pos",math.abs(self.pos - pos),dis)
			--end
			local offsetX = math.abs(dis) - (self.attackdis + self.modelradius + target.modelradius)
			if offsetX > mov_dis then
				offsetX = mov_dis
			end
			offsetX = math.random(offsetX-10,offsetX+10)
			local posx = self:GetPositionX() + offsetX * dis/math.abs(dis) 
			self:MoveTo(posx, mov_move)
			return
			--self.battle.m:moveTo(self,pos,mov_move,self.battle)
		elseif self.attackdis > 200 and math.abs(dis) <= 200 and self.escape_cd < now then
			--local pos = self.pos - dis/math.abs(dis)
			self:BackJump()
			self.escape_cd = now + 5000
			return
		end
		self.common_cd = now + 100
		--end
	end	
end

function avatar:UseSkill(rpk)
	local skill
	local now = Time.SysTick()
	if rpk then
		skill = self.skills[rpk:Read_uint16()]
		if skill then
			skill.flag = skill_pending
	  		self.battle.skill_state = self.battle.skill_state or {}
	  		local tmp = {}
	  		table.insert(tmp,{skill.id,false})
	  		table.insert(self.battle.skill_state,{self.uid,tmp})
	  		if self.pending_skill then
	  			self.pending_skill.flag = skill_disable
	  		end
	  		self.pending_skill = skill
	  		self.common_cd = 0
	  		if self.moving then
	  			self.moving = nil
	  		end

			if self.team.combotimeout > now and self.team.combotarget and self.team.combotarget.alive then
				self.skilltarget = self.team.combotarget
			else
				self.skilltarget = self.battle:GetFrontTargetByTeam(self.enemyteam)
				self.team.combotarget = self.skilltarget
				self.team.combonumber = 0
				self.team.combotimeout = Time.SysTick() + 5000
			end
	  		--[[
	  		if self:DoUseSkill(skill, now) then
	  			self.pending_skill = nil
	  		end
	  		]]
		end
	end
		--[[if skill and skill.flag == skill_useable then
			skill.flag = skill_pending
	  		self.battle.skill_state = self.battle.skill_state or {}  
	  		local tmp = {}
	  		table.insert(tmp,{skill.id,false})
	  		table.insert(self.battle.skill_state,{self.uid,tmp})			
			if now >= self.common_cd then
				if #self.pending_skills > 0 then
					table.insert(self.pending_skills,skill)
					skill = self.pending_skills[1]
					table.remove(self.pending_skills,1)
				end
			else
				table.insert(self.pending_skills,skill)
				skill = nil
			end
		end	
	else
		if now >= self.common_cd and #self.pending_skills > 0 then
			table.insert(self.pending_skills,skill)
			skill = self.pending_skills[1]
			table.remove(self.pending_skills,1)				
		end
	end

	self:DoUseSkill(skill, now)]]--
end

function avatar:MoveTo(posx, type)
	local wpk = CPacket.NewWPacket()
	wpk:Write_uint16(NetCmd.CMD_SC_MOVETO)
   	wpk:Write_uint8(type)
   	wpk:Write_uint8(self.uid)
   	wpk:Write_double(posx)
   	Send2Client(wpk)

   	self.moving = true
   	local avat = self
   	local cd = math.abs(posx - self:GetPositionX())/360*0.6
   	if type == mov_run then
   		self.common_cd = Time.SysTick() + cd + 200
   	else
   		self.common_cd = Time.SysTick() + math.random(1200,1400)
   	end
	Sche.Spawn(function ()
		local sleeptime = 1000
		if type == mov_run then
			sleeptime = cd
		end
		Sche.Sleep(sleeptime)
		if avat.alive then
			avat.moving = nil
		end
	end)
end

function avatar:AttackBack(dis)
	local posx
	if self.teamid == 1 then
		posx = self:GetPositionX() - dis
		if posx < self.battle.map_central - (480.0 - 40.0) then
			posx = self.battle.map_central - (480.0 - 40.0)
		end
	else
		posx = self:GetPositionX() + dis
		if posx > self.battle.map_central + (480.0 - 40.0) then
			posx = self.battle.map_central + (480.0 - 40.0)
		end	
	end
	return posx
end

function avatar:BackJump(dis)
	local distance = math.random(110,130)--backjump_dis
	if dis then
		distance = dis
	end
	local posx
	if self.teamid == 1 then
		posx = self:GetPositionX() - distance
		if posx < self.battle.map_central - (480.0 - 40.0) then
			posx = self.battle.map_central - (480.0 - 40.0)
		end
	else
		posx = self:GetPositionX() + distance
		if posx > self.battle.map_central + (480.0 - 40.0) then
			posx = self.battle.map_central + (480.0 - 40.0)
		end	
	end
	self:MoveTo(posx,mov_jumpback)
	
	--self.common_cd = Time.SysTick() + 1500
	--self.move_cd = Time.SysTick() + 2000
	--battle.m:resetPos(self,pos)
	--return pos	
end



function avatar:Suffer(damage)
	self.hp = self.hp - damage
	if self.teamid == 2 then
		if math.random(1,100) > 80 then
			self.common_cd = Time.SysTick() + 200
		end
	else
		if math.random(1,100) > 50 then
			self.common_cd = Time.SysTick() + 200
		end		
	end
	if self.hp <= 0 then
		--dead
		self.alive = nil
		self.hp = 0
		for k,v in pairs(self.battle.team[self.teamid]) do
			if v == self then
				table.remove(self.battle.team[self.teamid],k)
				self.team:RemoveMember(self)
				break
			end
		end
		for k,v in pairs(self.battle.avatars) do
			if v == self then
				table.remove(self.battle.avatars,k)
				break
			end
		end

		Sche.Spawn(function ()
			Sche.Sleep(500)
	    	local wpk = CPacket.NewWPacket()
	   		wpk:Write_uint16(NetCmd.CMD_SC_DEAD)
	   		wpk:Write_uint8(self.uid)  		
			Send2Client(wpk)					
		end)
	
	end
end

return {
	New = function(battle,avatid,hp) return avatar:new(battle,avatid,hp) end
}