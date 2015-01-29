function HandleDetectClient(packet)
	--closeFunnelLayer()
	packet:getU8() -- 一定是0
	local result = packet:getU8()
	local language = packet:getU8()
	local url = packet:getStr()
	if language ~= 255 then
		INT.localeIndex = language
		sStringMgr.reload()
	end
	if false then
	--if result > verCode.revised then
		function openUpdateUrl()
			PlatformUtility:OpenFullLink(url)
		end
		sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_Version),openUpdateUrl,openUpdateUrl)
	else
		sGameMgr:EnterScene(GameState.LOGIN)
	end
end

function HandleLoginFirstChallenge(packet)

end

function HandleLoginChallengeResponse(packet)
	local opRet = packet:getU8()
	cclog(opRet)
	if opRet ~= 0 then
		cclog("error code:"..opRet)
		sGameMgr:ShowInfo("LoginChallengeResponse error code:"..tostring(opRet))
	elseif opRet == 0 then
		network.SendLoginPacket(packet)
	end
end

function HandleLoginRealmListResponse(packet)
	network.LoginRealmListResponse(packet)
	network.ConnectGameServer()
end

function HandleAnonyCreateResponse(packet)
	local opRet = packet:getU8()
	if opRet == 0 then 
		AnonymAccount = packet:getStr()
		cclog("AnonymAccount undetected,create")
		PlatformUtility:setAnonymAccount(AnonymAccount)
		local psw = "000000"
		local nameStr = PlatformUtility:getAccount()
		local pswStr = PlatformUtility:getPassword()
		if nameStr == "" or pswStr == "" then
		    network.SetUserNameAndPassWord(AnonymAccount,psw)
			local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		    send_packet:setStr("zhCN")
			send_packet:setStr(AnonymAccount)
			network.send(send_packet)
        else
        	network.SetUserNameAndPassWord(nameStr,pswStr)
        	local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		    send_packet:setStr("zhCN")
			send_packet:setStr(nameStr)
			network.send(send_packet)
		end
	else
		sGameMgr:ShowInfo("Anonym create Failed")
	end
end

function HandleLoginProofResponse(packet)
	local opRet = packet:getU8()
	if opRet ~= 0 and opRet~=4 then
		cclog(opRet)
		sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_LoginFailed))
	elseif opRet == 4 then 
		sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_LoginInvalPsw))
	else
		local account = PlatformUtility:getAccount()
		local anonymous = PlatformUtility:getAnonymAccount()
		if account ~= "" and anonymous ~= "" then
			if string.sub(anonymous,1,8) == "UBERAUTO" then
				local send_packet1 = WorldPacket:new(CMD_BIND_ACCOUNT,70)
				send_packet1:setStr(account)
				send_packet1:setStr(anonymous)
				network.send(send_packet1)
				cclog("~~~~~~~~Account exists,Bind~~~~~~~~")
			else
				sGameMgr:ShowInfo("Unknown Error,Bind Failed")
			end
		else
			local send_packet2 = WorldPacket:new(CMD_REALM_LIST,0)
	    	network.send(send_packet2)
	    	cclog("~~~~~~~~Current Account is nil,Login with Anonym~~~~~~~~~~~~")
		end

	end 
end

function HandleCreateAccountResponse(packet)
	local opRet = packet:getU8()
	if opRet == 0 then
		--[[
		--sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_RegisterSuccess))]]
		cclog("registerSucces")
		--注册成功后需要给服务器发送登陆消息

		local nameStr = PlatformUtility:getAccount()
		local pswStr = PlatformUtility:getPassword()
		network.SetUserNameAndPassWord(nameStr,pswStr)

		local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		send_packet:setStr("zhCN")
		send_packet:setStr(nameStr)
		--send_packet:setStr("000000")
		network.send(send_packet)
		createFunnelLayer()

	elseif opRet == 50 then
		--[[
		sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_RegisterNameUsed))]]
		cclog("register fail! Name Used!!!!")
		sGameMgr:ShowInfo("register fail! Name Used!!!!")
	else
		--sGameMgr:ShowInfo(sStringMgr:getStringFromDBC(LocaleString.s_RegisterReput))
		sGameMgr:ShowInfo("Please reput register!")
	end
end

function HandleAccountBindResponse(packet)
	local opRet = packet:getU8()
	if opRet == 0 then
		cclog("~~~~~~~~~~~~~~~~Anonym Bind Done~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        PlatformUtility:setAnonymAccount("")
        local send_packet = WorldPacket:new(CMD_REALM_LIST,0)
	    network.send(send_packet)
	else 
		cclog(opRet)
		cclog("~~~~~~~~~~~~~~~Account Has been Binded,Direct Login~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		local send_packet = WorldPacket:new(CMD_REALM_LIST,0)
	    network.send(send_packet)
	end
    

end

