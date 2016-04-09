local UIResult = class("UIPVEResult", function()
    return require("UI.UIBaseLayer").create()
end)

function UIResult .create()
    local layer = UIResult .new()
    return layer
end

function UIResult:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function UIResult:Win()
    local size = self.visibleSize
    local spr = self.createSprite("menu/cg.png", {x = size.width/2+5, y = size.height/2}, {self})
    spr:runAction(cc.RepeatForever:create(cc.RotateBy:create(3,360)))
    self.createSprite("menu/sl.png", {x = size.width/2, y = size.height/2+80}, {self})
end

function UIResult:Failed()
    local size = self.visibleSize
    local spr = self.createSprite("menu/sbb.png", {x = size.width/2+5, y = size.height/2+80}, {self})
    spr:runAction(cc.RepeatForever:create(cc.RotateBy:create(6,360)))
    self.createSprite("menu/sb.png", {x = size.width/2, y = size.height/2+80}, {self})
end

return UIResult