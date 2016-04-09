
local cmd_num = 0

local function SetCmdNum(num)
	cmd_num = num
	return cmd_num
end

local function NextCmdNum()
	cmd_num = cmd_num + 1
	return cmd_num
end

local netcmd = {
	--client to server	
	CMD_CS_LOGIN = SetCmdNum(1),
	CMD_CS_RECONNECT = NextCmdNum(),
	CMD_CS_BATTLE_START = NextCmdNum(),
	CMD_CS_READY = NextCmdNum(),
	CMD_CS_USE_SKILL = NextCmdNum(),
	CMD_CS_SELECTTARGET = NextCmdNum(),
	--server to client
	CMD_SC_BEGPLY = SetCmdNum(100),
	CMD_SC_RECONNECT_RET = NextCmdNum(),
	CMD_SC_BATTLE_START = NextCmdNum(),
	CMD_SC_MOVETO = NextCmdNum(),
	CMD_SC_SKILLSUFFER = NextCmdNum(),
	CMD_SC_BATTLE_RETSULT = NextCmdNum(),
	CMD_SC_SKILL_STATE = NextCmdNum(),
	CMD_SC_ATK_FLY = NextCmdNum(),
	CMD_SC_NEXT_ROUND = NextCmdNum(),
	CMD_SC_BUFFBEGIN = NextCmdNum(),
	CMD_SC_BUFFEND = NextCmdNum(),
	CMD_SC_DEAD = NextCmdNum(),

	--dummy			 		
	CMD_CC_CONNECT_SUCCESS = 65533,
   	CMD_CC_CONNECT_FAILED = 65532,
   	CMD_CC_DISCONNECTED = 65531, 
   	CMD_CC_PING = 65530 	 				
}


--用于生成netcmd.h文件
--[[local function GenC_NetCmd()
	local f = io.open("netcmd.h","w")	
	f:write("#ifndef _NETCMD_H\n#define _NETCMD_H\n")	
	f:write("enum{\n")	
	for k,v in pairs(netcmd) do
		if k ~= "GenC_NetCmd" then
			f:write("	" .. k .. " = " .. v .. ",\n")
		end
	end
	f:write("}\n")
	f:write("#endif\n")
	f:close()
end

netcmd.GenC_NetCmd = GenC_NetCmd
]]--

return netcmd


