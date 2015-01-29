CheckVerScene = class("CheckVerScene",function()
	local scene = cc.Scene:create()
	return scene
	end)
CheckVerScene.__index = CheckVerScene

function CheckVerScene:ctor()
	local handler = function(event)

        --------------------------进入场景----------------------
		if event == "enter" then
			self:onEnterScene()
        --------------------------退出场景----------------------
    	elseif event == "exit" then
        	--self:onExitScene()
        --------------------------清理场景----------------------
    	elseif event == "cleanup" then
      		self:unregisterScriptHandler()
        	--self:onCleanupScene()
    	end
    end

    self:registerScriptHandler(handler)
    ----------------------清理缓存的条目-------------------------
    sharedFileUtils:purgeCachedEntries()
end

function CheckVerScene:onEnterScene()
	if cc.platform ~= "windows" then
        --[[
        if DEBUG then
            network.loginAddress = "115.29.242.78:3830"
        else
            network.loginAddress = "115.29.242.78:3829"
        end]]
        network.loginAddress = "121.199.25.164:2700"
    else
        network.loginAddress = "192.168.1.147:3800"
    end
    network.loginAddress = "121.199.25.164:2700"
    cclog("login address:"..network.loginAddress)

	network.ConnectLoginServer(network.loginAddress)
    local packet = WorldPacket:new(CMD_DETECT_CLIENT,4)
    packet:setU32(verCode.ver)
    network.send(packet)
end

return CheckVerScene