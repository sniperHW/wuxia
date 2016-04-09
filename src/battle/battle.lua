local Battle = require "common.battle.battle"
local Avatar = require "battle.avatar"
local Impack = require "battle.impack"

local battle = Battle:new()
battle.super = Battle

function battle:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function battle:Init(mapid)
	battle.super.Init(self,mapid)

	local map = TableMap[mapid]
	if not map then
		print("-->> error : map not found ", mapid)
		return nil
	end
	self.layer = cc.Layer:create()
	self.layer:setPosition(map.BattlePosition)
	self.layer:setAnchorPoint(map.BattleAnchor)
	return self
end

function battle:NewAvatar()
	return Avatar:new()
end

function battle:NewImpack()
	return Impack:new()
end

function battle:AddAvatar(avatar)
	battle.super.AddAvatar(self,avatar)
	
	self.layer:addChild(avatar.node)
end

function battle:RemoveAvatar(avatar)
	battle.super.RemoveAvatar(self,avatar)

	self.layer:removeChild(avatar.node)
end

function battle:AddImpack(impack)
	battle.super.AddImpack(self,impack)

	self.layer:addChild(impack.node)
end

function battle:RemoveImpack(impack)
	battle.super.RemoveImpack(self,impack)
	
	self.layer:removeChild(impack.node)
end

return battle