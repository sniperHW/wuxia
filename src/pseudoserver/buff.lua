local NetCmd = require "src.net.NetCmd"
local BuffFunc = require "src.pseudoserver.bufffunction"
local Time = require "src.pseudoserver.time"
require "src.table.TableBuff"
require "src.table.TableBuff_Nexus"

local buffExclusion = TableBuff_Nexus
local buff = {}

function buff:new()
	local o = {}   
	self.__index = self
	setmetatable(o, self)
	return o
end

local function GetTabFunction(tb,name)
	return BuffFunc[tb[name]]
end

function buff:Init(id,owner,releaser,tb,period)
	self.releaser = releaser -- who release the buff
	self.id = id
	self.owner = owner
	self.tb = tb
	self.interval = tb["Interval"] or 0
	if not period then
		self.period1 = tb["Period1"] or 0
		self.period2 = tb["Period2"] or 0
		period = self.period1 + self.period2
	end
	self.endTick = Time.SysTick() + period
	self.onBegin = GetTabFunction(tb,"OnBegin")
	self.onEnd = GetTabFunction(tb,"OnEnd")
	self.onInterval = GetTabFunction(tb,"OnInterval")
	if self.interval > 0 and self.onInterval then
		self.nextInterval = Time.SysTick() +  self.interval
	end	
	return self
end

function buff:Do(event)
	local func = self[event]
	if func then
		local ret,err = pcall(func,self)
	end
end

function buff:Reset(releaser,period)
	self.releaser = releaser
	if not period then
		period = self.period1 + self.period2
	end
	self.endTick = Time.SysTick() + period
end

function buff:NotifyBegin()
	local wpk = CPacket.NewWPacket(64)
	wpk:Write_uint16(NetCmd.CMD_SC_BUFFBEGIN)
	wpk:Write_table({suffer=self.owner.uid,buffid=self.id})
	Send2Client(wpk)
end

function buff:NotifyEnd()
	local wpk = CPacket.NewWPacket(64)
	wpk:Write_uint16(NetCmd.CMD_SC_BUFFEND)
	wpk:Write_table({suffer=self.owner.uid,buffid=self.id})
	Send2Client(wpk)
	self:Do("onEnd")
end

--if return false means the buff have end
function buff:Tick(currenttick)
	if self.nextInterval and currenttick >= self.nextInterval then
		self.nextInterval = Time.SysTick() +  self.interval
		self:Do("onInterval")
	end	
	if currenttick >= self.endTick then
		return false
	end
	return true
end

local buffmgr = {}

function buffmgr:new(avatar)
	local o = {}   
	setmetatable(o, self)
	self.__index = self
	o.avatar = avatar
	o.buffs = {}
	return o	
end

local replace     = 1
local exclude    = 2
local interrupt  = 3

function buffmgr:NewBuff(releaser,id,period)
	local tb = TableBuff[id]
	if not tb then
		return false
	end
	for k,v in pairs(self.buffs) do
		local exclusion	= buffExclusion[id]
		if exclusion then exclusion = exclusion[k] end
		if exclusion == exclude then 
			return false
		elseif exclusion == replace  or id == k then
			if id == k then
				v:Reset(releaser,period)
				return true
			else
				--remove the old one
				self:RemoveBuff(k)
				break
			end
		elseif  exclusion == interrupt then
			self:RemoveBuff(k)	
		end	
	end
	local buf = buff:new():Init(id,self.avatar,releaser,tb,period)
	self.buffs[id] = buf
	--local AtkSkill = tb["AtkSkill"]
	--if AtkSkill and AtkSkill > 0 and releaser.robot then
	--	buf.buffSkill = {AtkSkill,C.GetSysTick()+100,500}
	--end
	buf:NotifyBegin()
	buf:Do("onBegin")	
	return true
end

function buffmgr:OnAvatarDead()
	for k,v in pairs(self.buffs) do
		v:NotifyEnd()
	end
	self.buffs = {}	
end

function buffmgr:RemoveBuff(id)
	local buf = self.buffs[id]
	if not buf then
		return false
	end
	self.buffs[id] = nil
	print("RemoveBuff",id)
	buf:NotifyEnd()
	return true
end

function buffmgr:Tick(currenttick)
	for k,v in pairs(self.buffs) do
		if not v:Tick(currenttick) then
			v:NotifyEnd()
			self.buffs[k] = nil --remove the buff
		end
	end
end

function buffmgr:HasBuff(buffid)
	if buffid and self.buffs[buffid] then
		return true
	else
		return false
	end
end

return {
	New = function (avatar)  
		return buffmgr:new(avatar) 
	end
}
