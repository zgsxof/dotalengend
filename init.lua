require("cocos.init")
require("frameworkConfig")
require("config")
require("framework.init")
require("lfs")
cjson = require('cjson').new()

require("messagehandler.opcodes")
require("util")
require("functions")
require("ObjectDefine")

sGameMgr = require("GameMgr").getInstance() --GameMgr:getInstance()
ObjectMgr = require("ObjectMgr"):getInstance()
sObjectInfoMgr = require("ObjectInfoMgr"):getInstance()
sCallbackMgr = require("callbackMgr"):getInstance()
sCPlusObjectAccessor = CObjectAccessor:getInstance()
sSceneMgr = require("SceneMgr"):getInstance()
sBattleProxy = require("demo.BattleProxy").new()

--require("opcodes")
sharedFileUtils:setPopupNotify(false)

sharedFileUtils:addSearchPath("res")
sharedFileUtils:addSearchPath("res/test")
sharedFileUtils:addSearchPath("res/armatures")
sharedFileUtils:addSearchPath("res/effect")
sharedFileUtils:addSearchPath("res/image")
sharedFileUtils:addSearchPath("res/ui")
sharedFileUtils:addSearchPath("res/shaders")
sharedFileUtils:addSearchPath("res/uitest")
--[[
sharedDirector:getOpenGLView():setFrameSize(config.width,config.height)
sharedDirector:getOpenGLView():setDesignResolutionSize(config.designWidth,config.designHeight,config.policy)
]]
--sharedDirector:setDisplayStats(config.fps)
--sharedDirector:setAnimationInterval(1.0/config.interval)
cc.init()

require("dbc.DbcStruture")
require("dbc.DbcInit")

LoadItemIntensify()



