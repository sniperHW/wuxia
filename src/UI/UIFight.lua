local UIMessage = require "UI.UIMessage"

local skillIDs = {2011, 3011, 4011, 5011, 6011}

local UIFight = class("UIFight", function()
    return require("UI.UIBaseLayer").create()
end)

function UIFight.create()
    local layer = UIFight.new()
    return layer
end

function UIFight:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil    
    --local function onSkillTouched(sender, event)
    	--local skillid = sender:getTag()
    	--local uid = self.skills[skillid].uid
    	--CMD_USE_SKILL(uid, skillid)
    --end
    
    local function onNodeEvent(event)
        if "enter" == event then
            local spr = self.createSprite("Icon/Battle_Background.png", cc.p(0, 0), {self, cc.p(0, 0)})
            spr:setScale(0.5 * self.visibleSize.width/DesignSize.width)
            spr:setLocalZOrder(-1)
            --[[local infos = {}
            for id, hero in pairs(MgrPlayer) do
                if hero.teamid == 1 then
                    local info = {avatid = hero.avatid, id = hero.id, skill = 5, anger = 50, hp = 10, maxHp = 10} 
                    table.insert(infos,info)
                end
            end
            self:ShowHeros(infos)
            self:UpdateHeroInfo(infos)]]--
            --self:ShowHeros(self.heros)
            --for k,v in pairs(self.heros) do
            --    self:UpdateHero(v)
            --end            
        elseif "exit" == event then
            --cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function UIFight:ShowHeros(heros)
	self.Widgets = {}
    local beginPos = cc.p(self.visibleSize.width/2 - 160*3, -50)    
    local function onSkillTouched(sender, event)
        local skillid = sender:getTag()
        print("-->> skillid:", skillid)
        for idx, widget in pairs(self.Widgets) do
            if skillid == widget.BtnBack:getTag() then
                hero = widget.hero
                hero.ai:UseUnique()
                break
            end
        end
    end

    local function onSkillReleaseOut(sender, event)
        local skillid = sender:getTag()
        --print("-->> skillid:", skillid)
    end

	for idx, hero in pairs(heros) do
	    local avatid = hero.avatarid
        local widget = {}
        local btnPos = cc.pAdd(cc.p(160*(idx-1), 0),beginPos)

        widget.BtnBack =  self.createButton{pos = btnPos,
            icon = "Icon/Battle_Button1.png",
            handle = onSkillTouched,
            parent = self
        }
        widget.BtnBack:setScale(0.5)
        widget.BtnBack:registerControlEventHandler(onSkillReleaseOut, cc.CONTROL_EVENTTYPE_TOUCH_UP_OUTSIDE)
        widget.BtnBack:setZoomOnTouchDown(false)
        
        local barSp = cc.Sprite:create("Icon/Battle_Anger.png")
        local eBar = cc.ProgressTimer:create(barSp)
        eBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        eBar:setMidpoint(cc.p(0.5, 0))
        eBar:setBarChangeRate(cc.p(0, 1))
        eBar:setPercentage(50)
        eBar:setPosition(cc.pAdd(btnPos, cc.p(126, 112)))
        eBar:setScale(0.5)
        self:addChild(eBar)
        widget.barAnger = eBar
        
        local lifeBack = self.createSprite("Icon/Battle_Life2.png", 
            cc.pAdd(btnPos,cc.p(160, 65)), {self})
        lifeBack:setScale(0.5)
        
        local barSp = cc.Sprite:create("Icon/Battle_Life1.png")
        local eBar = cc.ProgressTimer:create(barSp)
        eBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        eBar:setMidpoint(cc.p(0.5, 0))
        eBar:setBarChangeRate(cc.p(0, 1))
        eBar:setPercentage(60)
        eBar:setPosition(cc.pAdd(btnPos, cc.p(193, 112)))
        eBar:setScale(0.5)
        self:addChild(eBar)
        widget.barSkillTimes = eBar
        
        local barSp = cc.Sprite:create("Icon/Battle_Yellow.png")
        local eBar = cc.ProgressTimer:create(barSp)
        eBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        eBar:setMidpoint(cc.p(0.5, 0))
        eBar:setBarChangeRate(cc.p(0, 1))
        eBar:setPercentage(30)
        eBar:setPosition(cc.pAdd(btnPos, cc.p(160, 65)))
        eBar:setScale(6)
        eBar:setRotation(90)
        self:addChild(eBar)
        widget.barLife = eBar
        
        local avaInfo = TableAvatar[avatid]
        if avaInfo.Head then
            print("avaInfo.Head[1]",avaInfo.Head[1])
            local iconHead = self.createSprite(avaInfo.Head[1], 
                cc.pAdd(btnPos,cc.p(175,145)), {self})
            iconHead:setScale(0.5)
            widget.iconHead = iconHead
            local skillID = avaInfo.UniqueSkill
            widget.BtnBack:setTag(skillID)
        end
        
        local sprMask = self.createSprite("Icon/Battle_Button3.png", 
            cc.pAdd(btnPos, cc.p(80, 55)), {self, {x = 0, y = 0}})                                 
        sprMask:setScale(0.5)
        sprMask:setVisible(false)
        widget.mask = sprMask
        widget.hero = hero        
        self.Widgets[hero] = widget
	end	
