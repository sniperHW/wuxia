local Name2idx = require "src.net.name2idx"
local netCmd = require "src.net.NetCmd"
local Pseudo = require "src.pseudoserver.pseudoserver"

local NetHandler = {}
function RegNetHandler(handle, cmd)
    NetHandler[cmd] = handle
end

local PseudoNetHandler = {}

local function SuperReg(func,cmd)
	RegHandler(func,cmd)
	PseudoNetHandler[cmd] = func
end

SuperReg(function (rpk)
	local packet = {data={
				positions={}
			}
		            }
	for i = 1,5 do
		packet.data.positions[i] = rpk:Read_uint16()
	end
	NetHandler[netCmd.CMD_SC_BEGPLY](packet)
end,netCmd.CMD_SC_BEGPLY)

SuperReg(function (rpk)
	local packet = {}
	packet.mov_type = rpk:Read_uint8() --1,move,2,atk_back
	packet.id = rpk:Read_uint8()
	packet.posx = rpk:Read_double()
	NetHandler[netCmd.CMD_SC_MOVETO](packet)
end,netCmd.CMD_SC_MOVETO)

SuperReg(function (rpk)
	NetHandler[netCmd.CMD_SC_SKILLSUFFER](rpk:Read_table())
end,netCmd.CMD_SC_SKILLSUFFER)

SuperReg(function (rpk)
	local packet = {avats={}}
	packet.central = rpk:Read_double()		
	local c = rpk:Read_uint8()
	for i = 1,c do
		local avat = {}
		avat.id = rpk:Read_uint8()
		avat.avatid = rpk:Read_uint16()
		avat.teamid = rpk:Read_uint8()
		avat.posx = rpk:Read_double()
		avat.baseY = rpk:Read_double()
		avat.hp = rpk:Read_uint32()
		table.insert(packet.avats,avat)
	end
	NetHandler[netCmd.CMD_SC_BATTLE_START](packet)
end,netCmd.CMD_SC_BATTLE_START)


SuperReg(function (rpk)
	local packet = {}		
	local c = rpk:Read_uint8()
	for i = 1,c do
		local avat = {}
		avat.id = rpk:Read_uint8()
		avat.avatid = rpk:Read_uint16()
		avat.teamid = rpk:Read_uint8()
		avat.pos = rpk:Read_uint16()
		avat.hp = rpk:Read_uint32()
		table.insert(packet,avat)
	end
	NetHandler[netCmd.CMD_SC_NEXT_ROUND](packet)
end,netCmd.CMD_SC_NEXT_ROUND)



--[[
	{atker,suffer,skillid,timeout,hp,atks={damage1,damage2,.....}}
]]--

SuperReg(function (rpk)
	local packet = rpk:Read_table()		
	NetHandler[netCmd.CMD_SC_ATK_FLY](packet)
end,netCmd.CMD_SC_ATK_FLY)


SuperReg(function (rpk)
	local packet = {winteam = rpk:Read_uint8()}
	NetHandler[netCmd.CMD_SC_BATTLE_RETSULT](packet)
end,netCmd.CMD_SC_BATTLE_RETSULT)



--[[
{
	{uid,{
			{skillid,useable},
			...
		 }
	},
	.....
}

]]--

SuperReg(function (rpk)
	local packet = rpk:Read_table()

	NetHandler[netCmd.CMD_SC_SKILL_STATE](packet)
end,netCmd.CMD_SC_SKILL_STATE)


SuperReg(function (rpk)
	--local packet = {winteam = rpk:Read_uint8()}
	--NetHandler[netCmd.CMD_SC_BATTLE_RETSULT](packet)
end,netCmd.CMD_SC_BUFFBEGIN)

SuperReg(function (rpk)
	local packet = rpk:Read_table()
	NetHandler[netCmd.CMD_SC_BUFFEND](packet)
	--print("CMD_SC_BUFFEND")
end,netCmd.CMD_SC_BUFFEND)

SuperReg(function (rpk)
	--print("CMD_SC_DEAD")
	local packet = {uid = rpk:Read_uint8()}
	NetHandler[netCmd.CMD_SC_DEAD](packet)
end,netCmd.CMD_SC_DEAD)





function OnPseudoServerPacket(rpk)
	local cmd = rpk:Read_uint16()
	local func = PseudoNetHandler[cmd]
	if func then
		func(rpk)
	end
end