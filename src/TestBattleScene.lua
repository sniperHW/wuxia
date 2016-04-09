local TestBattleScene = class("TestBattleScene",function()
    return cc.Scene:create()
end)

function TestBattleScene.create()
    local scene = TestBattleScene.new()
    return scene
end

function TestBattleScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil  

    self.sprMap = cc.Sprite:create()
    --self.sprMap:setPositionY(60)
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

    local mapSize = sprMap:getContentSize()

    local sprMap = cc.Sprite:create("map/map_1/map0_0.png")
    sprMap:setAnchorPoint(cc.p(0, 0))   
    sprMap:setLocalZOrder(1) 
    self.sprMap:addChild(sprMap)
    self.mapTop = sprMap

    self.sprMap:setPositionX(0 - (mapSize.width - self.visibleSize.width/2)/2)
    
    local draw = cc.DrawNode:create()
    self.drawNode = draw
    self.sprMap:addChild(draw, 65535)
    --self.sprMap:runAction(cc.ScaleTo:create(0.1, 2))
    --self.sprMap:setScale(3)
    self:initAvatar()

    local function onNodeEvent(event)
        if "enter" == event then
            
         elseif "exit" == event then

        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function TestBattleScene:initAvatar()
    local player = require("Hero").create(1004, nil)
    --player:setScale(0.7)
    local sprite2D = player:getChildByTag(EnumAvatar.Tag2D)
    sprite2D:setScale(0.7)
    --sprite2D:setScaleX(-0.7)
    player:setPosition(300, 200)
    self.sprMap:addChild(player)   
end

return TestBattleScene