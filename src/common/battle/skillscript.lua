local skillscript = {}

function skillscript.Skill2011_After(avatar,skill)
	avatar:MoveBy(1,{x=-5,y=0})
--	avatar:SetSpeedX(2 * avatar.direction * -1)
	avatar:SetSpeed({x=0,y=2})
end

return skillscript