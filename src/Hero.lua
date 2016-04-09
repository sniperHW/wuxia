local comm = require("common.CommonFun")

local Hero = class("Hero", function()
    return cc.Sprite:create()
end)

function Hero.create(avatarID, weapon)
    local sprite = Hero.new()
    sprite.actions = {}
    sprite.delayHit = {}
    sprite.state = EnumHeroState.Idle
    local modelID = TableAvatar[avatarID].ModelID

    local tableModel = TableModel[modelID] 
    local resPath = tableModel.Resource_Path    
      
    if avatarID > 1000 then
        local cache = cc.SpriteFrameCache:getInstance()
        for _, path in pairs(resPath) do
            local img = string.sub(path, 1, string.len(path)- 5)
            cache:addSpriteFrames("char/"..path, "char/"..img.."pvr.ccz")
        end

        local sprite2D = sprite:init2DAvatar(avatarID)
        sprite2D:setTag(EnumAvatar.Tag2D)
        sprite:addChild(sprite2D)
        if TableAvatar[avatarID].Scale then
            sprite2D:setScale(TableAvatar[avatarID].Scale)             
        end
    end

    return sprite
end

function Hero:ctor()
    self.schedulerID = nil
    self.playSkillAction = 0

    local function onNodeEvent(event)
        if "enter" == event then
            self:Idle()
        elseif "exit" == event then
            for _, value in pairs(self.actions) do
                value:release()
            end

            if self.flySchID then                
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.flySchID)
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function Hero:createAction(actionID)
    if actionID < 1 then
        return nil
    end
    
    local animation = cc.Animation:create()
    local tableAction = TableAction[actionID]
    
    local frameCache = cc.SpriteFrameCache:getInstance()
    local name = ""
    for i = tableAction.Start_Frame, tableAction.End_Frame do
        name = string.format(tableAction.Resource_Path..".png", i)
        animation:addSpriteFrame(frameCache:getSpriteFrame(name))
    end
    animation:setDelayPerUnit(tableAction.Frame_Interval)
    local animate = cc.Animate:create(animation)
    animate.offset = tableAction.offset
    return animate
end

function Hero:Idle()
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    local avatar = avatar2d
    --self:stopActionByTag(EnumActionTag.ActionMove)
    if avatar2d then
        avatar:stopActionByTag(EnumActionTag.State2D)
        
        if self.state == EnumHeroState.Attack then
            avatar2d:setPosition(cc.p(0, 0))   
        end
        
        if self.actions[EnumActions.Idle] then
            avatar:runAction(self.actions[EnumActions.Idle])
            self.state = EnumHeroState.Idle
        end
    end   
end

function Hero:DelayIdle(delayTime)
    local function delayIdle()
        self:Idle()
    end
    if delayTime > 0 then
        local action = cc.Sequence:create(cc.DelayTime:create(delayTime), 
            cc.CallFunc:create(delayIdle))
        self:runAction(action)
    else
        self:Idle()
    end
end

function Hero:Walk()
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    local avatar = avatar2d
    
    if avatar2d then
        if self.state == EnumHeroState.Attack then
             avatar2d:setPosition(cc.p(0, 0))   
        end
        
        avatar:stopActionByTag(EnumActionTag.State2D)
        avatar:runAction(self.actions[EnumActions.Walk])
        self.state = EnumHeroState.Walk
    end    
end

function Hero:Jump()
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    local avatar = avatar2d
    if avatar2d and self.actions[EnumActions.Jump] then
        if self.state == EnumHeroState.Attack then
             avatar2d:setPosition(cc.p(0, 0))   
        end
        
        avatar:stopActionByTag(EnumActionTag.State2D)
        avatar:runAction(self.actions[EnumActions.Jump])
        self.state = EnumHeroState.Walk
    end    
end

