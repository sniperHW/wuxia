local comm = require("common.CommonFun")

local TestScene = class("TestScene",function()
    return cc.Scene:create()
end)

local sceneMapID = 0
function TestScene.create()
    local scene = TestScene.new()
    return scene
end

function TestScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil  

    self.sprMap = cc.Sprite:create()
    self.sprMap:setPositionY(60)
    self.sprMap:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.sprMap)  

    local sprMap = cc.Sprite:create("map/map_1/map0_2.png")
    sprMap:setAnchorPoint(cc.p(0, 0))    
    self.sprMap:addChild(sprMap)
    self.mapButtom = sprMap

    local sprMap = cc.Sprite:create("map/map_1/map0_1.png")
    sprMap:setAnchorPoint(cc.p(0, 0))    
    self.sprMap:addChild(sprMap)
    self.mapMid = sprMap    

    local sprMap = cc.Sprite:create("map/map_1/map0_0.png")
    sprMap:setAnchorPoint(cc.p(0, 0))   
    sprMap:setLocalZOrder(1) 
    self.sprMap:addChild(sprMap)
    self.mapTop = sprMap
    
    local draw = cc.DrawNode:create()
    self.drawNode = draw
    self.sprMap:addChild(draw, 65535)
    --self.sprMap:runAction(cc.ScaleTo:create(0.1, 2))
    --self.sprMap:setScale(3)
    
    local player = require("Hero").create(1004, nil)
    --player:setScale(0.7)
    local sprite2D = player:getChildByTag(EnumAvatar.Tag2D)
    sprite2D:setScale(0.7)
    --sprite2D:setScaleX(-0.7)
    player:setPosition(300, 200)
    self.sprMap:addChild(player)    

    local pp = nil
    local pos = {cc.p(150, 130), 
        cc.p(560, 400), 
        cc.p(500, 230), 
        cc.p(300, 150), 
        cc.p(400, 400), 
        cc.p(200, 320),
        cc.p(300, 700), 
        cc.p(500, 550),
        cc.p(760, 500),
        cc.p(800, 350), 
        cc.p(960, 400),
        cc.p(100, 640)}
    local function onNodeEvent(event)
        local ids = {1002, 1005, 1003, 1004, 1005}
        --self.sprMap:runAction(cc.MoveTo:create(0.1,cc.p(-200,-260)))
        --self.sprMap:setPosition(-450, -390)
        
        if "enter" == event then
        --[[
            for i = 1, #pos do
                local player = require("Hero").create(ids[math.random(1,1)], nil)
                player.id = i
                player:setPosition(pos[i])
                --player:setScale(0.7)
                player:setLocalZOrder(math.max(640 - pos[i].y, 2))
                player:SetAvatarName("----"..i.."------")
                self.sprMap:addChild(player)    
                MgrPlayer[i] = player
            end
        ]]
            --[[
            local ids = {1002, 1005, 1003, 1004, 1005}
            local pos = {{x = 0, y = 120}, {x = -60, y = 150}, {x = -40, y = 60}, 
                {x = -110, y = 151}, {x = -100, y = 90}}

            for i = 1, 1 do
                local player = require("Hero").create(ids[i], nil)

                player:setPosition(pos[i].x+ 600, pos[i].y + 50)
                player:setScale(0.7)
                player:setLocalZOrder(200 - pos[i].y)
                --player:setScaleX(-0.7)
                self.sprMap:addChild(player)    
            end

            local pos = {{x = 0, y = 110}, {x = -60, y = 150}, {x = -40, y = 60}, 
                {x = -110, y = 151}, {x = -100, y = 90}}
            for i = 1, 2 do
                local player = require("Hero").create(ids[i], nil)

                player:setPosition(pos[i].x+ 480, pos[i].y + 50)
                player:setScale(0.7)
                player:setLocalZOrder(200 - pos[i].y)
            --player:setScaleX(-0.7)
            self.sprMap:addChild(player)    
            end

            local pos = {{x = 0, y = 110}, {x = -60, y = 150}, {x = -40, y = 60}, 
                {x = -110, y = 151}, {x = -100, y = 90}}
            for i = 1, 2 do
                local player = require("Hero").create(ids[i], nil)

                player:setPosition(pos[i].x+ 360, pos[i].y + 50)
                player:setScale(0.7)
                player:setLocalZOrder(200 - pos[i].y)
                --player:setScaleX(-0.7)
                self.sprMap:addChild(player)    
                pp = player
            end
            ]]
            
         elseif "exit" == event then
            --cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            --self:unregisterScriptHandler()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    


    local function attackEnd()

    end
    
    local fly = false
    local function onTouchBegan(...)
    --[[
        local avatar2D = player:getChildByTag(EnumAvatar.Tag2D)
        
        avatar2D:stopActionByTag(EnumActionTag.State2D)
        avatar2D:runAction(player.actions[EnumActions.Death])
        ]]
    --[[
        if fly == false then
            player:Fly()
        else
            player:Fall()
        end
        fly = not fly
    ]]
        --player:Attack("Skill1")
        --[[
        local scaleAc = cc.ScaleTo:create(0.2, 1.5)
        self.sprMap:runAction(scaleAc)
]]
        
        --MgrPlayer[6]:Attack("Skill2")
        
        --[[
        local maxIdx = #pos
        local ids = {
            math.random(1, maxIdx), math.random(1, maxIdx)}

        for _, id in pairs(ids) do
            print(id)
        end
        
        self:FocusAvatars(ids)
]]

        local schedule = cc.Director:getInstance():getScheduler()
        local v = 0
        local vx = 400
        local dis = 0
        local g = -500
        local b = 0.001
        local beginPosY = 600--player:getPositionY()
        local beginPosX = 200
        local mapPosY = self.sprMap:getPositionY() 
        local eTime = 0
        local function tick(detal)
            eTime = eTime + detal
            local bV = v
            if g*detal + v * v * b * detal <=  0 then
                v = v + g*detal + v * v * b * detal
            end
            
            local bVx = vx
            vx = vx - vx * vx * b * detal
            vx = math.abs(vx, 0)
            bVx = math.abs(bVx, 0)
            local offX = (vx + bVx) / 2 * detal
            beginPosX = beginPosX + offX
            player:setPositionX(beginPosX)

            local offY = (v + bV) / 2 * detal
            beginPosY = offY + beginPosY
            player:setPositionY(beginPosY)
            if beginPosY <= 200 then
                if self.schedulerID then
                    schedule:unscheduleScriptEntry(self.schedulerID)
                    self.schedulerID  = nil
                end
            end
            --[[
            if eTime > math.abs(v/g) * 2 then
                if self.schedulerID then
                    schedule:unscheduleScriptEntry(self.schedulerID)
                    self.schedulerID  = nil
                end
            end
            local posY = v * eTime + eTime * eTime * g * 0.5
            player:setPositionY(posY+beginPosY)
            ]]
            --self.sprMap:setPositionY(mapPosY - 0.5 * posY)
        end    
        if self.schedulerID then
            schedule:unscheduleScriptEntry(self.schedulerID)
            self.schedulerID = nil
        end
        player:setPositionY(600)
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    --listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    --listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:setSwallowTouches(true)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self.hud = require("UI.UIHudLayer").create()
    self:addChild(self.hud, 65535)

    self.hud:openUI("UIFight")
