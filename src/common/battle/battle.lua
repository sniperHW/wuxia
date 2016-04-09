-- 对战管理器
local Avatar = require "common.battle.avatar"
local Impack = require "common.battle.impack"
local Team = require "common.battle.team"

local AttackerDir = 1 -- 攻击方方向
local DefenderDir = -1 -- 防守方方向

local battle = {}

function battle:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.super = self
	return o
end

local function DegreesToRadians(angle)
	return angle * 0.01745329252
end

local function RadiansToDegrees(angle)
	return angle * 57.29577951
end

function battle:Init(mapid)
	local map = TableMap[mapid]
	if not map then
		print("-->> error : map not found ", mapid)
		return nil
	end
	self.units = {}
	self.avatars = {}
	self.impacks = {}
	self.start = false
	self.complete = false
	self.unitid = 0
	self.teamattacker = Team:new():Init(self,AttackerDir)
	self.teamdefender = Team:new():Init(self,DefenderDir)
	-- 初始化地图信息
	self.size = {
		width = map.BattleSize.width,
		height = map.BattleSize.height
	}
	-- 设置target team
	self.teamattacker:SetTargetTeam(self.teamdefender)
	self.teamdefender:SetTargetTeam(self.teamattacker)
	return self
end

function battle:NewUnitID()
	self.unitid = self.unitid + 1
	return self.unitid
end

function battle:InitAvatars(attackers, defenders)
	self.teamattacker:InitAvatars(attackers)
	self.teamdefender:InitAvatars(defenders)
end

function battle:NewAvatar()
	return Avatar:new()
end

function battle:NewImpack()
	return Impack:new()
end

function battle:AddAvatar(avatar)
	local unitid = self:NewUnitID()
	avatar:SetUnitID(unitid)
	self.units[unitid] = avatar
	self.avatars[unitid] = avatar
	-- 初始化变换
	avatar:InitTransform()
end

function battle:RemoveAvatar(avatar)
	self.units[avatar.unitid] = nil
	self.avatars[avatar.unitid] = nil
end

function battle:AddImpack(impack)
	local unitid = self:NewUnitID()
	impack:SetUnitID(unitid)
	self.units[unitid] = impack
	self.impacks[unitid] = impack
	-- 初始化变换
	impack:InitTransform()
end

function battle:RemoveImpack(impack)
	self.units[impack.unitid] = nil
	self.impacks[impack.unitid] = nil
end

function battle:Start()
	if not self.start then
		self.start = true
	end
end

function battle:IsComplete()
	return self.complete
end

-- 每帧调用一次，处理battle
function battle:ProcessPerFrame()
	-- 开始
	if not self.start then
		return
	end
	-- 完成
	if self.complete then
		return
	end

	-- 更新unit
	for k,v in pairs(self.units) do
		v:UpdatePerFrame()
	end
	-- 处理avatar
	for k,v in pairs(self.avatars) do
		v:ProcessPerFrame()
	end
	-- 处理impack
	for k,v in pairs(self.impacks) do
		if not v:IsDone() then
			v:ProcessPerFrame()
		else
			self:RemoveImpack(v)
		end
	end
	-- 处理team
	self.teamattacker:ProcessPerFrame()
	self.teamdefender:ProcessPerFrame()

	-- 检查是否战斗结束

end

return battle