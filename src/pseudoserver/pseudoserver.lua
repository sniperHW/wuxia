local Sche = require "src.pseudoserver.sche"
local Que = require "src.pseudoserver.queue"
local NetCmd = require "src.net.NetCmd"
local Battle = require "src.pseudoserver.battle"

local msgque = Que.New()
local cmdHandler = {}
local battle

cmdHandler[NetCmd.CMD_CS_LOGIN] = function (rpk)
    	local wpk = CPacket.NewWPacket()
    	wpk:Write_uint16(NetCmd.CMD_SC_BEGPLY)
    	wpk:Write_uint16(1001)
    	wpk:Write_uint16(1002)
        wpk:Write_uint16(1003)
        wpk:Write_uint16(1004)
        wpk:Write_uint16(1005)
    	Send2Client(wpk)		
end

cmdHandler[NetCmd.CMD_CS_BATTLE_START] = function (rpk)
		local mapid = rpk:Read_uint16()
		battle = Battle:New()
		battle:StartBattle(mapid)
end

cmdHandler[NetCmd.CMD_CS_READY] = function (rpk)
		battle:Ready()
end

cmdHandler[NetCmd.CMD_CS_USE_SKILL] = function (rpk)
		battle:UseSkill(rpk)
end

cmdHandler[NetCmd.CMD_CS_SELECTTARGET] = function (rpk)
		battle:SelectTarget(rpk)
end

local function Send2Pseudo(wpk)
	local rpk = CPacket.NewRPacket(wpk)	
	local cmd = rpk:Read_uint16()
	local handler = cmdHandler[cmd]
	if handler then
		handler(rpk)
	end
	--DestroyWPacket(wpk)
	--DestroyRPacket(rpk)
end

local function TickPseudo()
	if battle then
		battle:ProcessTick()
	end
	Sche.Schedule()
	while msgque:Len() > 0 do
		local wpk = msgque:Pop()
		wpk = wpk[1]
		local rpk = CPacket.NewRPacket(wpk)
		OnPseudoServerPacket(rpk)
		--DestroyWPacket(wpk)
		--DestroyRPacket(rpk)
	end
end

function Send2Client(wpk)
	msgque:Push({wpk})
end

return {
	Send2Pseudo = Send2Pseudo,
	TickPseudo = TickPseudo,
	--DestroyMap = DestroyMap,
	--BegPlay = BegPlay,
}






