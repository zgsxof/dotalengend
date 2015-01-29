

function HandleGameAuthChallengeResponse(packet)
    network.GameAuthChallengeResponse(packet)

    network.setVersion(verCode.ver)
	network.sendAuthSessionMessage()
end

function HandleGameAuthSessionResponse(packet)
	local opRet = packet:getU8()
	if opRet == 0x60 then
		local send_packet = WorldPacket:new(CMSG_GAME_CHAR_ENUM,0)
   		network.send(send_packet)
	else
		cclog("登陆错误:"..opRet)
		sGameMgr:ShowInfo("登陆错误:" .. tostring(opRet))
	end
	
	--debug 认证成功就进入主界面
	--game.enter(GAMESTATE_MAIN)
end

function HandlerGameCharEnumResponse(packet)
	local opRet = packet:getU8()
	if opRet == 0 then --无错误
		local char_num = packet:getU8()
		if char_num == 0 then --没有创建过角色，首次进入游戏
			--弹出创建昵称界面
--[[			local send_packet = WorldPacket:new(CMSG_GAME_CHAR_CREATE,0)
			math.newrandomseed()
			local num = math.random(1,10000)
			local username = string.format("test34_"..num)
			send_packet:setStr(username)
			network.send(send_packet)
]]
			local mainLayer = sharedDirector:getRunningScene():getChildByTag(10086)
			local CreateNameLayer = require("UI.CreateName").new()
			mainLayer:addChild(CreateNameLayer)

			--cclog("-----first enter game,my name is:"..username)
		else
			local guid = packet:getU64()
			HERO_GUID = guid:getValue32()
			HERO_GUID_64 = guid
			local send_packet = WorldPacket:new(CMSG_GAME_PLAYER_LOGIN,4)
			send_packet:setU64(guid)
			network.send(send_packet)
		end
	else
		cclog("玩家进入失败:"..opRet)
		sGameMgr:ShowInfo("玩家进入失败:" .. tostring(opRet))
	end
end

function HandlerGameCharCreateResponse(packet)
	local opRet = packet:getU8()
	if opRet == 0 then 
		local send_packet = WorldPacket:new(CMSG_GAME_CHAR_ENUM,0)
		network.send(send_packet)
	else              --1004为昵称已存在
		cclog("创建人物,错误返回码:"..opRet)
		sGameMgr:ShowInfo("创建人物,错误返回码:" .. tostring(opRet))
	end
end

function HandleGamePlayerLoginResponse(packet)
	local opRet = packet:getU8()
	if opRet ~= 0 then
		sGameMgr:ShowInfo(tostring(opRet))
	    return
    end

    sGameMgr:EnterScene(GameState.MAIN)

    cclog("login successfully")
end


function HandleGameSendPurchaseGoods(packet)     --钻石商店付费
	local code = packet:getU32()
	print("HandleGameSEND_PURCHASE_GOODS,getU32:%d",code)
	if code == errorCode.NO_ERROR then
		cclog("buy goods successfully")
		--sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_GamePurchaseSuccess))
		sGameMgr:ShowInfo("buy goods successfully")
	else
		sGameMgr:ShowInfo(tostring(code))
	end

	sPlayer:updateData(packet)

	cclog("diamond counts:"..sPlayer.diamond)
	game.mainscene.modifydiamond = 1

	local diamondShop = game.mainscene:getChildByTag(1002)
	if diamondShop then
		diamondShop:setFirstPurchseRewardVisible(false)
	end
end