local RegisterLayer = class("RegisterLayer",
	function()
		local layer = ccui.loadLayer("ui/Register")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function RegisterLayer:ctor( )
	local backBtn = self:getChild("R_Button_Back")
	backBtn:setTouchEnabled(true)
	backBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.BackCallback)})

	local RegBtn = self:getChild("R_Register")
	RegBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.RegisterCallback)})
end

function RegisterLayer:BackCallback( ... )
	self:setVisible(false)
end

local function CheckName( nameStr )
	if nameStr == "" or nameStr == nil then
		sGameMgr:ShowInfo("The name cannot be nil.")
		return false
	end

	if string.sub(nameStr,1,1) < "a"  or string.sub(nameStr,1,1) >"z" then
		if string.sub(nameStr,1,1) < "A"  or string.sub(nameStr,1,1) >"Z" then 
            sGameMgr:ShowInfo("The head character of name is not allowed.")
			return false
	    end
	end

	for k = 2,string.len(nameStr) do
		if string.sub(nameStr,k,k) == nil then 
			break 
		elseif string.sub(nameStr,k,k) < "a" or string.sub(nameStr,k,k) > "z" then 
	        if string.sub(nameStr,k,k) < "A" or string.sub(nameStr,k,k) > "Z" then 
		        if string.sub(nameStr,k,k) < "0" or string.sub(nameStr,k,k) > "9" then  
                 -- cclog("The name contains characters are not allowed: " .. string.sub(nameStr,k,k) .. " .")
                 sGameMgr:ShowInfo("The name contains characters are not allowed: " .. string.sub(nameStr,k,k) .. " .")
                 return false
                end
            end
        end     
	end

	return true
end

local function CheckPassword( pswStr, pswStr2)
	if pswStr ~= pswStr2 then
		cclog("Please input the same password.")
		sGameMgr:ShowInfo("Please input the same password.")
		return false
	end

	if pswStr == "" and pswStr2 == "" then
		cclog("Please input a correct password.")
		sGameMgr:ShowInfo("Please input a correct password.")
		return false
	end

	if string.len(pswStr) < 6 or string.len(pswStr) > 16 then
		cclog("Please input a correct password.")
		sGameMgr:ShowInfo("Please input a correct password.")
		return false
	end 

	for k = 1,string.len(pswStr) do
		if string.sub(pswStr,k,k) == nil then 
			break 
		elseif string.sub(pswStr,k,k) < "a" or string.sub(pswStr,k,k) > "z" then 
	        if string.sub(pswStr,k,k) < "A" or string.sub(pswStr,k,k) > "Z" then 
		        if string.sub(pswStr,k,k) < "0" or string.sub(pswStr,k,k) > "9" then  
                 cclog("The password contains a character: " .. string.sub(pswStr,k,k) .. ". ")
                 sGameMgr:ShowInfo("The password contains a character: " .. string.sub(pswStr,k,k) .. ". ")
                 return false
                end
            end
        end     
	end

	return true
end

function RegisterLayer:RegisterCallback()
	local nameStr = self:getChild("R_Text_Name"):getString()
	local pswStr = self:getChild("R_Text_Password1"):getString()
	local pswStr2 = self:getChild("R_Text_Password2"):getString()
	local nameRenderer = tolua.cast(self:getChild("R_Text_Name"):getVirtualRenderer(),"UICCTextField")

	-- 可能C++没有开放UICCTextField::getCharCount()给lua使用
	--if nameRenderer:getCharCount() < 4 or nameRenderer:getCharCount() > 16 then
	if string.len(nameRenderer) < 4 or string.len(nameRenderer) > 16 then
		sGameMgr:ShowInfo("The length of the name is not enough.")
		return
	end

	if CheckName(nameStr) and CheckPassword(pswStr,pswStr2) then
		self.nameStr = nameStr
		self.pswStr  = pswStr

		PlatformUtility:setAccount(nameStr)
		PlatformUtility:setPassword(pswStr)
		
		network.SetUserNameAndPassWord(nameStr,pswStr)
		network.SendSignInPacket()

		createFunnelLayer()
	end
end

return RegisterLayer