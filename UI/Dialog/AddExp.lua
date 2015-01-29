local AddExp = class("AddExp",
	function (  )
		local layer = ccui.loadLayer("ui/AddExp")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function AddExp:ctor( guid )
	self._playerGuid = guid

	self._cancelBtn = self:getChild("Button_Cancel")
	self._cancelBtn:setTouchEnabled(true)
	self._cancelBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.CancelCallback)})

	
	self._okBtn = self:getChild("Button_OK")
	self._okBtn:setTouchEnabled(true)
	self._okBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.OkCallback)})

	cclog("textfield type:")
	cclog(tolua.type(self:getChild("TextField_8")))
end

function AddExp:OkCallback( )
	local exp = self:getChild("TextField_8"):getString()
	if checknumber(exp) ~= 0 then
		local packet = WorldPacket:new(CMSG_GAME_ASSIGN_EXP,60)
		packet:setU32(self._playerGuid)
		packet:setU32(checknumber(exp))
	   	network.send(packet)

	   	self:removeFromParent()
	else
		sGameMgr:ShowInfo("输入有误，请重新输入")
	end
end

function AddExp:CancelCallback( ... )
	self:removeFromParent()
end

return AddExp