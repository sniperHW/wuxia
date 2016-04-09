local netCmd = require "src.net.NetCmd"

local UILogin = class("UILogin", function()
    return require("UI.UIBaseLayer").create()
end)

function UILogin.create()
    local layer = UILogin.new()
    return layer
end

local checkTickScheduleID = nil
local lastConnectTime = GetSysTick()
local function checkTick(detal)
	local wpk = GetWPacket()
    WriteUint32(wpk, 0xABABCBCB)
    SendWPacket(wpk)

    if GetSysTick() - lastConnectTime >= 10*1000 then
        Close()
    end
end

function UILogin:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil

    local spr = self.createSprite("menu/Login/Login.png", 
        {x = self.visibleSize.width/2, y = self.visibleSize.height/2}, {self})
    spr:setScale(0.5)
    
    spr = self.createSprite("menu/Login/Logo.png", 
        {x = self.visibleSize.width/2, y = self.visibleSize.height/2 + 150}, {self})
    spr:setScale(0.5)
    
    spr = self.createSprite("menu/Login/bg.png", 
        {x = self.visibleSize.width/2, y = 0}, {self, {x = 0.5, y = 0}})
    spr:setScale(0.5)
    
    spr = self.createSprite("menu/Login/Icon_Sys.png", 
        {x = self.visibleSize.width-30, y = self.visibleSize.height-30}, {self})
    spr:setScale(0.5)
    
    local nodeMid = cc.Node:create()
    self.nodeMid = nodeMid
    nodeMid:setPositionX((self.visibleSize.width - 960)/2)
    self:addChild(self.nodeMid)
    
    local function btnHandle(sender, event)
        print("pre connect")        
        local userName = self.txtUserName:getText()
        CMD_LOGIN(userName)
    end
    
    local btn = self.createButton{pos = {x = self.visibleSize.width/2, y = 160},
        icon = "menu/Login/Icon_Login.png",
        handle = btnHandle,
        ignore = false,
        parent = nodeMid
    }
    btn:setScale(0.5)
    
    btn = self.createButton{pos = {x = 120, y = 80},
        icon = "menu/Login/Icon_Reg.png",
        handle = nil,
        ignore = false,
        parent = self
    }
    btn:setScale(0.5)

    local function onExitTouched(sender, event)
        cc.Director:getInstance():endToLua()
    end
    
    btn = self.createButton{pos = {x = self.visibleSize.width - 120, y = 80},
        icon = "menu/Login/Icon_Out.png",
        handle = onExitTouched,
        ignore = false,
        parent = self
    }
    btn:setScale(0.5)

    local function onTextHandle(typestr)
        if typestr == "began" then
        elseif typestr == "changed" then

        elseif typestr == "ended" then
        elseif typestr == "return" then
        end
        --return true
    end
    
    local vsize = self.visibleSize
    
    self.txtUserName = ccui.EditBox:create({width = 325, height = 60},
        "UI/login/txtInput.png")
        --self.createScale9Sprite("UI/login/txtInput.png", nil, {widht = 255, height = 55}, {}))
    self.txtUserName:setPosition(vsize.width/2 -100, vsize.height/2+30)
    self.txtUserName:setAnchorPoint(0, 0.5)
    self.txtUserName:registerScriptEditBoxHandler(onTextHandle)
    nodeMid:addChild(self.txtUserName)
    
    self.txtPass = ccui.EditBox:create({width = 325, height = 60},
        "UI/login/txtInput.png")
        --self.createScale9Sprite("UI/login/txtInput.png", nil, {widht = 255, height = 55}, {}))
    self.txtPass:setPosition(vsize.width/2-100, vsize.height/2-30)
    self.txtPass:setAnchorPoint(0, 0.5)
    self.txtPass:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.txtPass:registerScriptEditBoxHandler(onTextHandle)
    nodeMid:addChild(self.txtPass)

    RegHandler(function (rpk)     
        print("CMD_CC_CONNECT_SUCCESS")    
        local userName = self.txtUserName:getText()
        local pass = self.txtPass:getText()
        CMD_LOGIN(userName)
        local sche = cc.Director:getInstance():getScheduler()
        checkTickScheduleID = sche:scheduleScriptFunc(checkTick, 1, false)
        lastConnectTime = GetSysTick()+1
    end, netCmd.CMD_CC_CONNECT_SUCCESS)

    --beginButton:registerControlEventHandler(btnHandle, cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end
    
RegHandler(function (rpk) 
    print("CMD_CC_CONNECT_FAILED")
end, netCmd.CMD_CC_CONNECT_FAILED)
    
RegHandler(function (rpk) 
    print("CMD_CC_DISCONNECTED")
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(checkTickScheduleID)
    checkTickScheduleID = nil
    local UIMessage = require "UI.UIMessage"
    UIMessage.showMessage("网络断开，请重新登录")
end, netCmd.CMD_CC_DISCONNECTED)

RegNetHandler(function (rpk)
    lastConnectTime = GetSysTick()    
end, netCmd.CMD_CC_PING)
    
return UILogin