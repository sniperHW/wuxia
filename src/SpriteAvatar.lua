local SpriteAvatar = class("SpriteAvatar", function()
    return cc.Sprite:create()
end)

function SpriteAvatar.create(avatarid)
    --[[
    local pathlen = string.len(model.Resource_Path)
    local img = string.sub(model.Resource_Path, 1, pathlen - 5)]]
    local avatar = SpriteAvatar:new()
    avatar.avatid = avatarid
    
    local modelid = TableAvatar[avatarid].ModelID
	local model = TableModel[modelid]

    local resPath = model.Resource_Path    
	local cache = cc.SpriteFrameCache:getInstance()
	for _, path in pairs(resPath) do
        local img = string.sub(path, 1, string.len(path)- 5)
        cache:addSpriteFrames("char/"..path, "char/"..img.."pvr.ccz")
	end

    avatar:setScale(TableAvatar[avatarid].Scale)

    avatar.actions = {}
    --[[
    cc.SpriteFrameCache:getInstance():addSpriteFrames(model.Resource_Path, 
            img.."png")
            ]]
    if model.Standby and model.Standby > 0 then
        avatar.actions[EnumActions.Idle] = avatar:createAction(model.Standby, true)
        avatar.actions[EnumActions.Idle]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Idle]:retain()
    end
    
    if model.Attack1 and model.Attack1 > 0 then
        avatar.actions[EnumActions.Attack1] = avatar:createAction(model.Attack1)        
        avatar.actions[EnumActions.Attack1]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Attack1]:retain()
    end
    
    if model.Walk and model.Walk > 0 then
        avatar.actions[EnumActions.Walk] = avatar:createAction(model.Walk, true)
        avatar.actions[EnumActions.Walk]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Walk]:retain()
    end
    
    for i = EnumActions.Skill1, EnumActions.Skill5 do
        local  idxName = GetEnumName(EnumActions, i)
        if nil ~= model[idxName] then
            avatar.actions[i] = avatar:createAction(model[idxName])
            avatar.actions[i]:setTag(EnumActionTag.State2D)
            avatar.actions[i]:retain()
        end
    end
    
    if model.Hit and model.Hit > 0 then
        avatar.actions[EnumActions.Hit] = avatar:createAction(model.Hit)
        avatar.actions[EnumActions.Hit]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Hit]:retain()
    end
    
    if model.Death and model.Death > 0 then
        avatar.actions[EnumActions.Death] = avatar:createAction(model.Death)
        avatar.actions[EnumActions.Death]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Death]:retain()
    end

    if model.Jump and model.Jump > 0 then
        avatar.actions[EnumActions.Jump] = avatar:createAction(model.Jump, true)
        avatar.actions[EnumActions.Jump]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Jump]:retain()
    end

    if model.Back and model.Back > 0 then
        avatar.actions[EnumActions.Back] = avatar:createAction(model.Back, true)
        avatar.actions[EnumActions.Back]:setTag(EnumActionTag.State2D)
        avatar.actions[EnumActions.Back]:retain()
    end

    --avatar.state = EnumActions.Idle -- 初始待机
    return avatar
end

function SpriteAvatar:ctor()
	local function onNodeEvent(event)
        if "enter" == event then
            --self.avatar:Idle()
        elseif "exit" == event then
            for k, v in pairs(self.actions) do
                v:release()
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function SpriteAvatar:createAction(actionID, repeatforever)
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
    local action = cc.Animate:create(animation)
    if repeatforever then
        action = cc.RepeatForever:create(action)
    end
    action.anchor = tableAction.Anchor
    return action
end

function SpriteAvatar:RunAnimation(type)
    local action = self.actions[type]
	if action then
		if self.actiontype == type then
            return
        end
        self:stopAllActions()
        local function setAnchor()
            if action.anchor then
                local anchor = action.anchor
                if self:isFlippedX() then
                    self:setAnchorPoint(cc.p(1.0 - anchor.x, anchor.y))
                else
                    self:setAnchorPoint(anchor)
                end
            end
        end

        self:runAction(action)
        self:runAction(cc.CallFunc:create(setAnchor))
        self.actiontype = type
	end
end

return SpriteAvatar