local MsgBox = class("MsgBox",
	function (  )
		local layer = ccui.loadLayer("ui/MsgBox")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function MsgBox:ctor( msgContext, okCallback, bOK, cancelCallback, bCancel )
	if msgContext ~= nil then
		local contentLabel = self:getChild("Label_Content")
		contentLabel:setString(msgContext)
	end
	
	local panel = self:getChild("Panel_mgsbox")
	local singleOKBtn = self:getChild("Button_OK_single")
	local okBtn = self:getChild("Button_OK")
	local cancelBtn = self:getChild("Button_Cancel")
	
	if not okCallback and not bOK and not cancelCallback and not bCancel then
		--没有确认和取消按钮,点击任何地方关闭对话框
		singleOKBtn:setVisible(false)
		okBtn:setVisible(false)
		cancelBtn:setVisible(false)

		panel:setTouchEnabled(true)
		panel:addTouchEvent({[ccui.TouchEventType.ended] = handler(sCallbackMgr, sCallbackMgr.RemoveMsgBox)})
	elseif not bOK and okCallback then
		--没有确认和取消按钮,点击任何地方响应回调函数
		singleOKBtn:setVisible(false)
		okBtn:setVisible(false)
		cancelBtn:setVisible(false)

		panel:setTouchEnabled(true)
		panel:addTouchEvent({[ccui.TouchEventType.ended] = handler(sCallbackMgr, okCallback)})
	elseif bOK and okCallback and not bCancel then
		--有确认按钮，没有取消按钮
		singleOKBtn:setVisible(true)
		okBtn:setVisible(false)
		cancelBtn:setVisible(false)

		singleOKBtn:setTouchEnabled(true)
		singleOKBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(sCallbackMgr, okCallback)})
	elseif bOK and okCallback ~= nil and bCancel then
		--有确认和取消按钮
		singleOKBtn:setVisible(false)
		okBtn:setVisible(true)
		cancelBtn:setVisible(true)

		okBtn:setTouchEnabled(true)
		okBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(sCallbackMgr, okCallback)})

		if cancelCallback then
			cancelBtn:setTouchEnabled(true)
			cancelBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(sCallbackMgr, cancelCallback)})
		end
	else

	end
end

return MsgBox