local avatar = {}

function avatar:new(data)
	local o = o
 	setmetatable(o, self)
 	self.__index = self
 	o.data = data
 	return o
end

function avatar:Set(key,val)
	if self.data[key] then
		self.data[key] = val
	end
end

function avatar:Get(key)
	return self.data[key]
end

function avatar:CloneData()
	local tmp = {}
	for k,v in pairs(self.data)
		tmp[k] = v
	end
	return tmp
end

return avatar


