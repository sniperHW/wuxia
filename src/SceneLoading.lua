--region SceneLoading.lua
--Author : youfu
--Date   : 2014/8/13
--此文件由[BabeLua]插件自动生成

local SceneLoading = class("SceneLoading",function()
    return cc.Scene:create()
end)

local targetMapID = nil
function SceneLoading.create()
    local scene = SceneLoading.new()

    return scene
end

function SceneLoading:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    
    local player = require("SpriteAvatar").create(1001)
    player:setScale(0.7)
    player:setPosition(self.visibleSize.width/2, self.visibleSize.height/2)
    --player:setScale(0.7)

    self:addChild(player)
    
    
    local spriteBarBack = cc.Sprite:create("menu/loading_down.png")
    spriteBarBack:setPosition(self.visibleSize.width/2, 50)
    self:addChild(spriteBarBack)
    
    local barSprite = cc.Sprite:create("menu/loading_up.png")
    self.loadingProgress = cc.ProgressTimer:create(barSprite)
    self.loadingProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    --self.loadingProgress:setScaleX(8)
    --self.loadingProgress:setAnchorPoint(0, 0.5)
    self.loadingProgress:setPosition(self.visibleSize.width/2, 46)
    self.loadingProgress:setMidpoint({x = 0, y = 0.5})
    self.loadingProgress:setBarChangeRate({x = 1, y = 0})
    self.loadingProgress:setPercentage(0)    
    self:addChild(self.loadingProgress)
     
    --[[
    local loadImages = {}
         
    local mapInfo = TableMap[targetMapID]
    
    local totalCount = #loadImages
    local function onLoad()
        if #loadImages > 0 then
            print(#loadImages)
            local image = loadImages[1]
            table.remove(loadImages, 1)
            local percentage = (totalCount - #loadImages)/totalCount * 100
            self.loadingProgress:setPercentage(percentage)
            local cache = cc.Director:getInstance():getTextureCache()
            cache:addImageAsync(image, onLoad) 
        else
            if MgrPlayer[maincha.id] 
                or self.mapID == 205
                or self.mapID == 202
                or MgrGuideStep == 4 
                or MgrGuideStep == 15 then
                
                local scene = nil 
                if self.mapID == 205 then
                    scene = require("SceneGarden").create(0)
                else
                    if MgrGuideStep == 4 or MgrGuideStep == 17 then
                        scene = require("SceneGuidePVE").create(targetMapID)
                    else
                        scene = require("SceneCity").create(targetMapID)
                    end
                end
                cc.Director:getInstance():replaceScene(scene)
            else
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
                    cc.CallFunc:create(onLoad)))
            end
        end
    end
    ]]

    local function loadingOver()        
        local scene = nil 
        scene = require("SceneBattle").create()
        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1, scene))
    end
    
    local duration = 0
    local function tick(detal)
        --duration = duration + detal
        --self.loadingProgress:setPercentage(duration/5 * 100)  
    end
    
    self.loadingProgress:runAction(cc.Sequence:create({cc.DelayTime:create(1), cc.ProgressTo:create(2, 100)}))
    
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
    self:runAction(cc.Sequence:create(
        {cc.DelayTime:create(3), 
        cc.CallFunc:create(loadingOver, {}), 
        nil}))
    
    local function onNodeEvent(event)
        if "enter" == event then
            --MgrLoadedMap = {}
            --cache:removeUnusedTextures()
            --MgrPlayer = {}
            --onLoad()
            player:RunAnimation(EnumActions.Walk)
        elseif "exit" == event and self.schedulerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            --self:unregisterScriptHandler()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

return SceneLoading
--endregion
