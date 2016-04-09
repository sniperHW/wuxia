-- 基本战斗单位，仅用于继承，专门处理移动碰撞等
local speed_y_min = -8.0		-- 垂直最小速度
local subspeed_y = -0.25			-- 非地面垂直减速度
local gravitybombspeed = -4.0	-- 重力回弹速度
local gravitybombrate = -0.3	-- 重力回弹速度比率

-- 变换
local function transform(u)
	-- 顺时针旋转矩阵
	local cos = math.cos(u.rotation)
	local sin = math.sin(u.rotation)
	-- 旋转矩阵
	--[[
	self.mat[1][1] = cos
	self.mat[1][2] = sin
	self.mat[2][1] = -sin
	self.mat[2][2] = cos
	]]
	local x1 = - u.size.width * u.anchor.x * u.direction
	local y1 = - u.size.height * u.anchor.y
	local x2 = x1 + u.size.width * u.direction
	local y2 = y1 + u.size.height

	local cr = cos
	local sr2 = sin
	local sr = -sin
	local cr2 = cos

	local x = u.position.x
	local y = u.position.y
	-- bottom left
	u.vertices.bl.x = x1 * cr + y1 * sr2 + x
	u.vertices.bl.y = x1 * sr + y1 * cr2 + y
	-- bottom right
	u.vertices.br.x = x2 * cr + y1 * sr2 + x
	u.vertices.br.y = x2 * sr + y1 * cr2 + y
	-- top left
	u.vertices.tl.x = x1 * cr + y2 * sr2 + x
	u.vertices.tl.y = x1 * sr + y2 * cr2 + y
	-- top right
	u.vertices.tr.x = x2 * cr + y2 * sr2 + x
	u.vertices.tr.y = x2 * sr + y2 * cr2 + y
	-- 轴
	u.axis.axisx.x = cos
	u.axis.axisx.y = -sin
	u.axis.axisy.x = sin
	u.axis.axisy.y = cos
end

-- 计算轴投影
local function projection(vertices, axis)
	local bl = vertices.bl.x*axis.x+vertices.bl.y*axis.y
	local br = vertices.br.x*axis.x+vertices.br.y*axis.y
	local tl = vertices.tl.x*axis.x+vertices.tl.y*axis.y
	local tr = vertices.tr.x*axis.x+vertices.tr.y*axis.y

	local min = math.min(bl, br, tl, tr)
	local max = math.max(bl, br, tl, tr)

	return min, max
end

-- 检查轴上投影重叠
local function overlap(vertices1, vertices2 , axis)
	local min1, max1 = projection(vertices1, axis)
	local min2, max2 = projection(vertices2, axis)
	if min1 > max2 or min2 > max1 then
		return false
	end
	return true
end


local unit = {}

function unit:new()
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.super = unit
	return o
end

function unit:Init(battle)
	self.battle = battle
	self.unitid = 0
	-- 位置
	self.position = {x = 0, y = 0}
	self.size = {width = 0, height = 0}
	self.anchor = {x = 0, y = 0}
	self.direction = 1			-- 方向
	self.rotation = 0			-- 旋转角度
	-- 顺时针旋转矩阵
	-- 旋转矩阵
	--self.mat = { {cos, sin}, {-sin, cos} }
	-- 顶点坐标
	self.vertices = {
		bl = {x = 0, y = 0},
		br = {x = 0, y = 0},
		tl = {x = 0, y = 0},
		tr = {x = 0, y = 0}
	}
	-- 轴
	self.axis = {axisx = {x = 0, y = 0}, axisy = {x = 0, y = 0}}
	-- 移动
	self.actionmove = {frames = 0, x = 0, y = 0}

	self.outside = false		-- 是否允许出界
	-- 重力
	self.speed = {x = 0, y = 0}	-- 速度
	self.gravity = false		-- 模拟重力
	self.gravitybomb = false	-- 重力回弹
	self.ground      = 0
	return self
end

function unit:InitTransform()
	transform(self)
end

function unit:SetUnitID(unitid)
	self.unitid = unitid
end

function unit:SetPosition(position,ground)
	self.position.x = position.x
	self.position.y = position.y
	self.ground = ground or self.ground
end

function unit:InGround()
	return self.position.y <= self.ground
end

