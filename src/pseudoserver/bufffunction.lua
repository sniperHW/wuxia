local Time = require "src.pseudoserver.time"
local BuffFunc = {
	["Begin3001"] = function (buff)
		buff.owner.buff_stat[3001] = true
	end,	
	["End3001"] = function (buff)
		buff.owner.buff_stat[3001] = nil
	end,
	["Begin3002"] = function (buff)
		buff.owner.buff_stat[3002] = true
	end,	
	["End3002"] = function (buff)
		buff.owner.buff_stat[3002] = nil
	end
}

return BuffFunc