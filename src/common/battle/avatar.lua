-- 角色，继承于unit
local Unit = require "common.battle.unit"
local Skill = require "common.battle.skill"
local State = require "common.battle.state"
local AI = require "common.battle.ai"

local avatar = Unit:new()
avatar.super = Unit

function avatar:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- override
function avatar:Init(battle,team,avatarid)
	avatar.super.Init(self,battle) -- 初始化super

	local tableAvatar = TableAvatar[avatarid]
	if not tableAvatar then
		print("-->> error : avatar not found ", avatarid)
		return nil
	end
	-- unit 参数
	self.size.width = tableAvatar.Size.width
	self.size.height = tableAvatar.Size.height
	self.anchor.x = 0.5
	self.anchor.y = 0
	self.gravity = true

	-- avatar 参数
	self.team = team
	self.avatarid = avatarid
    self.vocation = tableAvatar.Vocation-- 职业

    self.commonskill = self:NewSkill():Init(battle,self,tableAvatar.CommonSkill) -- 普攻
    self.uniqueskill = self:NewSkill():Init(battle,self,tableAvatar.UniqueSkill) -- 绝招

    -- 属性
    self.hp = 1000
    self.maxhp = 1000
    self.anger = 50

    -- 初始化状态机
    self.state = nil
    self.statecallback = nil
	self.states = {}
	self.states.bettle = State.state_battle:new():Init(self)
	self.states.forward = State.state_forward:new():Init(self)
	self.states.backward = State.state_backward:new():Init(self)
	self.states.skill = State.state_skill:new():Init(self)
	self.states.fall = State.state_fall:new():Init(self)
	self.states.crick = State.state_crick:new():Init(self)
	self.states.stay = State.state_stay:new():Init(self)
	self.states.jump = State.state_jump:new():Init(self)
	-- ai
	self.ai = AI:new():Init(self)

	return self
end

function avatar:NewSkill()
	return Skill:new()
end

-- 战斗初始状态
function avatar:Battle()
	self:RunState(self.states.bettle:InitState())
end

-- 向前移动
function avatar:Forward(frames,distance,callback)
	-- 计算移动的相对位置
	local point = {x = distance * self.direction, y = 0}
	self:MoveBy(frames,point)
	self:RunState(self.states.forward:InitState(frames),callback)
end

-- 向后移动
function avatar:Backward(frames,distance,callback)
	-- 计算移动的相对位置
	local point = {x = -distance * self.direction, y = 0}
	self:MoveBy(frames,point)
	self:RunState(self.states.backward:InitState(frames),callback)
end

-- 原地停留
function avatar:Stay(frames,callback)
	self:RunState(self.states.stay:InitState(frames),callback)
end

-- 空中下落
function avatar:Fall(callback)
	self:RunState(self.states.fall:InitState(),callback)
end

-- 跳
function avatar:Jump(frames,distance,height,speed,callback)
	-- 计算移动的相对位置
	local point = {x = distance * self.direction, y = height}
	self:MoveBy(frames,point)
	self:SetSpeed(speed)
	self:RunState(self.states.jump:InitState(frames),callback)
end

function avatar:Skill(skill)
	local function done()
		if self:IsFalling() then
			self:Fall()
		else
			self:Battle()
		end
	end
	self:RunState(self.states.skill:InitState(skill),done)
end

function avatar:Crick()
	local function done()
		self:Stay(30)
	end
	self:RunState(self.states.crick:InitState(),done)
end

function avatar:OnHit(impack)
	if impack.crick == 1 then
		self:StopMove()
		if impack.targetmove then
			local point = {x = impack.targetmove.x * impack.direction, y = impack.targetmove.y}
			self:MoveBy(impack.targetmove.frames, point)
		end
		if impack.targetspeed then
			local speed = {x = impack.targetspeed.x * impack.direction, y = impack.targetspeed.y}
			self:SetSpeed(speed)
		end
		self:Crick()
	end
end

function avatar:RunState(state,callback)
	-- 结束当前状态
	if self.state then
		self.state:EndState()
	end
	-- 替换当前状态
	self.state = state
	self.statecallback = callback
	-- 开始当前状态
	if self.state then
		self.state:BeginState()
	end
end

-- override
function avatar:UpdatePerFrame()
	avatar.super.UpdatePerFrame(self)

	self.commonskill:UpdatePerFrame()
	self.uniqueskill:UpdatePerFrame()
end

-- override
function avatar:ProcessPerFrame()
	avatar.super.ProcessPerFrame(self)
	-- 检查状态结束
	if self.state and self.state:IsDone() then
		local state = self.state
		local statecallback = self.statecallback
		self.state = nil
		self.statecallback = nil
		state:EndState()
		if statecallback then
			statecallback()
		end
	end
	-- 检查当前状态
	if not self.state then
		local state = self.states.bettle
		state:BeginState()
		self.state = state
		self.statecallback = nil
	end
	if self.state:IsDone() then
		print("-->> error : state done")
	end
	self.state:ProcessPerFrame()
end

return avatar