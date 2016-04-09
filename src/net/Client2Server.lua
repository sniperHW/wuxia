local netCmd = require "src.net.NetCmd"
UsePseudo = true
local Pseudo = require "src.pseudoserver.pseudoserver"

function CMD_LOGIN(name)		
    local wpk = CPacket.NewWPacket()
    wpk:Write_uint16(netCmd.CMD_CS_LOGIN)
    wpk:Write_string(name)
    Pseudo.Send2Pseudo(wpk)		
end

function CMD_BATTLE_START(mapid)		
    local wpk = CPacket.NewWPacket()
    wpk:Write_uint16(netCmd.CMD_CS_BATTLE_START)
    wpk:Write_uint16(mapid)
    Pseudo.Send2Pseudo(wpk)		
end

function CMD_READY()
    local wpk = CPacket.NewWPacket()
    wpk:Write_uint16(netCmd.CMD_CS_READY)
    Pseudo.Send2Pseudo(wpk)	
end

function CMD_USE_SKILL(heroid,skillid)
    local wpk = CPacket.NewWPacket()
    wpk:Write_uint16(netCmd.CMD_CS_USE_SKILL)
    wpk:Write_uint8(heroid)
    wpk:Write_uint16(skillid)
    Pseudo.Send2Pseudo(wpk) 
end

-- 点击屏幕选择目标
function CMD_CS_SELECTTARGET(heroid)
    local wpk = CPacket.NewWPacket()
    wpk:Write_uint16(netCmd.CMD_CS_SELECTTARGET)
    wpk:Write_uint8(heroid)
    Pseudo.Send2Pseudo(wpk) 
end

cc.Director:getInstance():getScheduler():scheduleScriptFunc(function () 
    if UsePseudo then
        Pseudo.TickPseudo()
    end
end, 0, false)