function Hero:Back()
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    local avatar = avatar2d
    if avatar2d and self.actions[EnumActions.Back] then
        if self.state == EnumHeroState.Attack then
             avatar2d:setPosition(cc.p(0, 0))   
        end
        
        avatar:stopActionByTag(EnumActionTag.State2D)
        avatar:runAction(self.actions[EnumActions.Back])
        self.state = EnumHeroState.Walk
    end    
end

function Hero:Attack(actionName,suffer,packet)
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    local avatar = avatar2d
    local skillInfo = TableSkill[packet.skill]
    local function AttackEnd(sender, extra)
        if self.avatid == 1001 and packet.skill == 2011 then
            print("AttackEnd",self:getPositionY())
        end
        if not self.isDead then--self.hp > 0 then
            avatar:setPosition(extra[1])
            if suffer and packet and packet.atks then
                self:Attack(actionName,suffer,packet)
            else 
                local btick = false
                if MgrCameraInfo.bUsingSkill and MgrCameraInfo.SkillAcker == self.id then
                    MgrCameraInfo.bUsingSkill = false
                    MgrCameraInfo.SkillAcker = 0
                    MgrCameraInfo.SkillSuffer = 0
                    btick = true
                end
                if MgrCameraInfo.bFlyingAtk and MgrCameraInfo.FlyAcker == self.id then
                    MgrCameraInfo.bFlyingAtk = false
                    MgrCameraInfo.FlyAcker = 0
                    MgrCameraInfo.FlySuffer = 0
                    btick = true
                end
                if btick then
                    cc.Director:getInstance():getRunningScene():cameraTick()
                end
                self:Idle()
            end
        end                
    end

    if avatar2d then
        avatar:stopActionByTag(EnumActionTag.State2D)       
        local action = self.actions[EnumActions[actionName]]    

        local function AttackBegin()
            if self.avatid == 1001 and packet.skill == 2011 then
                print("AttackBegin",self:getPositionY())
            end            
            if avatar:getScaleX() < 0 then
                avatar:setPosition(cc.p(-action.offset.x, action.offset.y)) 
            else
                avatar:setPosition(action.offset)
            end
        end

         if suffer and packet then
            local damage = packet.atks[1]
            table.remove(packet.atks,1)
            if self.avatid == 1003 then
                suffer:DelayHit(0.3,damage,packet)
            else
                suffer:DelayHit(0.1,damage,packet)
            end
            if packet.fly then
                suffer:Fly(packet)                
            end
            if skillInfo.AtkFly then      
                local se = cc.Sequence:create(action, cc.CallFunc:create(function () end))
                avatar:runAction(se)
                
                local selfY = self:getPositionY()
                local targetY = suffer:getPositionY()
                local dis
                if targetY + 200 > 450 then
                    dis = 450 - selfY
                else
                    dis = targetY + 200 - selfY
                end
                --local dis = 200
                --if self:getPositionY() + 200 > 400 then
                --        dis = 400 - self:getPositionY() 
                --end
                print("atk fly",dis)                 
                local function AtkFlyBackJump()
                    self:runAction(cc.Spawn:create(
                            cc.EaseSineOut:create(cc.MoveBy:create(0.7, cc.p(-70, 0))),
                            cc.EaseExponentialOut:create(cc.MoveBy:create(0.4, cc.p(0, 20)))))
                end
                se = cc.Sequence:create({cc.CallFunc:create(AttackBegin), 
                    cc.Spawn:create(cc.EaseExponentialOut:create(cc.MoveBy:create(0.6,cc.p(0,dis))), 
                        cc.Sequence:create({cc.DelayTime:create(0.4), cc.CallFunc:create(AttackEnd,{cc.p(0, 0)}),
                            cc.CallFunc:create(AtkFlyBackJump)}))})
                
                se:setTag(EnumActionTag.State2D)
                self:runAction(se)
                self.state = EnumHeroState.Attack
                packet.atks = nil
                MgrCameraInfo.bFlyingAtk = true
                MgrCameraInfo.FlyAcker = packet.atker
                MgrCameraInfo.FlySuffer = packet.suffer
                cc.Director:getInstance():getRunningScene():cameraTick()
                return
            end
            cc.Director:getInstance():getRunningScene():cameraTick()
            if #packet.atks == 0 then
                packet.atks = nil
            end
        end       
        
        local se = cc.Sequence:create({cc.Spawn:create(action, cc.CallFunc:create(AttackBegin)), cc.CallFunc:create(AttackEnd,{cc.p(0, 0)})})
        se:setTag(EnumActionTag.State2D)
        avatar:runAction(se)
        self.state = EnumHeroState.Attack
    end
