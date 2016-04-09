
local ai = {}

function ai:new()
	local o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end

function ai:Init(avatar)
	self.avatar = avatar
	self.autounique = false
	self.useunique = false
	return self
end

-- 设置开启/关闭绝招自动释放
function ai:SetAutoUnique(autounique)
	self.autounique = autounique
end

function ai:UseUnique()
	local avatar = self.avatar
	if not self.autounique and not self.useunique then
		self.useunique = true
		if avatar.state ~= avatar.states.fall and avatar.state ~= avatar.states.crick and avatar.state ~= avatar.states.jump then
			avatar:StopMove()
			avatar:StopSpeed()
			avatar:Battle()
		end
	end
end

function ai:CommonSkill1()
	local avatar = self.avatar
	local skill = avatar.commonskill

	-- 攻击技能，选择敌人作为目标
	local target = avatar.team.targetteam:FrontMember()
	if not target then
		return
	end
	-- 是否越过目标位置
	local dis = (target.position.x - avatar.position.x) * avatar.direction - (avatar.size.width + target.size.width)/2
	if dis < 0 then
		local distance = 60
		local frames = math.ceil(distance/4)
		local function done()
			avatar:Stay(10) -- 原地停留10帧
		end
		avatar:Backward(frames, distance, done)
		return
	end

	if not skill:IsUsable() then
		return
	end
	-- 如果超过攻击范围，前进
	if skill.distance < dis then
		local distance = math.min(dis - skill.distance, 100)
		local frames = math.ceil(distance/4)
		local function done()
			avatar:Stay(50) -- 原地停留50帧
		end
		avatar:Forward(frames,distance,done)
		return
	end
	-- 高度
	--if target:getPositionY() - target.baseY < 150 then
		--avatar:UseSkill(avatar.normalskill,target)
	--end
	self.target = target
	avatar:Skill(skill)
	return
end

-- 近身技能AI
function ai:UniqueSkill1()
	local avatar = self.avatar
	local skill = avatar.uniqueskill
	-- 选择目标，顺序：连击目标>攻击目标>选择目标
	local target = avatar.team.hittarget or avatar.target or avatar.team.targetteam:FrontMember()

	if not target then
		self.useunique = false
		return
	end

	local function doskill()
		-- 是否越过目标位置
		local dis = (target.position.x - avatar.position.x) * avatar.direction - (avatar.size.width + target.size.width)/2
		if dis < 0 then
			local distance = 60
			local frames = math.ceil(distance/6)
			local function done()
				avatar:Stay(10,doskill) -- 原地停留10帧
			end
			avatar:Backward(frames,distance,done)
			return
		end
		-- 如果超过攻击范围，前进
		if skill.distance + 200 < dis then
			local distance = dis - skill.distance - 200
			local frames = math.ceil(distance/10)
			avatar:Forward(frames,distance,doskill)
			return
		end

		local distance = math.max(target.position.x - avatar.position.x + skill.distance * target.direction, 0)
		local height = math.max(target.position.y - avatar.position.y, 0)
		local frames = math.max(math.ceil(distance /30), math.ceil(height /30), 1)
		local function done()
			avatar:StopSpeed()
			avatar.target = target
			avatar:Skill(skill)
			self.useunique = false
		end
		if skill.distance < 100 and height > 100 then
			avatar:Jump(frames,distance,height,target.speed,done)
		else
			avatar:Jump(frames,distance,0,target.speed,done)
		end
	end

	doskill()
end

function ai:Process()
	local avatar = self.avatar

	if self.autounique and avatar.uniqueskill:IsUsable() then
		self.useunique = true
	end

	if self.useunique then
		local skill = avatar.uniqueskill
		if skill.type == 1 then
			self:UniqueSkill1()	-- 近身技能
		elseif skill.type == 2 then
			self:UniqueSkill2()	-- 远程技能
		elseif skill.type == 3 then
			self:UniqueSkill3()	-- 法师？
		elseif skill.type == 4 then
			self:UniqueSkill4()	-- 治疗技能
		end
	else
		local skill = avatar.commonskill
		if skill.type == 1 then
			self:CommonSkill1()	-- 近身技能
		elseif skill.type == 2 then
			self:CommonSkill2()	-- 远程技能
		elseif skill.type == 3 then
			self:CommonSkill3()	-- 法师？
		elseif skill.type == 4 then
			self:CommonSkill4()	-- 治疗技能
		end
	end
end

return ai