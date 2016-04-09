local Avatar = require "common.battle.avatar"
local Skill = require "battle.skill"
local SpriteAvatar = require "SpriteAvatar"

local avatar = Avatar:new()
avatar.super = Avatar

function avatar:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- override
function avatar:Init(battle,team,avatarid)
	avatar.super.Init(self,battle,team,avatarid)
	-- client
	self.node = cc.Node:create()
	self.spriteavatar = SpriteAvatar.create(avatarid)
	self.node:addChild(self.spriteavatar)
	self.spriteavatar:RunAnimation(EnumActions.Idle)
	return self
end

function avatar:NewSkill()
	return Skill:new()
end

function avatar:SetDirection(direction)
	avatar.super.SetDirection(self,direction)
	-- client
	self.spriteavatar:setFlippedX(direction < 0)
end

-- 战斗初始状态
function avatar:Battle()
	avatar.super.Battle(self)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Idle)
end

-- 向前移动
function avatar:Forward(frames,distance,callback)
	avatar.super.Forward(self,frames,distance,callback)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Walk)
end

-- 向后移动
function avatar:Backward(frames,distance,callback)
	avatar.super.Backward(self,frames,distance,callback)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Back)
end

-- 原地停留
function avatar:Stay(frames,callback)
	avatar.super.Stay(self,frames,callback)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Idle)
end

-- 空中下落
function avatar:Fall(callback)
	avatar.super.Fall(self,callback)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Idle)
end

-- 跳
function avatar:Jump(frames,distance,height,speed,callback)
	avatar.super.Jump(self,frames,distance,height,speed,callback)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Jump)
end

function avatar:Skill(skill)
	avatar.super.Skill(self,skill)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Walk)
end

function avatar:Crick(skill)
	avatar.super.Crick(self)
	-- client
	self.spriteavatar:RunAnimation(EnumActions.Hit)
end

-- 处理2D
function avatar:UpdatePerFrame()
	avatar.super.UpdatePerFrame(self)
	-- client
	self.node:setPosition(self.position)
end

-- 处理逻辑
function avatar:ProcessPerFrame()
	avatar.super.ProcessPerFrame(self)
	-- client
	self.node:setPosition(self.position)
end

return avatar