local GameMgr = class("GameMgr")
GameMgr.__index = GameMgr

GameState = 
{
	LOGO	= 1,
	LOGIN	= 2,
	MAIN	= 3,
	BATTLE	= 4,
}

local __instance = nil
local __allowInstance = nil

function GameMgr:ctor( )
	if not __allowInstance then
		error("GameMgr is a singleton")
	end

	self:init()
end

function GameMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = GameMgr.new()
		__allowInstance = false
	end

	return __instance
end

function GameMgr:init( )
	
end

function GameMgr:checkVer()
    --local sceneGame = cc.Scene:create()
	--sharedDirector:replaceScene(sceneGame)
	cclog("-----connect login server")
	--createFunnelLayer()
	network.loginAddress = "192.168.1.147:3800"
	--local loginAddr = "192.168.1.147:3800"
	network.ConnectLoginServer(network.loginAddress)
    local packet = WorldPacket:new(CMD_DETECT_CLIENT,4)
    packet:setU32(1)
    network.send(packet)
end

local function enterLogin()
	--local sceneGame = cc.Scene:create()
	local sceneGame = display.newScene()
    local loginLayer = require("UI.IndexLayer").new()
    sceneGame:addChild(loginLayer,0,10086)
    sharedDirector:replaceScene(sceneGame)
end

local function enterMain( )
	local sceneGame = cc.Scene:create()
	local mainLayer = require("UI.MainLayer").new()
	sceneGame:addChild(mainLayer,0,10086)
	sharedDirector:replaceScene(sceneGame)
	--[[
local battleLayer = require("UI.BattleLayer").new()
sceneGame:addChild(battleLayer,0,10086)
sharedDirector:replaceScene(sceneGame)]]
end

local function entertest( ... )
	local sceneGame = cc.Scene:create()
    --local loginLayer = require("UI.testui").new()
    local loginLayer = require("UI.testui").new()
    sceneGame:addChild(loginLayer)
    cc.runScene(sceneGame)
end

function GameMgr:EnterScene(state)
	assert(state)

	if state == GameState.LOGIN then
		self.state = GameState.LOGIN

		enterLogin()
	elseif state == GameState.MAIN then
		self.state = GameState.MAIN
		enterMain()
	elseif state == GameState.BATTLE then
		self.state = GameState.BATTLE
		self:enterBattle()
	else
		assert(false,string.format("non definded state:%d",state))
	end
end

function GameMgr:ShowInfo( context )
	local layer = sharedDirector:getRunningScene():getChildByTag(10086)
	if layer then
		local label = ccui.label({text=context,fontSize=30,color=cc.c3b(255,0,0)})
		label:pos(cc.CENTER)
		label:setScale(10)
		local scaleAction = cc.ScaleTo:create(0.08,1)
		local fadeAction = cc.FadeOut:create(2.5)
		label:runAction(cc.Sequence:create(scaleAction,fadeAction,cc.CallFunc:create(function ()
			label:removeFromParent()
		end)))
		layer:addChild(label,100000)
	end
end


return GameMgr