end

function TestScene:FocusAvatars(avatids)
    local avatars = {}
    local minPosX, minPosY = 20000, 200000
    local maxPosX, maxPosY = 0, 0

    for k, v in pairs(avatids) do
        local hero = MgrPlayer[v]
        local ava = hero:getChildByTag(EnumAvatar.Tag2D)
        local box = ava:getBoundingBox()        

        local posX, posY = hero:getPosition()
        local posHero = cc.p(posX, posY)
        
        local minX, minY = posHero.x - box.width/2, posHero.y - box.height/2
        local maxX, maxY = posHero.x + box.width/2, posHero.y + box.height/2
        
        minX = math.max(0, math.min(minX, 2000))
        minY = math.max(0, math.min(minY, 768))
        maxX = math.max(0, math.min(maxX, 2000))
        maxY = math.max(0, math.min(maxY, 768))
        
        if minX < minPosX then
            minPosX = minX
        end
        if minY < minPosY then
            minPosY = minY
        end
        if maxX > maxPosX then
            maxPosX = maxX
        end
        if maxY > maxPosY then
            maxPosY = maxY
        end
    end
    
    local midPos = cc.p((maxPosX+minPosX)*0.5, (maxPosY+minPosY)*0.5)    
    local lbPos = cc.p(-minPosX, -minPosY)
    lbPos.x = math.min(0, math.max(lbPos.x, self.visibleSize.width - 2688))
    lbPos.y = math.min(0, math.max(lbPos.y, self.visibleSize.height - 768))
    local scaleRadio = math.min(self.visibleSize.width/(maxPosX-minPosX), 
        self.visibleSize.height/(maxPosY-minPosY))
    scaleRadio = math.min(2, scaleRadio)
    scaleRadio = math.min(1.5, math.abs(scaleRadio))
    print("-->> radio:", scaleRadio)
        
    local scaleAc = cc.ScaleTo:create(0.1, scaleRadio)
    local moveAc = cc.MoveTo:create(0.1, cc.pMul(lbPos, scaleRadio))
    self.sprMap:runAction(cc.Spawn:create(scaleAc, moveAc))
end

return TestScene