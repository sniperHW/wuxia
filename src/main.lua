
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
--cc.FileUtils:getInstance():addSearchPath("lua")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"

require "src.net.ParseSC"
require "src/net/Client2Server"

require "math"
require "src.table.TableModel"
require "src.table.TableAvatar"
require "src.table.TableAction"
require "src.table.TableMap"
require "src.table.TableSkill"
require "src.table.TableImpack"
require "src.Enum"
require "src.CommonFun"

math.randomseed(tostring(os.time()):reverse():sub(1, 6))  

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

DesignSize = {width = 960, height = 640}
BeginTime = {localtime = GetSysTick(), servertime = 0} 
local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    if MgrRuning then
        return
    end
    MgrRuning = true
    --[[
    local userData = cc.UserDefault:getInstance()
    MgrSetting.bPlayMusic = userData:getBoolForKey("bPlayMusic", true)
    MgrSetting.bPlayEffect = userData:getBoolForKey("bPlayEffect", true)
    ]]
    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    director:setDisplayStats(false)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
    
    local glView = cc.Director:getInstance():getOpenGLView() 
    glView:setDesignResolutionSize(960, 640, cc.ResolutionPolicy.FIXED_HEIGHT)
    
    --create scene 
    Lang = require "LangCh"
    local scene = require("SceneLogin")
    --local scene = require("SceneLoading")
    --local scene = require("TestScene")
    --local scene = require("TestBattleScene")
    local gameScene = scene.create()
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    
    --[[
    local loadImages = {}
    local tableEff = TableSpecial_Effects 
    for _, value in pairs(tableEff) do
        local path = "effect/"..value.Resource_Path..".png"
        table.insert(loadImages, path)
    end
    
    local totalCount = #loadImages
    local function onLoad()
        if #loadImages > 0 then
            local image = loadImages[1]
            table.remove(loadImages, 1)
            local cache = cc.Director:getInstance():getTextureCache()
            cache:addImageAsync(image, onLoad) 
        end
    end
    onLoad()
    ]]
    

    local function onKeyDown(keyCode, event)
        if keyCode == cc.KeyCode.KEY_R then
            TableModel = nil
            TableAvatar = nil
            TableAction = nil
            
            package.loaded["src.table.TableAvatar"] = false
            package.loaded["src.table.TableAction"] = false            
            package.loaded["src.table.TableModel"] = false
            require "src.table.TableModel"
            require "src.table.TableAction"
            require "src.table.TableModel"
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyDown, cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