end

local hpbarPath = {"Icon/Battle_Yellow.png", "Icon/Battle_Blue.png", "Icon/Battle_Red.png"}
function UIFight:UpdateHero(hero)
    local widget = self.Widgets[hero]
    if widget then
        local life = hero.hp/hero.maxhp * 100
        local hpbar = hpbarPath[3]
        if life > 80 then
            hpbar = hpbarPath[1]
        elseif life > 40 then
            hpbar = hpbarPath[2]
        else
            hpbar = hpbarPath[3]
        end
        widget.barLife:setSprite(cc.Sprite:create(hpbar))
        widget.barLife:setPercentage(life)
        widget.barSkillTimes:setPercentage(10)
        widget.barAnger:setPercentage(hero.anger)
    end
end

function UIFight:UpdateSkillState(packet)
    --[[for _, value in pairs(packet) do
       local skillInfo = value[2][1]

        local skillid = skillInfo[1]
        local skillEnable = skillInfo[2]
        local id = value[1]
        local widget = self.Widgets[id]
        if widget then
            widget.BtnBack:setEnabled(skillEnable)
            widget.mask:setVisible(not skillEnable)
        end
    end]]--
end

function UIFight:onHeroDead(hero)
    local widget = self.Widgets[hero] 
    if widget then
        widget.BtnBack:setEnabled(false)
        widget.mask:setVisible(true)
        widget.BtnBack:setBackgroundSpriteForState(
            ccui.Scale9Sprite:create("Icon/Battle_Button2.png"),cc.CONTROL_STATE_DISABLED)
        --local player = MgrPlayer[uid]
        local avaInfo = TableAvatar[hero.avatid]
        if avaInfo then
            widget.iconHead:setTexture(avaInfo.Head[2])
        end
    end
end

--[[function UIFight:ShowFlyAtk(atker)
    local function hideFlyAtk( )
        self.btnFlyAtk:setVisible(false)
        self.btnFlyAtk:setTag(0)
    end

    self.btnFlyAtk:setVisible(true)
    self.btnFlyAtk:setTag(atker)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(hideFlyAtk)))
end]]--


local COMBOACTIONTAG = 12312
function UIFight:ShowCambo(times)
    if not self.nodeCombo then
        self.nodeCombo = cc.Node:create()
        self:addChild(self.nodeCombo)
        local spr = self.createSprite("menu/Cambo.png", 
            {x = self.visibleSize.width - 310, y = 500}, {self.nodeCombo})
        spr:setScale(0.5)
        self.lblCombo = cc.Label:createWithBMFont("fonts/9.fnt", 1,
            cc.TEXT_ALIGNMENT_CENTER, 0, {x = 0, y = 0})
        self.lblCombo:setAnchorPoint(cc.p(0, 0.5))
        self.lblCombo:setPosition({x = self.visibleSize.width - 190, y = 550})
        self.nodeCombo:addChild(self.lblCombo)
    end

    self.lblCombo:setString(times)
    local function fadeOutEnd()
        self.nodeCombo:setVisible(false)
    end

    self.nodeCombo:setVisible(true)

    local acScaleMax = cc.EaseIn:create(cc.ScaleTo:create(0.1, 0.6), 3)
    local acScaleMin = cc.ScaleTo:create(0.1, 0.4)
    local acScale = cc.Sequence:create(acScaleMax, acScaleMin)
    acScale:setTag(COMBOACTIONTAG)
    --local acScale = cc.Sequence:create(acScaleMax)

    self.lblCombo:runAction(acScale)

    local acNode = cc.Sequence:create(cc.DelayTime:create(1), cc.FadeTo:create(2, 1), cc.CallFunc:create(fadeOutEnd))
    acNode:setTag(COMBOACTIONTAG)
    if self.nodeCombo:getActionByTag(COMBOACTIONTAG) then
        self.nodeCombo:stopActionByTag(COMBOACTIONTAG)
    end
    self.nodeCombo:runAction(acNode)
end

return UIFight
