local LoginLayer = class("LoginLayer",
	function()
		local layer = ccui.loadLayer("ui/Login")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function LoginLayer:ctor( )
	self._btnBack = self:getChild("L_Button_back")
	self._btnBack:setTouchEnabled(true)
	self._btnBack:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.BackCallback)})

	self._account = self:getChild("L_Text_Name")
	self._account:setString(PlatformUtility:getAccount())

	self._password = self:getChild("L_Text_Password") 
	if DEBUG then self._password:setString("123456") end

	self._regBtn = self:getChild("L_Register")
	self._regBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.ShowRegisterCallback)})

	self._loginBtn = self:getChild("L_Button_Login") 
	self._loginBtn:setTouchEnabled(true) 
	self._loginBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.loginCallback)})
end

function LoginLayer:BackCallback( )
	self:setVisible(false)
end

function LoginLayer:ShowRegisterCallback( )
	local parent = self:getParent()
	if parent then
		parent:ShowRegister()
	end
end

function LoginLayer:loginCallback( )
	local nameStr = self._account:getString()
	local pswStr = self._password:getString()
	local AnonymAccount = PlatformUtility:getAnonymAccount()

	if nameStr == "" then 
		sGameMgr:ShowInfo("The name cannot be nil.")
		return 
	end

	if pswStr == "" then 
		sGameMgr:ShowInfo("The password cannot be nil.")
		return 
	end

	PlatformUtility:setAccount(nameStr)
	PlatformUtility:setPassword(pswStr)
	network.SetUserNameAndPassWord(nameStr,pswStr)

	local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
	send_packet:setStr("zhCN")
	send_packet:setStr(nameStr)
	--send_packet:setStr("000000")
	network.send(send_packet)
	createFunnelLayer()
end

return LoginLayer