-- 尺寸
function unit:SetSize(size)
	self.size.width = size.width
	self.size.height = size.height
end

function unit:SetAnchor(anchor)
	self.anchor.x = anchor.x
	self.anchor.y = anchor.y
end

function unit:SetRotation(rotation)
	self.rotation = rotation
end

-- 方向
function unit:SetDirection(direction)
	self.direction = direction
end

-- 设置允许/禁止超出边界
function unit:SetOutSide(outside)
	self.outside = outside
end

-- 重力
function unit:SetGravity(gravity)
	self.gravity = gravity
end

-- 设置开启/关闭重力回弹
function unit:SetGravityBomb(gravitybomb)
	self.gravitybomb = gravitybomb
end

function unit:SetSpeed(speed)
	self.speed.x = speed.x
	self.speed.y = speed.y
end

function unit:MoveBy(frames,point)
	self.actionmove.frames = frames
	self.actionmove.x = point.x / frames
	self.actionmove.y = point.y / frames
end

function unit:MoveTo(frames,point)
	self.actionmove.frames = frames
	self.actionmove.x = (point.x - self.position.x) / frames
	self.actionmove.y = (point.y - self.position.y) / frames
end

function unit:StopMove()
	self.actionmove.frames = 0
end

function unit:StopSpeed()
	self.speed.x = 0
	self.speed.y = 0
end

-- 是否移动中
function unit:IsMoving()
	if self.actionmove.frames > 0 then
		return true
	end
	return false
end

-- 是否下落中
function unit:IsFalling()
	if self.gravity then
		--if self.position.y > 0 or self.speed.y > 0 then
		if not self:InGround() or self.speed.y > 0 then
			return true
		end
	end
	return false
end

-- 检查碰撞
function unit:Intersects(u)
	-- 检查各轴上的投影重叠
	if not overlap(self.vertices, u.vertices, self.axis.axisx) then
		return false
	end
	if not overlap(self.vertices, u.vertices, self.axis.axisy) then
		return false
	end
	if not overlap(self.vertices, u.vertices, u.axis.axisx) then
		return false
	end
	if not overlap(self.vertices, u.vertices, u.axis.axisy) then
		return false
	end

	return true
end

-- 处理2D
function unit:UpdatePerFrame()
	-- 处理位置
	if self.actionmove.frames > 0 then
		local x = self.position.x + self.actionmove.x
		local y = self.position.y + self.actionmove.y
		-- 检查边界
		if not self.outside then
			x = math.max(x,-self.battle.size.width/2)
			x = math.min(x,self.battle.size.width/2)
			y = math.max(y,0)
			y = math.min(y,self.battle.size.height/2)
		end
		self.position.x = x
		self.position.y = y
		self.actionmove.frames = self.actionmove.frames - 1
	end

	-- 处理缩放
	if self.actionscale then

	end

	-- 处理重力
	if self.gravity then
		-- 在空中，或者垂直速度大于0
		--if self.position.y > 0 or self.speed.y > 0 then
		if not self:InGround() or self.speed.y > 0 then
			-- 水平移动
			if self.speed.x ~= 0 then
				local x = self.position.x + self.speed.x
				if not self.outside then
					x = math.max(x,-self.battle.size.width/2)
					x = math.min(x,self.battle.size.width/2)
				end
				self.position.x = x
			end
			-- 处理sub speedy
			if self.speed.y > speed_y_min then
				if self.speed.y + subspeed_y > speed_y_min then
					self.speed.y = self.speed.y + subspeed_y
				else
					self.speed.y = speed_y_min
				end
			end
			-- 垂直移动
			if self.position.y + self.speed.y > 0 then
				local y = self.position.y + self.speed.y
				if not self.outside then
					y = math.min(y,self.battle.size.height/2)
				end
				self.position.y = y
			else
				self.position.y = self.ground
				self.speed.x = 0 -- 清除水平速度
			end
			-- 处理重力回弹
			if self:InGround() then --self.position.y == 0 then
				if self.gravitybomb and self.speed.y < gravitybombspeed then
					self.speed.y = self.speed.y * gravitybombrate
				else
					self.speed.y = 0	
				end
			end
		end
	end

	-- 变换
	transform(self)
end

-- 处理逻辑
function unit:ProcessPerFrame()
	-- do nothing
end

return unit