end

function Hero:Hit(hpchandge,addCombo)
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    local avatar = avatar2d

    if avatar2d then
        if self.state == EnumHeroState.Idle or 
            self.state == EnumHeroState.Hit or
            self.state == EnumHeroState.Fly then
            avatar:stopActionByTag(EnumActionTag.State2D)        
            local function HitEnd()
                --self:Idle()         
            end
            
            local action = self.actions[EnumActions.Hit]        
            local se = cc.Sequence:create(action, cc.CallFunc:create(HitEnd,{}))
            se:setTag(EnumActionTag.State2D)
            avatar:runAction(se)
            --self.state = EnumHeroState.Hit 
        end

        if self:getPositionY() > self.baseY then
            local se = cc.Sequence:create(cc.MoveBy:create(0.05, cc.p(0, 12)),
                cc.MoveBy:create(0.05, cc.p(0, -12)))
            self:runAction(se)
        end

        if hpchandge then
            local hp = tostring(-hpchandge)
            local label = cc.Label:createWithBMFont("fonts/hurt.fnt", hp,
                cc.TEXT_ALIGNMENT_CENTER, 0, {x = 0, y = 0})
            label:setPosition({x = 0, y = 160})

            local acScaleMax = cc.ScaleTo:create(0.1, 1.5)
            local acScaleMin = cc.ScaleTo:create(0.3, 1)
            local acScale = cc.Sequence:create(acScaleMax, 
                cc.DelayTime:create(0.2), acScaleMin)
            self.hp = self.hp - hpchandge                    
            local ac = cc.Sequence:create{cc.Spawn:create(
                cc.EaseSineOut:create(cc.MoveBy:create(0.2, {x = 0, y = 30})), acScale), 
                --cc.CallFunc:create(death),
            cc.RemoveSelf:create()}

            label:runAction(ac) 
            self:addChild(label)
        end
    end

    if addCombo then
        cambo = cambo or {lasttime = 0, counts = 0}
        if hpchandge then
            local curTime = GetSysTick()
            if curTime - cambo.lasttime > 1200 then
                cambo.counts = 1
            else
                cambo.counts = cambo.counts + 1
            end
            cambo.lasttime = curTime

            local hud = cc.Director:getInstance():getRunningScene().hud
            local ui = hud:getUI("UIFight")
            if ui then
                ui:ShowCambo(cambo.counts)
            end
        end
    end
end

function Hero:DelayHit(delayTime, hpchandge,packet)
    local addCombo = not packet.normal_skill
    local function delayHit(sender, extra)
        if packet then
            local function onWalkEnd()
                    self:Hit(extra[1],addCombo)
            end             
            if packet.backpos then
                local posX = self:getPositionX()
                local diffX = packet.backpos - posX
                local walkTime = math.abs(diffX*0.3)*0.1
                local moveAc = cc.MoveBy:create(walkTime, cc.p(diffX, 0))                                         
                self:runAction(cc.Sequence:create({moveAc, cc.CallFunc:create(onWalkEnd), cc.CallFunc:create(function() end)}))
            elseif not packet.normal_skill then
                local moveAc = cc.MoveBy:create(0.1, cc.p(math.random(5,10), 0))                                       
                self:runAction(cc.Sequence:create({moveAc, cc.CallFunc:create(onWalkEnd), cc.CallFunc:create(function() end)}))                
            else
                  self:Hit(extra[1],addCombo)          
            end
        else
            self:Hit(extra[1],addCombo)
        end
    end
    if delayTime > 0 then
        local action = cc.Sequence:create(cc.DelayTime:create(delayTime), 
            cc.CallFunc:create(delayHit, {hpchandge}))
        self:runAction(action)
    else
        self:Hit(hpchandge,addCombo)
    end
