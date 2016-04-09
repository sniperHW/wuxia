local Time = require "src.pseudoserver.time"
require "src.table.TableSkill"

local skill = {}

function skill:new(skillid)
	local sk = TableSkill[skillid]
	if not sk then
		print("-->> error : skill not found ", skillid)
		return
	end
	local o = o or {}
 	setmetatable(o, self)
 	self.__index = self
 	o.id = skillid
 	o.timeout = Time.SysTick()
 	o.cd = sk.Skill_CD
 	o.atkFly = sk.AtkFly == 1
 	return o
end

function skill:IsUsable(now)
	return self.timeout <= now
end

function skill:Used(now)
	self.timeout = now + self.cd + math.random(1,200)
end

return {
	New = function(skillid) return skill:new(skillid) end
}