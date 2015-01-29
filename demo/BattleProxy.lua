--local BattleProxy = class("BattleProxy", function() return cc.Scene:create() end)
local BattleProxy = class("BattleProxy")
BattleProxy.__index = BattleProxy

require("demo.SpellDefine")

BattleProxy._curMapId = 1003
BattleProxy._nextMapId = 1003

function BattleProxy:Reset()
	self._animationID = 0
end

sObjectAccessor = require("demo.ObjectAccessor").new()
sBattleMap = nil

require("demo.Util")

function BattleProxy:ctor()

end

function BattleProxy:BattleStart(sceneId,chapter)
	if not sBattleMap then
		sBattleMap = require("demo.BattleMap").new()
		--[[把battleLayer加到Mainlayer,因暂时需求把battleLayer当成主界面，此段代码暂时屏蔽
		local layer = require("UI.BattleLayer").new()
		local mainLayer = sharedDirector:getRunningScene():getChildByTag(10086)
		if not mainLayer then assert(false) end
		mainLayer:addChild(layer)
		sBattleMap:SetLayer(layer)]]
local battleLayer = sharedDirector:getRunningScene():getChildByTag(10086)
sBattleMap:SetLayer(battleLayer)
	end
	
	sBattleMap:Init()

end

return BattleProxy