end

function Hero:Fly(packet)
    local ava = self
        
    local function onFlyEnd()
        ava.flyAction = nil
        ava:setLocalZOrder(EnumZOrder.mapMask+1)--640-ava:getPositionY())  
    end

    if self.actionFall then
        self:stopAction(self.actionFall)
        self.actionFall = nil
    end

    local dis = 160
    if self:getPositionY() + 160 > 420 then
            dis = 420 - self:getPositionY() 
    end 
    local ac = cc.MoveBy:create(0.8, cc.p(0, dis))
    --self:runAction(cc.Sequence:create(cc.EaseOut:create(ac, 2), cc.CallFunc:create(onFlyEnd)))   
    self:stopActionByTag(EnumActionTag.State2D) 

    self.flyAction = cc.Sequence:create(cc.EaseExponentialOut:create(ac), cc.CallFunc:create(onFlyEnd))
    self:runAction(self.flyAction)

end



function Hero:Fall()
    local ava = self
    local function onFlyEnd()
        --if self.avatid == 1001 then
        --    print("Fall onFlyEnd",self:getPositionY())
        --end        
        self:Idle()
        self:setLocalZOrder(640-self:getPositionY())
    end
    if self.teamid == 2 then
        print("Fall",self:getPositionY())
    end    
    local time
    if self.avatid == 1001 then
        time = 0.4
    elseif self.avatid == 1002 then
        time = 0.6
    else
        time = 1.2
    end
    --self.teamid == 1 and 0.4 or 1.2
    --local rand = math.random(-5,5) 
    local ac = cc.MoveTo:create(time, cc.p(self:getPositionX(),self.baseY))
    self.actionFall = cc.Sequence:create(cc.EaseExponentialIn:create(ac), cc.CallFunc:create(onFlyEnd)) 
    self:runAction(self.actionFall)   
end

function Hero:Death()
    if self.isDead then
        return
    end 
    self.isDead = true 
    if self.teamid == 1 then
        local hud = cc.Director:getInstance():getRunningScene().hud
        local ui = hud:getUI("UIFight")
        if ui then
            print("ui:onHeroDead")
            ui:onHeroDead(self.id)
        end
    end
    self.state = EnumHeroState.Dead
    local avatar2d = self:getChildByTag(EnumAvatar.Tag2D)
    if avatar2d and self.actions[EnumActions.Death] then
        avatar2d:stopActionByTag(EnumActionTag.State2D)
        avatar2d:runAction(self.actions[EnumActions.Death])
    end      

    if self:getPositionY() > self.baseY then
        local ac = cc.MoveTo:create(0.8, cc.p(self:getPositionX(),self.baseY))
        local action = cc.Sequence:create(cc.EaseExponentialIn:create(ac),cc.DelayTime:create(1.5),
            cc.CallFunc:create(
            function ()
                MgrPlayer[self.id] = nil
                self:removeFromParent()                
            end
            ))
        self:runAction(action)       
    else
        local action = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ()
            MgrPlayer[self.id] = nil
            self:removeFromParent()            
            end))
        self:runAction(action)  
    end  
end

