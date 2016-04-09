local Avatar = require "src.pseudoserver.avatar"

local battleteam = {}

function battleteam:new(battle,teamid)
	local o = o or {}   
	setmetatable(o, self)
	self.__index = self
	o.battle = battle
	o.teamid = type
	o.members = {}
	o.skills_state = {}
	o.combotarget = nil -- 连击目标
	o.combonumber = 0 -- 连击数
	o.combotimeout = 0 -- 连击超时
	return o
end

function battleteam:AddMember(avat)
	table.insert(self.members,avat)
end

function battleteam:RemoveMember(avat)
	for k,v in pairs(self.members) do
		if v == avat then
			table.remove(self.members,k)
			break
		end
	end
end

function battleteam:notifySkillState()

end

-- 选择位置最靠前的目标
function battleteam:GetFront()
	local avat = nil
	for k,v in pairs(self.members) do
		if avat then
			if self.type == attacks then
				if target.pos < v.pos then
					target = v
				end
			elseif self.type == defends then
				if avat.pos > v.pos then
					avat = v
				end
			end
		else
			avat = v
		end
	end
	return avat
end

return {
	New = function(battle,teamid) return battleteam:new(battle,teamid) end,
}