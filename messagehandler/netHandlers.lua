function HandleGameModifyTeamResp( packet )
	local opRet = packet:getU8()
	if opRet == 0 then
		sGameMgr:ShowInfo("调整出战列表成功")
		cclog("modify team successfully")
	else
		cclog("modify team fail")
	end
end

function Handle_UpdateSceneInfo( packet )

	local flag = packet:getU8()

	if flag == 1 then		-- init
		local count = packet:getU32()
		local mark,buytimes,entertimes;
		--sCSceneMgr.init();
		for i = 1,count do
			local id = packet:getU32()
			local mark = packet:getU8()
			local buytimes = packet:getU8()
			local entertimes = packet:getU8()
			sSceneMgr:AddPassed(id);
		end
		count = packet:getU32()
		for i = 1,count do
			local id = packet:getU32()
			sSceneMgr:AddAllowable(id);
		end
	elseif flag == 2 then
		local id = packet:getU32()
		sSceneMgr:AddPassed(id);
	elseif flag == 3 then
		local id = packet:getU32()
		sSceneMgr:AddAllowable(id);
	elseif flag == 4 then
		local id = packet:getU32()
		sSceneMgr:ResetGroup( id );
	end
end

function Handle_lootResponse( packet )
	local categorys = packet:getU8()
	for i = 1,categorys do
		local itemid = packet:getU32()
		local itemcount = packet:getU32()
		cclog("-------loot itemid:%d,count:%d",itemid,itemcount)
	end
end

function Handle_IntensifyEquipResponse( packet )
	local opRet = packet:getU8()
	if opRet == 0 then
		sGameMgr:ShowInfo("强化成功")
	else
		sGameMgr:ShowInfo(string.format("intensify error:%d",opRet))
	end
end

function Handle_UpgradeEquipResponse( packet )
	local opRet = packet:getU8()
	if opRet == 0 then
		sGameMgr:ShowInfo("升级成功")
	else
		sGameMgr:ShowInfo(string.format("upgrade equip error:%d",opRet))
	end
end

function Handle_AssignExpResponse( packet )
	local opRet = packet:getU8()
	if opRet == 0 then
		sGameMgr:ShowInfo("分配经验成功")
	else
		sGameMgr:ShowInfo(string.format("AssignExp error:%d",opRet))
	end
end

function Handle_EnterBattleResponse( packet )
	local opRet = packet:getU8()
	if opRet == 0 then
		sBattleProxy:BattleStart()
	else
		cclog("EnterBattle error:"..opRet)
		sGameMgr:ShowInfo(string.format("EnterBattle error:%d",opRet))
	end
end

function Handle_BattleResult( packet )
	local opRet = packet:getU8()
	if opRet == 0 then
		cclog("handle battle quit successfully")
		if sBattleMap then
			sBattleMap:SetState(SceneStatus.SCENE_STATUS_WAIT)
		end
	else
		cclog("handle battle result fail,error code"..opRet)
	end
end