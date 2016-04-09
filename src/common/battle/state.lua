-- 公共状态
local state = {}

function state:new()
	local o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end

function state:Init(avatar)
	self.avatar = avatar
	return self
end

function state:InitState()
	--do nothing
	return self
end

function state:IsDone()
	--do nothing
	return false
end

function state:BeginState()
	--do nothing
end

function state:EndState()
	--do nothing
end

function state:ProcessPerFrame(tick)
	--do nothing
end

function state.derive(self)
	local subclass = self:new()
	subclass.new = function(self)
		local o = {}		
		setmetatable(o, self)
    	self.__index = self
    	return o		
	end
	return subclass
end

-- 战斗状态
local state_battle = state:derive()

function state_battle:InitState()
	return self
end

-- battle 状态没有结束
function state_battle:IsDone()
	return false
end

function state_battle:ProcessPerFrame()
	local avatar = self.avatar
	-- 先进行状态检查
	if avatar:IsFalling() then
		avatar:Fall()
		return
	end
	-- 由AI来决策干什么
	avatar.ai:Process()
end

-- 前进
local state_forward = state:derive()

function state_forward:InitState(frames)
	self.frame = 0
	self.frames = frames
	return self
end

function state_forward:IsDone()
	if self.frame < self.frames then
		return false
	end
	return true
end

function state_forward:ProcessPerFrame()
	if self.frame < self.frames then
		self.frame = self.frame + 1
	end
end

-- 后退
local state_backward = state:derive()

function state_backward:InitState(frames)
	self.frame = 0
	self.frames = frames
	return self
end

function state_backward:IsDone()
	if self.frame < self.frames then
		return false
	end
	return true
end

function state_backward:ProcessPerFrame()
	if self.frame < self.frames then
		self.frame = self.frame + 1
	end
end

-- 使用技能
local state_skill = state:derive()

function state_skill:InitState(skill)
	self.skill = skill
	self.castframe = 0
	self.frame = 0
	return self
end

function state_skill:IsDone()
	local skill = self.skill
	if self.castframe < skill.castframes or self.frame < skill.frames then
		return false
	end
	return true
end

function state_skill:BeginState()
	local avatar = self.avatar
	local skill = self.skill
	-- 处理skillbefore
	skill:Before()
end

function state_skill:EndState()
	local avatar = self.avatar
	local skill = self.skill

	-- 处理skillafter
	skill:After()
end

function state_skill:ProcessPerFrame()
	local avatar = self.avatar
	local skill = self.skill

	-- 引导阶段
	if self.castframe < skill.castframes then
		self.castframe = self.castframe + 1
		-- 处理引导
		skill:ProcessCast(self.castframe)
		return
	end
	-- 技能阶段
	if self.frame < skill.frames then
		self.frame = self.frame + 1
		-- 处理技能
		skill:Process(self.frame)
	end
end

-- 空中下落
local state_fall = state:derive()

function state_fall:InitState()
	self.falling = true
	return self
end

function state_fall:IsDone()
	if self.falling then
		return false
	end
	return true
end

function state_fall:ProcessPerFrame()
	local avatar = self.avatar
	if self.falling then
    	if not avatar:IsFalling() then
    		self.falling = false
    	end
	end
end

-- 原地停留
local state_stay = state:derive()

function state_stay:InitState(frames)
	self.frame = 0
	self.frames = frames
	return self
end

function state_stay:IsDone()
	if self.frame < self.frames then
		return false
	end
	return true
end

function state_stay:ProcessPerFrame()
	if self.frame < self.frames then
		self.frame = self.frame + 1
	end
end

-- 僵直
local state_crick = state:derive()

function state_crick:InitState()
	self.cricking = true
	return self
end

function state_crick:IsDone()
	if self.cricking then
		return false
	end
	return true
end

function state_crick:BeginState()
	local avatar = self.avatar
	-- 开启重力回弹
	avatar:SetGravityBomb(true)
end

function state_crick:EndState()
	local avatar = self.avatar
	-- 关闭重力回弹
	avatar:SetGravityBomb(false)
end

function state_crick:ProcessPerFrame()
	local avatar = self.avatar
	if self.cricking then
		if not avatar:IsMoving() and not avatar:IsFalling() then
			self.cricking = false
		end
	end
end

-- 跳
local state_jump = state:derive()

function state_jump:InitState(frames)
	self.frame = 0
	self.frames = frames
	return self
end

function state_jump:IsDone()
	if self.frame < self.frames then
		return false
	end
	return true
end

function state_jump:BeginState()
	local avatar = self.avatar
	-- 开启重力
	--avatar:SetGravity(false)
end

function state_jump:EndState()
	local avatar = self.avatar
	-- 关闭重力
	--avatar:SetGravity(true)
end

function state_jump:ProcessPerFrame()
	if self.frame < self.frames then
		self.frame = self.frame + 1
	end
end

--[[
local state_dead = state:derive()

function state_dead:Process(tick)
	if tick >= self.deadline then
		--销毁avatar
	end
end

function state_dead:BeginState(extra)
	local avatar = self.avatar
	if avatar.action then
		avatar:stopAction(avatar.action)
		avatar.action = nil
	end	
	local deadline = extra
	self.avatar.avatar2d:RunAnimation(EnumActions.Dead)
	self.deadline = deadline
	return self
end


local state_float = state:derive()

function state_float:BeginState(height,distance)
	self.height = height
	self.distance = distance
end

function state_float:Process(tick)

end
]]

return {
	state = state,
	state_battle = state_battle,
	state_forward = state_forward,
	state_backward = state_backward,
	state_skill = state_skill,
	state_fall = state_fall,
	state_crick = state_crick,
	state_stay = state_stay,
	state_jump = state_jump,
}