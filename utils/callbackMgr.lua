local CallbackMgr = class("CallbackMgr")
CallbackMgr.__index = CallbackMgr

local __instance = nil
local __allowInstance = nil

function CallbackMgr:ctor(  )
	if not __allowInstance then
		error("CallbackMgr is a singleton")
	end

	self:init()
end

function CallbackMgr:init(  )

end

function CallbackMgr:getInstance(  )
	if not __instance then
		__allowInstance = true
		__instance = CallbackMgr.new()
		__allowInstance = false
	end

	return __instance
end

function CallbackMgr:CreateMsgBox( msgContext, okCallback, bOK, cancelCallback, bCancel )
	local scene = sharedDirector:getRunningScene()
	if scene then
		scene:removeChildByTag(3333, true)
		local msgBox = require("UI.MsgBox").new(msgContext, okCallback, bOK, cancelCallback, bCancel )

		if msgBox then
			scene:addChild(msgBox, 100000, 3333)
			return true
		else
			return false
		end
	else
		return false
	end
end

function CallbackMgr:RemoveMsgBox(  )
	local scene = sharedDirector:getRunningScene()
	if scene then
		scene:removeChildByTag(3333, true)
	end
end

network.onNeedReConnect = function()
    sCallbackMgr:CreateMsgBox("无法连接网络，点击重试",sCallbackMgr.onReConnect)
end

function CallbackMgr:onReConnect()
	cclog("network.reConnect()")
	if not network.state then
		cclog("未连接登陆服务器,将再次尝试连接登录服务器")
		network.ConnectLoginServer(network.loginAddress)
        local packet = WorldPacket:new(CMD_DETECT_CLIENT,4)
        packet:setU32(verCode.ver)
        network.send(packet)
	else
		self:RemoveMsgBox()
		network.reConnect()
	end
end

return CallbackMgr