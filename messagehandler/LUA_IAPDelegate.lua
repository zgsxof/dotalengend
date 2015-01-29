LUA_IAPDelegate = class("LUA_IAPDelegate",function()
	local delegate = InAppPurchaseDelegate:new()
	require ("framework.InAppPurchaseDelegateExtend")
	InAppPurchaseDelegateExtend.extend(delegate)
	delegate:handleIAPEvent(true)
	return delegate
end)

-- 预定义的商品信息
local products = 
{
	{id = "com.uber.sanxiao.cn1.yuanbao.one3", price = "", locale = 0,verid = 1},
	{id = "com.uber.sanxiao.cn1.yuanbao.two3", price = "", locale = 0,verid = 1},
	{id = "com.uber.sanxiao.cn1.yuanbao.three3", price = "",locale = 0,verid = 1},
	{id = "com.uber.sanxiao.cn1.yuanbao.four3", price = "", locale = 0,verid = 1},
	{id = "com.uber.sanxiao.cn1.yuanbao.five3", price = "", locale = 0,verid = 1},
	{id = "com.uber.sanxiao.cn1.yuanbao.six3", price = "", locale = 0,verid = 1},           
	{id = "com.uber.sanxiao.encn2.yuanbao.one1", price = "", locale = 0,verid = 2},
	{id = "com.uber.sanxiao.encn2.yuanbao.two1",price = "", locale = 0,verid = 2},
	{id = "com.uber.sanxiao.encn2.yuanbao.three1",price = "", locale = 0,verid = 2},
	{id = "com.uber.sanxiao.encn2.yuanbao.four1", price = "",locale = 0,verid = 2},
	{id = "com.uber.sanxiao.encn2.yuanbao.five1", price = "",locale = 0,verid = 2},
	{id = "com.uber.sanxiao.encn2.yuanbao.six1", price = "",locale = 0,verid = 2},
	{id = "com.uber.sanxiao.en3.yuanbao.one1", price = "", locale = 0, verid = 3},
	{id = "com.uber.sanxiao.en3.yuanbao.two1", price = "", locale = 0, verid = 3},
	{id = "com.uber.sanxiao.en3.yuanbao.three1", price = "", locale = 0, verid = 3},
	{id = "com.uber.sanxiao.en3.yuanbao.four1", price = "", locale = 0, verid = 3},
	{id = "com.uber.sanxiao.en3.yuanbao.five1", price = "", locale = 0, verid = 3},
	{id = "com.uber.sanxiao.en3.yuanbao.six1", price = "", locale = 0, verid = 3},
	--[[
	{id = "com.uber.sanxiao.en2.yuanbao.one", price = "", locale = 0, verid = 4},
	{id = "com.uber.sanxiao.en2.yuanbao.two", price = "", locale = 0, verid = 4},
	{id = "com.uber.sanxiao.en2.yuanbao.three", price = "", locale = 0, verid = 4},
	{id = "com.uber.sanxiao.en2.yuanbao.four", price = "", locale = 0, verid = 4},
	{id = "com.uber.sanxiao.en2.yuanbao.five", price = "", locale = 0, verid = 4},
	{id = "com.uber.sanxiao.en2.yuanbao.six", price = "", locale = 0, verid = 4},
	{id = "com.uber.sanxiao.en3.yuanbao.one", price = "", locale = 0, verid = 5},
	{id = "com.uber.sanxiao.en3.yuanbao.two", price = "", locale = 0, verid = 5},
	{id = "com.uber.sanxiao.en3.yuanbao.three", price = "", locale = 0, verid = 5},
	{id = "com.uber.sanxiao.en3.yuanbao.four", price = "", locale = 0, verid = 5},
	{id = "com.uber.sanxiao.en3.yuanbao.five", price = "", locale = 0, verid = 5},
	{id = "com.uber.sanxiao.en3.yuanbao.six", price = "", locale = 0, verid = 5},
	{id = "com.uber.sanxiao.en4.yuanbao.one", price = "", locale = 0, verid = 6},
	{id = "com.uber.sanxiao.en4.yuanbao.two", price = "", locale = 0, verid = 6},
	{id = "com.uber.sanxiao.en4.yuanbao.three", price = "", locale = 0, verid = 6},
	{id = "com.uber.sanxiao.en4.yuanbao.four", price = "", locale = 0, verid = 6},
	{id = "com.uber.sanxiao.en4.yuanbao.five", price = "", locale = 0, verid = 6},
	{id = "com.uber.sanxiao.en4.yuanbao.six", price = "", locale = 0, verid = 6}]]
}

function LUA_IAPDelegate:ctor()
	for _,v in ipairs(products) do
		if v.locale == LOCALE_INDEX and v.verid == VER_ID then
			self:addProduct(v.id,v.price)
		end
	end
end

function LUA_IAPDelegate:onQueryProductFinish()
	cclog("Query finish")
	closeFunnelLayer()
	local i = 0
	for _,v in ipairs(products) do
		if v.locale == LOCALE_INDEX and v.verid == VER_ID then
			v.price = self:getPrice(i)
			i = i+1
			cclog(v.price)
		end
	end	
end

function LUA_IAPDelegate:onPurchaseFinish(content)
	cclog("purchase finish")
	if content ~= nil then
		cclog(content)
	end
	if cc.platform == "ios" then
		--local send_packet = WorldPacket:new(CMSG_GAME_VERIFY_PURCHASE_RECEIPT,100)   --换成服务端红好的CMSG_GAME_VERIFY_PURCHASE_RECEIPT
		local send_packet = WorldPacket:new(CMSG_GAME_VERIFY_PURCHASE_RECEIPT,100)
		send_packet:setStr(content)
		network.send(send_packet)
	elseif cc.platform == "android" then
		local send_packet = WorldPacket:new(CMSG_GAME_ALIPAY_BUY,100)
		send_packet:setStr(content)
		network.send(send_packet)
	end
end

function LUA_IAPDelegate:onPurchaseFailed(desc)
	if desc ~= nil then
		closeFunnelLayer()
		--弹出错误窗口,desc是错误信息
		sGameMgr:ShowInfo(desc)
		local sureWnd =  require("UI.RandCardSure").new()
		game.mainscene:addChild(sureWnd)
		sureWnd:getChild("Label_Info"):setText(desc)
	end
	--closeFunnelLayer()
end

return LUA_IAPDelegate