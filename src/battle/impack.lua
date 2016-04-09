local Impack = require "common.battle.impack"

local impack = Impack:new()
impack.super = Impack

function impack:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

local EffectFunc = {
	Impack1 = function (self)
		local sprit = cc.Sprite:create("xingxingda.png")
		sprit:setPositionY(self.size.height/2)
		sprit:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1,90)))
		self.node:addChild(sprit)	
	end
}


function impack:Init(battle,skill,targets,impackid)
	impack.super.Init(self,battle,skill,targets,impackid)
	-- client
	self.node  = cc.Node:create()
	if self.Effect then
		EffectFunc[self.Effect](self)
	end
	return self
end

-- 处理2D
function impack:UpdatePerFrame()
	impack.super.UpdatePerFrame(self)
	-- client
	self.node:setPosition(self.position)
end

-- 处理逻辑
function impack:ProcessPerFrame()
	impack.super.ProcessPerFrame(self)
	-- client
	self.node:setPosition(self.position)
end

return impack