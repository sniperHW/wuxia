local netCmd = require "src.net.NetCmd"

MgrLoadedMap = {}
played = false
heros = {}
local SceneLogin = class("SceneLogin",function()
    return cc.Scene:create()
end)

function SceneLogin.create()
    local scene = SceneLogin.new()
    return scene
end

function SceneLogin:setOpenUI(uiName)
    self.defaultUI = uiName
end

function SceneLogin:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("menu/Icon_BG2.png")--("Back.png")
    local spriteDog = cc.Sprite:createWithTexture(textureDog)
    spriteDog:setAnchorPoint({x = 0, y = 0})
    --spriteDog:setPosition({x = -220, y = 0})
    spriteDog:setPosition(self.visibleSize.width-textureDog:getContentSize().width, 0)
    
    --spriteDog:setScale(DesignSize.width/spriteDog:getContentSize().width)
    self:addChild(spriteDog)
    
    self.hud = require("UI.UIHudLayer").create()
    self:addChild(self.hud, 1)

    local function createHeros(heroid, idx)        
        local heroPos = {{x = 420, y = 230 - 100}, {x = 570, y = 210 - 100},
            {x = 1020, y = 230 - 100},{x = 870, y = 210 - 100}, {x = 720, y = 200 - 100}}
        
        if heroid > 0 then
            local player = require("SpriteAvatar").create(heroid,1,0.7)
            player:setScale(0.7)
            player:RunAnimation(EnumActions.Idle)
            --local player = require("Hero").create(1005, nil)

            player:setPosition(heroPos[idx])
            --player:setScale(0.7)

            --if i == 5 then
            --    player:setScaleX(-0.7)
            --end
            --player:setScaleX(-0.7)
            spriteDog:addChild(player)    
        end
    end

    local function onNodeEvent(event)
        if "enter" == event then            
            if played then
                self.hud:openUI("UIMainLayer")

                for i = 1, #heros do
                    createHeros(heros[i], i)
                end
                spriteDog:setPosition({x = -220, y = 0})
            else
                self.hud:openUI("UILogin")
            end
            
            local cache = cc.Director:getInstance():getTextureCache()
            for idx, path in pairs(MgrLoadedMap) do
                cache:removeTextureForKey(path)    
            end

            --cache:removeUnusedTextures()
        elseif "exit" == event and self.schedulerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            cc.SimpleAudioEngine:getInstance():stopMusic()
            --self:unregisterScriptHandler()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    local function onTouchBegan(...)

    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:setSwallowTouches(true)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)    

    RegNetHandler(function (packet) 
        print("begin play")
        
        self.hud:closeUI("UILogin")
        heros = packet.data.positions
        for i = 1, #heros do
            createHeros(packet.data.positions[i], i)
        end

        local ac = cc.MoveTo:create(0.5, cc.p(-220, 0))
        local function openMain()
            self.hud:openUI("UIMainLayer")
            played = true
        end

        spriteDog:runAction(cc.Sequence:create(cc.EaseIn:create(ac, 3), cc.CallFunc:create(openMain)))
    end, netCmd.CMD_SC_BEGPLY)
end

return SceneLogin