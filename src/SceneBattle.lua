local Battle = require("battle.battle")

local Time = require("src.util.time")
local UIHudLayer = require("src.UI.UIHudLayer").create()
require("src.table.TableMap")

--region SceneCity.lua
local SceneBattle = class("SceneBattle",function()
    return cc.Scene:create()
end)

function SceneBattle.create()
    local scene = SceneBattle.new()
    return scene
end

local g_scenebattle

function SceneBattle:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    
    -- 创建战斗
    local mapid = 1
    self.battle = Battle:new():Init(mapid)

    local map = TableMap[mapid]

    local attackers = {[1] = {avatarid = 1001},[2] = {avatarid = 1002},[3] = {avatarid = 1003}}
    local defenders = {[1] = {avatarid = 1004},[2] = {avatarid = 1005}}
    self.battle:InitAvatars(attackers, defenders)

    self.sprMap = cc.Layer:create()
    self.sprMap:setContentSize(map.Size)
    self.sprMap:setAnchorPoint(cc.p(0.5, 0))
    self:addChild(self.sprMap)
    
    local draw = cc.DrawNode:create()
    self.drawNode = draw
    self.sprMap:addChild(draw, 65535)
   
    -- 背景层
    local sprMap = cc.Sprite:create(map.BackgroundMapPath)
    sprMap:setAnchorPoint(cc.p(0.5, 0))    
    self.sprMap:addChild(sprMap)
    self.mapButtom = sprMap
    -- 地图
    local sprMap = cc.Sprite:create(map.MapPath)
    sprMap:setAnchorPoint(cc.p(0.5, 0))    
    self.sprMap:addChild(sprMap)
    self.mapMid = sprMap

    local battlelayer = self.battle.layer
    self.sprMap:addChild(battlelayer)
    self.mapBattle = battlelayer
   
    -- 前景层
    local sprMap = cc.Sprite:create(map.ForegroundMapPath)
    sprMap:setAnchorPoint(cc.p(0.5, 0))
    sprMap:setLocalZOrder(EnumZOrder.mapTopLayer) 
    self.sprMap:addChild(sprMap)
    self.mapTop = sprMap

    
    self.UIFight = UIHudLayer:openUI("UIFight")
    --self.UIFight.heros = self.battle.teamattacker.members
    self.UIFight:ShowHeros(self.battle.teamattacker.members)
    for k,v in pairs(self.battle.teamattacker.members) do
        self.UIFight:UpdateHero(v)
    end
    self:addChild(UIHudLayer,640)

    local function onNodeEvent(event)
        if "enter" == event then
            self.battle:Start() -- 开始
            self:TickCamera()
        elseif "exit" == event then
            local scheduler = cc.Director:getInstance():getScheduler()
            if self.schedulerID then
                scheduler:unscheduleScriptEntry(self.schedulerID)
            end
            self:UntickCamera()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    local function update(dt)
        self:Update(dt)
    end
    
    self:scheduleUpdateWithPriorityLua(update, 0)
    -- 设定到地图中间
    --self.sprMap:setPositionX(-(map.Size.width/2 - self.visibleSize.width/2))
    self.sprMap:setPositionX(self.visibleSize.width/2)

    -- 点击屏幕事件，测试用
    local function onTouchBegan(touch)
        local beginpos = touch:getLocation()
        self.beginpos = beginpos
        return true
    end
    local function onTouchEnded(touch)
        local endpos = touch:getLocation()
        x = endpos.x - self.beginpos.x
        y = endpos.y - self.beginpos.y
        if x > -10 and x < 10 and y > -10 and y < 10 then
            local team = self.battle.teams[Battle.TeamAttacker]
            local avatar = team.members[1]
            avatar:SetPosition({x = 1044, y = 0})
            avatar:SetSpeedY(15)
            avatar:SetSpeedX(5)

            avatar = team.members[2]
            avatar:SetPosition({x = 994, y = 300})
            avatar:SetSpeedY(0)

            avatar = team.members[3]
            avatar:SetPosition({x = 1094, y = 300})
            avatar:SetFloat(true)
            avatar:SetSpeedY(0)

            team = self.battle.teams[Battle.TeamDefender]
            avatar = team.members[1]
            avatar:SetPosition({x = 1444, y = 0})
            avatar:MoveBy(10,{x=30,y=0})
            avatar:SetSpeedY(2)
            avatar:SetSpeedX(1)
            avatar.sprite:RunAnimation(EnumActions.Hit)

            avatar = team.members[2]
            avatar:SetPosition({x = 1294, y = 0})
            avatar:SetFloat(true)
            avatar:SetSpeedY(15)
            avatar:SetSpeedX(2)
            avatar.sprite:RunAnimation(EnumActions.Hit)
        else
            local team = self.battle.teams[Battle.TeamDefender]
            local avatar = team.members[2]
            avatar:SetSpeedY(y/10)
            avatar:SetSpeedX(x/10)
        end
    end
    --[[
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
]]
    -- 绘制碰撞线
    local function primitivesDraw(transform, transformUpdated)
        
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)

        gl.lineWidth( 1.0 )
        cc.DrawPrimitives.drawColor4B(255,0,0,255)

        for k,v in pairs(self.battle.units) do
            local vertices = v.vertices
            cc.DrawPrimitives.drawLine( vertices.bl,vertices.br )
            cc.DrawPrimitives.drawLine( vertices.br,vertices.tr )
            cc.DrawPrimitives.drawLine( vertices.tr,vertices.tl )
            cc.DrawPrimitives.drawLine( vertices.tl,vertices.bl )
        end
    end
    local size = {width=2688,height=768}
    local glNode  = gl.glNodeCreate()
    glNode:setContentSize(cc.size(size.width, size.height))
    glNode:setAnchorPoint(cc.p(0.5, 0.5))

    --glNode:registerScriptDrawHandler(primitivesDraw)

    self.battle.layer:addChild(glNode,100)
    glNode:setPosition( size.width / 2, size.height / 2)

    self.hud = require("UI.UIHudLayer").create()
    self:addChild(self.hud, 65535)
    g_scenebattle = self
