local IndexLayer = class("IndexLayer",
	function()
		local layer = ccui.loadLayer("ui/Index")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

IndexLayer._loginLayer = nil
IndexLayer._regLayer = nil

function IndexLayer:onEnter()
	self.registerSucces = false 
	if DEBUG then 
		local macAddress = PlatformUtility:GetDeviceMacAddress()
		cclog(macAddress)
	end

	self._enterGameBtn = self:getChild("Image_Enter")
    self._enterGameBtn:setTouchEnabled(true)
    self._enterGameBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.wayToEnter)})
    
    self._logoutBtn = self:getChild("Button_LoginOut")
    self._logoutBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.LogoutCallback)})
    
    self._loginBtn = self:getChild("Button_Login") 
    self._loginBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.showLoginCallback)})
    
    self._username = self:getChild("Label_Username")
    self._username:setString(PlatformUtility:getAccount())

    local scale = self._enterGameBtn:getScale()
    local action = cc.Sequence:create(cc.ScaleTo:create(0.7,0.8*scale),cc.ScaleTo:create(0.7,scale))
    self._enterGameBtn:runAction(cc.RepeatForever:create(action))

    local nameStr = self:getChild("Label_Username")  
    nameStr:setString(PlatformUtility:getAccount())
    if nameStr:getString() ~= "" then 
    	self._logoutBtn:setVisible(true)
    	self._logoutBtn:setTouchEnabled(true)
    	self._loginBtn:setVisible(false)
    	self._loginBtn:setTouchEnabled(false)
    	--textFrame:setVisible(true)
    else
    	self._logoutBtn:setVisible(false)
    	self._logoutBtn:setTouchEnabled(false)
    	self._loginBtn:setVisible(true)
    	self._loginBtn:setTouchEnabled(true)
    	--textFrame:setVisible(false)
    end

    self:AutoScale()
end

function IndexLayer:AutoScale( )
	local panel = self:getChild("Panel_Login_Reg")
	for i = 1,panel:getChildrenCount() do
		 local child = panel:getChildren()[i]
		 if child:getName() == "Image_bg" then
		 	display.autoscale(child)
		 else
		 	display.ccp(child)
		 end
	end
	--display.autoscale(self:getChild("Image_bg"))
end

function IndexLayer:AnonymloginCallback()
	local AnonymAccount = PlatformUtility:getAnonymAccount()
	if AnonymAccount ~= "" then
		if string.sub(AnonymAccount,1,8) == "UBERAUTO" then 
			local psw = "000000"
		    network.SetUserNameAndPassWord(AnonymAccount,psw)
			local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		    send_packet:setStr("zhCN")
			send_packet:setStr(AnonymAccount)
			--send_packet:setStr("000000")
			network.send(send_packet)
			createFunnelLayer()
			cclog("AnonymAccount detected,Login")
		else
			PlatformUtility:setAnonymAccount("")
			cclog("匿名帐号被篡改，清空")
            return
		end
	else
		local send_packet = WorldPacket:new(CMD_CREATE_ANONYMOUS_ACCOUNT,60)
		if cc.platform == "windows" then
			local macAddress = PlatformUtility:GetDeviceMacAddress()
			send_packet:setStr(macAddress)
		else
			local ifa = PlatformUtility:GetDeviceIdentify()
			send_packet:setStr(ifa)
		end
		network.send(send_packet)	
	end
end

function IndexLayer:DirectloginCallback()
	local nameStr = PlatformUtility:getAccount()
    local pswStr = PlatformUtility:getPassword()
    if nameStr == "" then return end

	ACCOUNT = nameStr
	network.SetUserNameAndPassWord(nameStr,pswStr)
	local AnonymAccount = PlatformUtility:getAnonymAccount()
	if AnonymAccount == "" then 
		local send_packet = WorldPacket:new(CMD_CREATE_ANONYMOUS_ACCOUNT,60)
		if cc.platform == "windows" then
			local macAddress = PlatformUtility:GetDeviceMacAddress()
			send_packet:setStr(macAddress)
		else
			local ifa = PlatformUtility:GetDeviceIdentify()
			send_packet:setStr(ifa)
		end
		network.send(send_packet)
		createFunnelLayer()
	else
		local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		send_packet:setStr("zhCN")
		send_packet:setStr(nameStr)
		network.send(send_packet)
		createFunnelLayer()
	end	
end

function IndexLayer:wayToEnter()
	--[[
	local nameStr = self:getChild("Label_Username")
	if nameStr:getString() == "" then
		self:AnonymloginCallback()
	else
		self:DirectloginCallback()
	end]]
	sGameMgr:EnterScene(GameState.MAIN)
end

function IndexLayer:LogoutCallback() 
	local nameStr = self:getChild("Label_Username")
    local btnLogin = self:getChild("Button_Login")
	local btnLoginout = self:getChild("Button_LoginOut")
	local textFrame = self:getChild("Image_3_0_1_0")
	local btnEnter = self:getChild("Image_Enter")
	if nameStr:getString() ~= "" then
		PlatformUtility:setAccount("")
        PlatformUtility:setPassword("")
		nameStr:setString("")
		btnLoginout:setVisible(false)
    	btnLoginout:setTouchEnabled(false)
    	btnLogin:setVisible(true)
    	btnLogin:setTouchEnabled(true)
    	textFrame:setVisible(false)
	end
end

function IndexLayer:showLoginCallback()
	if not self._loginLayer then
		self._loginLayer = require("UI.Login").new()
		self:addChild(self._loginLayer)
	else
		self._loginLayer:setVisible(true)
	end
end

function IndexLayer:ShowRegister( ... )
	self._loginLayer:setVisible(false)

	if not self._regLayer then
		self._regLayer = require("UI.Register").new()
		self:addChild(self._regLayer)
	else
		self._regLayer:setVisible(true)
	end
end


return IndexLayer