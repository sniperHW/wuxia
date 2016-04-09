local Skill = require "common.battle.skill"

local skill = Skill:new()
skill.super = Skill

function skill:new()
	local o = o or {}
 	setmetatable(o, self)
 	self.__index = self
 	return o
end

function skill:Init(battle,owner,id)
	skill.super.Init(self,battle,owner,id)
	local tableSkill = TableSkill[id]
	if not tableSkill then
		print("-->> error : skill not found ", id)
		return nil
	end
 	-- client
 	self.castactions = tableSkill.CastActions
 	self.actions = tableSkill.Actions
	return self
end

function skill:ProcessCast(frame)
	skill.super.ProcessCast(self, frame)
	-- client
	if self.castactions[frame] then
		self.owner.spriteavatar:RunAnimation(EnumActions[self.castactions[frame]])
	end
end

function skill:Process(frame)
	skill.super.Process(self, frame)
	-- client
	if self.actions[frame] then
		self.owner.spriteavatar:RunAnimation(EnumActions[self.actions[frame]])
	end
end

return skill