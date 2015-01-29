require("cocos.init")
require("config")
require("framework.init")
require("lfs")
cjson = require('cjson').new()

require("messagehandler.opcodes")
require("utils.util")
require("utils.functions")
require("utils.ObjectDefine")

sGameMgr = require("utils.GameMgr").getInstance() --GameMgr:getInstance()
ObjectMgr = require("utils.ObjectMgr"):getInstance()
sObjectInfoMgr = require("utils.ObjectInfoMgr"):getInstance()
sCallbackMgr = require("utils.callbackMgr"):getInstance()
sCPlusObjectAccessor = CObjectAccessor:getInstance()
sSceneMgr = require("utils.SceneMgr"):getInstance()
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



