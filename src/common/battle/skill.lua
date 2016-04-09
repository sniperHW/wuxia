-- 战斗中技能计算
local SkillScript = require "common.battle.skillscript"

local skill = {}

function skill:new()
	local o = o or {}
 	setmetatable(o, self)
 	self.__index = self
 	return o
end

function skill:Init(battle,owner,id)
	local tableSkill = TableSkill[id]
	if not tableSkill then
		print("-->> error : skill not found ", id)
		return nil
	end
	self.battle = battle
	self.owner = owner
 	self.id = id
 	self.cdrframes = 0							-- 恢复冷却帧数
 	-- 技能参数
 	self.type = tableSkill.Type 				-- 类型
 	self.distance = tableSkill.Distance 		-- 距离
 	self.castframes = tableSkill.CastFrames 	-- 施法帧数
 	self.castmoves = tableSkill.CastMoves 		-- 施法位移
 	self.frames = tableSkill.Frames 			-- 技能帧数
 	self.moves = tableSkill.Moves 				-- 技能位移
 	self.cdframes = tableSkill.CDFrames 		-- 冷却帧数
 	if tableSkill.BeforeScript then
 		self.beforescript = SkillScript[tableSkill.BeforeScript]
 	end
 	if tableSkill.AfterScript then
 		self.afterscript = SkillScript[tableSkill.AfterScript]
 	end

 	self.impacks = tableSkill.Impacks			-- 效果

	return self
end

function skill:IsUsable()
	return self.cdrframes == 0
end

function skill:UpdatePerFrame()
	if self.cdrframes > 0 then
		self.cdrframes = self.cdrframes - 1
	end
end

function skill:Before()
	-- 技能处理需关闭自身重力
	self.owner:SetGravity(false)
	
	if self.beforescript then
		self.beforescript(self.owner,self)
	end
end

function skill:After()
	if self.afterscript then
		self.afterscript(self.owner,self)
	end
	-- CD
	self.cdrframes = self.cdframes
	-- 技能处理结束开启重力
	self.owner:SetGravity(true)
end

function skill:ProcessCast(frame)
	
end

function skill:Process(frame)
	-- 释放者移动
	if self.moves[frame] then
		local move = self.moves[frame]
		local point = {x = move.x * self.owner.direction, y = move.y}
		self.owner:MoveBy(move.frames, point)
	end

	--if true then
	--	self.owner:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1,90)))
	--end

	-- 处理impacks
	if self.impacks[frame] then
		local impacks = self.impacks[frame]
		for k,v in pairs(impacks) do
			local targets = self.owner.team.targetteam.members
			local impack = self.battle:NewImpack()
			impack:Init(self.battle,self,targets,v)
			self.battle:AddImpack(impack)
		end
	end
end

return skill