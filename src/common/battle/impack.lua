-- 技能效果，继承于unit
local Unit = require "common.battle.unit"

local impack = Unit:new()
impack.super = Unit

function impack:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function impack:Init(battle,skill,targets,impackid)
	impack.super.Init(self,battle)

	local tableImapck = TableImpack[impackid]
	if not tableImapck then
		print("-->> error : impack not found ", impackid)
		return nil
	end

	self.skill = skill
	self.targets = targets
	self.owner = skill.owner
	-- 位置
	self.position.x = self.owner.position.x + tableImapck.Offset.x * self.owner.direction
	self.position.y = self.owner.position.y + tableImapck.Offset.y
	self.size.width = tableImapck.Size.width
	self.size.height = tableImapck.Size.height
	self.anchor.x = tableImapck.Anchor.x 
	self.anchor.y = tableImapck.Anchor.y
	-- 方向
	self.direction = skill.owner.direction
	-- 自己
	self.frames = tableImapck.Frames
	self.moves = tableImapck.Moves
	-- 目标
	self.intervalframes = tableImapck.IntervalFrames
	self.crick = tableImapck.Crick
	self.targetmove = tableImapck.TargetMove
	self.targetspeed = tableImapck.TargetSpeed

	self.frame = 0
	self.overs = {}
	self.Effect = tableImapck.Effect 

	return self
end

function impack:IsDone()
	if self.frame < self.frames then
		return false
	end
	return true
end

-- override
function impack:UpdatePerFrame()
	impack.super.UpdatePerFrame(self)
end

-- override
function impack:ProcessPerFrame()
	if self.frame < self.frames then
		self.frame = self.frame + 1
		if self.moves and self.moves[self.frame] then
			local move = self.moves[self.frame]
			local point = {x = move.x * self.direction, y = move.y}
			self:MoveBy(move.frames, point)
		end
		if self.intervalframes and self.intervalframes > 0 then
			if self.frame % self.intervalframes == 0 then
				self.overs = {}
			end
		end
		for k,v in pairs(self.targets) do
			if not self.overs[k] and self:Intersects(v) then
				self.overs[k] = v
				v:OnHit(self)
			end
		end
	end
end

function impack:Hit(avatar)
	
end

return impack