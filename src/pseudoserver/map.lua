local MinHeap = require "src.pseudoserver.minheap"
local Time = require "src.pseudoserver.time"
local Sche = require "src.pseudoserver.sche"
local NetCmd = require "src.net.NetCmd"

local map = {}

function map:new(battle,length)
	local o = o or {}   
	setmetatable(o, self)
	self.__index = self
	o.battle = battle
	o.length = length
	o.blocks = {}
	o.minheap = MinHeap.New()
	return o
end

function map:moveTo(avat,pos,type,battle)
	local block = self.blocks[pos]
	if not block then
		block = {}
		self.blocks[pos] = block
	end

	local oldBlock = self.blocks[avat.pos]
	oldBlock[avat.uid] = nil	
	block[avat.uid] = avat
	--if type == mov_move then
	avat.moving = true
	--[[
	for k,v in pairs(battle.team[avat.teamid]) do
		local timeout = Time.SysTick() + 200
		if v ~= avat and v.move_cd < timeout  then
			v.move_cd = timeout
		end
	end	
	]]	
	Sche.Spawn(function ()
			local sleeptime = math.abs(avat.pos - pos) * 300
			avat.pos = pos
			Sche.Sleep(sleeptime)
			if avat.alive then
				--avat.move_cd = Time.SysTick() + math.random(1000,1500)
				avat.common_cd = Time.SysTick() + math.random(1000,1500)
				avat.moving = nil
			end	
		end)
    local wpk = CPacket.NewWPacket()
   	wpk:Write_uint16(NetCmd.CMD_SC_MOVETO)
   	wpk:Write_uint8(type)	
   	wpk:Write_uint8(avat.uid)
   	wpk:Write_uint16(pos)
   	Send2Client(wpk)
end

function map:resetPos(avat,pos)
	local block = self.blocks[pos]
	if not block then
		block = {}
		self.blocks[pos] = block
	end

	local oldBlock = self.blocks[avat.pos]
	oldBlock[avat.uid] = nil	
	block[avat.uid] = avat
	avat.pos = pos
end

function map:enterMap(avat,pos)
	local block = self.blocks[pos]
	if not block then
		block = {}
		self.blocks[pos] = block
	end
	avat.pos = pos
	block[avat.uid] = avat
end

return {
	New = function(battle,length) return map:new(battle,length) end
}