function Hero:WalkTo(packet, walkcb)
    local posX = self:getPositionX()
    local cellWidth = MgrConfig.cellWidth
    local cellIdx = math.ceil(posX/cellWidth)
    local walkTime = math.abs((packet.posx - posX)/360)
    if packet.mov_type and (packet.mov_type == 2 or packet.mov_type == 3) then
        walkTime = walkTime * 0.2
    elseif packet.mov_type and packet.mov_type == 4 then
        walkTime = walkTime * 0.6
    end
    
    local moveAc = cc.MoveBy:create(walkTime, cc.p(packet.posx - posX, 0))
    local function onWalkEnd()
        self.movAction = nil
        self:Idle()
    end
    if not walkcb then
        walkcb = function() end
    end
    if self.movAction then
        self:stopAction(self.movAction)
    end
    self.movAction = cc.Sequence:create({moveAc, cc.CallFunc:create(onWalkEnd), cc.CallFunc:create(walkcb)})
    self:runAction(self.movAction)
    if packet.mov_type and (packet.mov_type == 2 or packet.mov_type == 3) then
        if packet.mov_type == 2 then
            self:Back()
        elseif packet.mov_type == 3 then
            self:Jump()
        end
    elseif packet.mov_type and (packet.mov_type == 1 or packet.mov_type == 4) then
        self:Walk()
    end

    return walkTime
end

function Hero:SetAvatarName(strName)
    if not self.lblName then
        local label = cc.Label:create()
        label:setSystemFontSize(20)
        label:setPosition(0, 20)    
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setColor(cc.c3b(0,0,0))
        self:addChild(label)            
        self.lblName = label
    end
    self.lblName:setString(strName)    
end 

function Hero:init2DAvatar(modelID)
    local model = TableModel[modelID]
    --[[
    local pathlen = string.len(model.Resource_Path)
    local img = string.sub(model.Resource_Path, 1, pathlen - 5)]]
    local avatar = cc.Sprite:create()
    --[[
    cc.SpriteFrameCache:getInstance():addSpriteFrames(model.Resource_Path, 
            img.."png")
            ]]
    if model.Standby and model.Standby > 0 then
        local action = self:createAction(model.Standby)
        self.actions[EnumActions.Idle] = cc.RepeatForever:create(action)
        self.actions[EnumActions.Idle]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Idle]:retain()
    end
    
    if model.Attack1 and model.Attack1 > 0 then
        self.actions[EnumActions.Attack1] = self:createAction(model.Attack1)        
        self.actions[EnumActions.Attack1]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Attack1]:retain()
    end
    
    if model.Walk and model.Walk > 0 then
        local action = self:createAction(model.Walk)
        self.actions[EnumActions.Walk] = cc.RepeatForever:create(action)
        self.actions[EnumActions.Walk]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Walk]:retain()
    end
    
    for i = EnumActions.Skill1, EnumActions.Skill5 do
        local  idxName = GetEnumName(EnumActions, i)

        if nil ~= model[idxName] then
            self.actions[i] = self:createAction(model[idxName])
            self.actions[i]:setTag(EnumActionTag.State2D)
            self.actions[i]:retain()
        end
    end
    
    if model.Hit and model.Hit > 0 then
        self.actions[EnumActions.Hit] = self:createAction(model.Hit)
        self.actions[EnumActions.Hit]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Hit]:retain()
    end
    
    if model.Death and model.Death > 0 then
        self.actions[EnumActions.Death] = self:createAction(model.Death)
        self.actions[EnumActions.Death]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Death]:retain()
    end

    if model.Jump and model.Jump > 0 then
        local action = self:createAction(model.Jump)
        self.actions[EnumActions.Jump] = cc.RepeatForever:create(action)
        self.actions[EnumActions.Jump]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Jump]:retain()
    end

    if model.Back and model.Back > 0 then
        local action = self:createAction(model.Back)
        self.actions[EnumActions.Back] = cc.RepeatForever:create(action)
        self.actions[EnumActions.Back]:setTag(EnumActionTag.State2D)
        self.actions[EnumActions.Back]:retain()
    end

    return avatar
end

return Hero