end

function SceneBattle:Update()
    self.battle:ProcessPerFrame()
end

function SceneBattle:TickMapPos(endTime)
    local size = self.sprMap:getContentSize()
    local cellWidth = MgrConfig.cellWidth
    local vWidth = self.visibleSize.width
    local detalTime = 0

    local function tick(detal)
        for i, hero in pairs(MgrPlayer.selfHero) do
            local player = MgrPlayer[hero.id]
            if player then
                local posX, posY = player:getPosition()
                local diffX = vWidth*0.5 - player.line * cellWidth + player.diffX
                local offX = diffX - posX

                self.sprMap:setPositionX(math.min(0, 
                    math.max(self.visibleSize.width - size.width, offX)))

                detalTime = detalTime + detal
                if detalTime > endTime then
                    self:UntickMapPos()
                    self:TickCamera()
                end
                
                break
            end
        end
    end    
    if self.schedulerID then
        self:UntickMapPos()
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function SceneBattle:UntickMapPos()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
end

function SceneBattle:TickCamera()
    local function tick(detal)
        if self.focusAvatars and #self.focusAvatars > 0 then
            self:FocusAvatars(self.focusAvatars)
        else
            self:FocusAvatars(self.battle.avatars)
        end      
    end    

    self.cameraTick = tick
    if self.cameraSchedulerID then
        self:UntickCamera()
    end
    self.cameraSchedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function SceneBattle:SetFocusAvatars(avatars)
    self.focusAvatars = avatars
end

function SceneBattle:UntickCamera()
    if self.cameraSchedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.cameraSchedulerID)
        self.cameraSchedulerID = nil
    end
end

function SceneBattle:FocusAvatars(avatars)
    if #avatars < 1 then
        return
    end

    local minPosX, minPosY = 20000, 200000
    local maxPosX, maxPosY = 0, 0

    for k, hero in pairs(avatars) do
        local ava = hero.spriteavatar
        local box = ava:getBoundingBox()       
        box.width = 100
        box.height = 150 

        local posX, posY = hero.node:getPosition()
        posY = posY + 130
        local posHero = cc.p(posX, posY)

        local minX, minY = posHero.x - box.width/2, posHero.y
        local maxX, maxY = posHero.x + box.width/2, posHero.y + box.height

        minX = math.min(minX, 2000)
        minY = math.min(minY, 768)
        maxX = math.min(maxX, 2000)
        maxY = math.min(maxY, 768)

        minPosX = math.min(minPosX, minX)
        minPosY = math.min(minPosY, minY)
        maxPosX = math.max(maxPosX, maxX)
        maxPosY = math.max(maxPosY, maxY)  
    end

    local vSize = self.visibleSize

    local mapPosX, mapPosY = self.sprMap:getPosition()
    local curMapScale = self.sprMap:getScale()
    local limitMinPos = self.sprMap:convertToNodeSpace(cc.p(100, 100))
    local limitMaxPos = self.sprMap:convertToNodeSpace(cc.p(vSize.width - 100, vSize.height - 100))
    local midPos = cc.p((maxPosX+minPosX)*0.5, (maxPosY+minPosY)*0.5)    
    
--[[
    self.drawNode:clear()
    self.drawNode:drawPoint(midPos, 20, cc.c4f(0,1,1,1))

    self.drawNode:drawRect(cc.p(minPosX,minPosY), 
        cc.p(maxPosX, maxPosY), cc.c4f(1,1,1,1))
    self.drawNode:drawRect(limitMinPos, limitMaxPos, cc.c4f(0,0,0,1))  
]]

    if minPosX > limitMinPos.x and 
        minPosY > limitMinPos.y and
        maxPosX < limitMaxPos.x and
        maxPosY < limitMaxPos.y and 
        math.abs(mapPosY - 40) < 1 then
        return
    end 

    local scaleRadio = math.min(self.visibleSize.width/(maxPosX-minPosX), 
        self.visibleSize.height/(maxPosY-minPosY))
    scaleRadio = math.min(1.2, math.abs(scaleRadio))
    self.sprMap:setScale(scaleRadio)
    local wPos = self.sprMap:convertToWorldSpace(midPos)

    local tarPos = cc.p(mapPosX - wPos.x + self.visibleSize.width/2, 
        math.min(40, mapPosY - wPos.y + vSize.height/2))

    local diffX = tarPos.x - mapPosX
    if math.abs(diffX) > 10 then
        local tPosX = diffX/math.abs(diffX) * 5 + mapPosX
        self.sprMap:setPositionX(tPosX)
    else
        self.sprMap:setPositionX(tarPos.x)
    end

    local diffY = tarPos.y - mapPosY
    if math.abs(diffY) > 10 then
        local tPosY = diffY/math.abs(diffY) * 5 + mapPosY
        self.sprMap:setPositionY(tPosY)
    else
        self.sprMap:setPositionY(tarPos.y)
    end

    --self.sprMap:setPosition(tarPos)    
end


function GetSceneBattle()
    return g_scenebattle
end

return SceneBattle