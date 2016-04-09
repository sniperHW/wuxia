local UIMessage = require "UI.UIMessage"

local UIMainLayer = class("UIMainLayer", function()
    return require("UI.UIBaseLayer").create()
end)

function UIMainLayer.create()
    local layer = UIMainLayer.new()
    return layer
end

function UIMainLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    
    local spr = self.createSprite("menu/Login/bg.png", 
        {x = self.visibleSize.width/2, y = 0}, {self, {x = 0.5, y = 0}})
    spr:setScale(0.5)

    spr = self.createSprite("menu/Icon_Up_1.png", 
        {x = self.visibleSize.width/2, y = self.visibleSize.height}, {self, {x = 0.5, y = 1}})
    spr:setScale(0.45)
    
    local spr = self.createSprite("menu/Icon_1.png", 
        {x = self.visibleSize.width/2-360, y = self.visibleSize.height}, {self, {x = 0.5, y = 1}})
    spr:setScale(0.45)
    
    local spr = self.createSprite("menu/Icon_System_1.png", 
        {x = self.visibleSize.width/2+360, y = self.visibleSize.height}, {self, {x = 0.5, y = 1}})
    spr:setScale(0.45)
    
    local spr = self.createSprite("menu/Icon_2.png", 
        {x = 10, y = self.visibleSize.height/2}, {self, {x = 0, y = 0.5}})
    spr:setScale(0.5)
    
    local spr = self.createSprite("menu/Icon_3.png", 
        {x = 10, y = 0}, {self, {x = 0, y = 0}})
    spr:setScale(0.5)

    local vsize = self.visibleSize
    local spr = self.createSprite("menu/Icon_Avg_3.png", 
        {x = vsize.width - 180, y = 70}, {self})
    spr:setScale(0.5)
    
    local function onBtnFightTouched(sender, event)
        --CMD_BATTLE_START(1)  
        local scene = require("SceneLoading").create()
        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1, scene))
    end
    
    local btn = self.createButton{pos = {x = vsize.width - 252, y = 73},
        icon = "menu/Icon_Battle_1.png",
        handle = onBtnFightTouched,
        ignore = false,
        parent = self
    }
    btn:setBackgroundSpriteForState(
        ccui.Scale9Sprite:create("menu/Icon_Battle_2.png"), 
        cc.CONTROL_STATE_HIGH_LIGHTED)
    btn:setScale(0.5)
    
    local btn = self.createButton{pos = {x = vsize.width - 112, y = 73},
        icon = "menu/Icon_Avg_1.png",
        handle = onBtnFightTouched,
        ignore = false,
        parent = self
    }
    btn:setBackgroundSpriteForState(
        ccui.Scale9Sprite:create("menu/Icon_Avg_2.png"), 
        cc.CONTROL_STATE_HIGH_LIGHTED)
    btn:setScale(0.5)
end

return UIMainLayer
