local CreateNameLayer = class("CreateNameLayer",
	function ()
		local layer = ccui.loadLayer("ui/CreateName")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function CreateNameLayer:ctor(  )
	local randomBtn = self:getChild("Button_random")
	randomBtn:setTouchEnabled(true)
	randomBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.RandomCallback)})

	local createBtn = self:getChild("Button_create")
	createBtn:setTouchEnabled(true)
	createBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.CreateCallback)})

	self._textName = self:getChild("L_Text_Name")
end

function CreateNameLayer:RandomCallback(  )
	-- 现在暂定从一张随机名字表里读取一个名字
	local name = GetRandomName()
	-- 之后再做发消息到服务器，请求随机名字

	self._textName:setString(name)
end

function CreateNameLayer:CreateCallback(  )
	-- 获取创建的名字后，发消息到服务器保存
	local name = self._textName:getString()
	if name then
		local send_packet = WorldPacket:new(CMSG_GAME_CHAR_CREATE,0)
		send_packet:setStr(name)
		network.send(send_packet)
	else
		--assert(false, "------ name is nil ------")
	end
end

return CreateNameLayer