-- 编队
local team = {}

local HitIntervalFrames = 120 -- 连击时间间隔

function team:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self

	return o
end

function team:Init(battle,direction)
	self.battle = battle
	self.direction = direction
	self.targetteam = nil
	self.hittarget = nil
	self.hitcounts = 0
	self.hitframes = 0
	self.members = {}
	
	return self
end

function team:InitAvatars(avatars)
	local yy = 0
	for k,v in pairs(avatars) do
		local pos = {x = (k * 50 - 400) * self.direction, y = yy}
		local avatar = self.battle:NewAvatar()
		avatar:Init(self.battle,self,v.avatarid)
		avatar:SetPosition(pos,yy)
		avatar:SetDirection(self.direction)
		self.members[k] = avatar
		self.battle:AddAvatar(avatar)
		if yy == 0 then
			yy = 8
		else
			yy = 0
		end
	end
end

function team:SetTargetTeam(targetteam)
	self.targetteam = targetteam
end

function team:Death()
	for k,v in pairs(self.members) do
		if not v:Death() then
			return false
		end
	end
	return true
end

function team:ProcessPerFrame()
	-- 计算连击
	if self.hitframes > 0 then
		self.hitframes = self.hitframes - 1
		if self.hitframes == 0 then
			self.hittarget = nil
			self.hitcounts = 0
		end
	end
end

-- 连击处理
function team:OnHit()
	self.hitcounts = self.hitcounts + 1
	self.hitframes = HitIntervalFrames
end

-- 位置最靠前的成员
function team:FrontMember()
	local avat = nil
	for k,v in pairs(self.members) do
		if avat then
			if avat.position.x * self.direction < v.position.x * self.direction then
				avat = v
			end
		else
			avat = v
		end
	end
	return avat
end

return team