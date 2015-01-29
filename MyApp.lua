local MyApp = class("MyApp", cc.AppBase)
MyApp.__index = MyApp



function MyApp:ctor()
	MyApp.super.ctor(self)
	--[[
    local scene = require("StartEngineScene").new()
    cc.runScene(scene)]]
    --[[local scene = require("UI.CheckVerScene").new()
	cc.runScene(scene)
	]]
    sGameMgr:EnterScene(GameState.LOGIN)
end

function MyApp:onEnterBackground()
	cclog("onEnterBackground")
	--network.shutdown()
end

function MyApp:onEnterForeground()
	cclog("onEnterForeground")
	--network.reConnect()
end

return MyApp