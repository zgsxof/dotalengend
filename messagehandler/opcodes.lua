require("messagehandler.loginHandlers")
require("messagehandler.gameHandlers")
require("messagehandler.objectHandlers")
require("messagehandler.netHandlers")

-- opcoeds
-- LoginNetOpcodes
CMD_AUTH_LOGON_CHALLENGE_2											= 0x001 --发送账号名和密码
CMD_AUTH_LOGON_PROOF												= 0x002
CMD_AUTH_RECONNECT_CHALLENGE										= 0x003
CMD_AUTH_RECONNECT_PROOF											= 0x004
CMD_REALM_LIST														= 0x005 -- 请求服务器
CMD_CREATE_ACCOUNT													= 0x006
CMD_AUTH_LOGON_CHALLENGE_1										    = 0x007                                              
CMD_DETECT_CLIENT                                                   = 0x008
CMD_CREATE_ANONYMOUS_ACCOUNT                                        = 0x009
CMD_BIND_ACCOUNT                                                    = 0x00B

------------------
AddLoginHandler = function(opcode,name,handler)
	network.addHandler(opcode,NLS_LOGINSERVER,name,handler)
end

AddLoginHandler( CMD_AUTH_LOGON_CHALLENGE_1,"CMD_AUTH_LOGON_CHALLENGE_1",HandleLoginFirstChallenge)
AddLoginHandler( CMD_AUTH_LOGON_CHALLENGE_2,"第二次挑战",HandleLoginChallengeResponse)
AddLoginHandler( CMD_REALM_LIST,			"服务器列表",HandleLoginRealmListResponse)
AddLoginHandler( CMD_AUTH_LOGON_PROOF,		"登陆",HandleLoginProofResponse)
AddLoginHandler( CMD_CREATE_ACCOUNT,		"创建角色",HandleCreateAccountResponse)
AddLoginHandler( CMD_CREATE_ANONYMOUS_ACCOUNT,"匿名帐号创建",HandleAnonyCreateResponse)
AddLoginHandler( CMD_BIND_ACCOUNT,          "匿名帐号绑定",HandleAccountBindResponse)
AddLoginHandler( CMD_DETECT_CLIENT,			"版本验证", HandleDetectClient)

--GameNetOpcodes
SMSG_UPDATE_OBJECT                                                  = 0x0A9
SMSG_DESTROY_OBJECT                             					= 0x0AA
SMSG_INITIAL_SPELLS                             					= 0x12A --初始化技能
SMSG_LEARNED_SPELL                              					= 0x12B --学习技能
SMSG_SUPERCEDED_SPELL                           					= 0x12C
SMSG_REMOVED_SPELL                              					= 0x203 --移除技能

SMSG_LOOT_RESPONSE													= 0x160 --掉落
CMSG_BATTLEMAP_ENTER												= 0x525	--请求进入某张战斗地图
SMSG_BATTLEMAP_ENTER_RESPONSE										= 0x526
CMSG_BATTLEMAP_QUIT													= 0x527
SMSG_BATTLEMAP_QUIT_RESPONSE										= 0x528
CMSG_INTENSIFY_ITEM													= 0x52E
SMSG_INTENSIFY_ITEM_RESPONSE										= 0x52F
CMSG_MERGE_ITEM														= 0x531
SMSG_MERGE_ITEM_RESPONSE											= 0x532
SMSG_UPDATE_SCENE_PASS_INFO											= 0x539	--初始化和更新关卡进入信息
CMSG_UPGRADE_CHARACTER												= 0x5B3
SMSG_UPGRADE_CHARACTER_RESPONSE										= 0x5B4

SMSG_GAME_AUTH_CHALLENGE                                            = 0x804
CMSG_GAME_AUTH_SESSION												= 0x805
SMSG_GAME_AUTH_SESSION_RESPONSE                                     = 0x806
CMSG_GAME_CHAR_ENUM													= 0x900
SMSG_GAME_CHAR_ENUM_RESPONSE                                        = 0x901
CMSG_GAME_CHAR_CREATE												= 0x902
SMSG_GAME_CHAR_CREATE_RESPONSE                                      = 0x903
CMSG_GAME_CHAR_DELETE                           					= 0x904   -- 删除角色
SMSG_GAME_CHAR_DELETE_RESPONSE                  					= 0x905 
CMSG_GAME_PLAYER_LOGIN                          					= 0x906   --进入游戏
SMSG_GAME_PLAYER_LOGIN_RESPONSE                 					= 0x907
SMSG_GAME_BATTLE_CARD												= 0x909
SMSG_GAME_TIME_CAUTION												= 0x90B
SMSG_GAME_BATTLE_STATUS												= 0x90D
--CMSG_GAME_ENTER_MAP													= 0x910
--SMSG_GAME_ENTER_MAP_RESPONSE										= 0x911

CMSG_GAME_STAGE_ENTER                                               = 0x920   --进入关卡
SMSG_GAME_STAGE_ENTER_RESPONSE									    = 0x921
CMSG_GAME_STAGE_REWARD												= 0x922   --通关
SMSG_GAME_STAGE_REWARD_RESPONSE										= 0x923
CMSG_GAME_STAGE_MARK												= 0x924
SMSG_GAME_STAGE_MARK_RESPONSE										= 0x925
CMSG_GAME_ATTACK_TARGET												= 0x926
SMSG_GAME_ATTACK_TARGET_RESPONSE									= 0x927

CMSG_GAME_ASSIGN_EXP												= 0x950
SMSG_GAME_ASSIGN_EXP_RESPONSE										= 0x951
CMSG_GAME_ARENA_MATCH_CANCEL										= 0x952
SMSG_GAME_ARENA_MATCH_CANCEL_RESPONSE								= 0x953

CMSG_GAME_MODIFY_TEAM												= 0x980
SMSG_GAME_MODIFY_TEAM_RESPONSE										= 0x981

CMSG_GAME_GET_CARD                                                  = 0xA54    --祭坛抽卡
SMSG_GAME_GET_CARD_RESPONSE                                         = 0xA55
CMSG_GAME_TEST_ADD_ITEM                                             = 0xA58    --系统，GM测试功能
SMSG_GAME_TEST_ADD_ITEM_RESPONSE                                    = 0xA59
CMSG_GAME_SHOPPING                                                  = 0xA5C    --商店 ，购买商品
SMSG_GAME_SHOPPING_RESPONSE                                         = 0xA5D
CMSG_GAME_UPGRADE_CARD                                              = 0xA52    --英雄，转生
SMSG_GAME_UPGRADE_CARD_RESPONSE                                     = 0xA53
CMSG_GAME_INTENSIFY_CARD                        					= 0xA50    --强化卡牌
SMSG_GAME_INTENSIFY_CARD_RESPONSE               					= 0xA51
CMSG_GAME_TEST_ADD_ITEM                         					= 0xA58    --测试（格式是物品ID后跟数量）
SMSG_GAME_TEST_ADD_ITEM_RESPONSE                					= 0xA59    --返回 的是成功失败
CMSG_GAME_QUERY_PLAYERINFO                     						= 0xA5A    --查询信息（"查询类型"U32）1 玩家信息 2 卡片信息 3 队伍信息 0 全部
SMSG_GAME_QUERY_PLAYERINFO_RESPONSE             					= 0xA5B    --返回信息和登陆得到的人物信息一样
CMSG_GAME_QUERY_STAGE                           					= 0xA5E    --请求活动副本信息 
SMSG_GAME_QUERY_STAGE_RESPONSE                 					    = 0xA5F
CMSG_GAME_VERIFY_PURCHASE_RECEIPT				                    = 0x82F    -- add by zhoujy 通知服务器验证证书并发货
SMSG_GAME_SEND_PURCHASE_GOODS					                    = 0x830    --通知服务器验证证书并发货,返回

SMSG_GAME_RECOVER_ENERGY											= 0x836    --每10分钟增加体力,格式是 << 更新后的体力 << 更新间隔时间,第2个一般是600秒,都是u32
ERROR_CARD_MAX_LEVEL           										= 9101     --已经到达最大等级



AddGameHandler = function(opcode,name,handler)
	network.addHandler(opcode,NLS_GAMESERVER,name,handler)
end


AddGameHandler(SMSG_DESTROY_OBJECT, "SMSG_DESTROY_OBJECT",Handle_ObjectDestroy )
AddGameHandler(SMSG_UPDATE_OBJECT, "SMSG_UPDATE_OBJECT",Handle_ObjectUpdate )
AddGameHandler(SMSG_INITIAL_SPELLS,"SMSG_INITIAL_SPELLS", Handle_InitialSpells)
AddGameHandler(SMSG_LEARNED_SPELL,"SMSG_LEARNED_SPELL", Handle_LearnSpells)
AddGameHandler(SMSG_SUPERCEDED_SPELL,"SMSG_SUPERCEDED_SPELL", Handle_SupercededSpell)
AddGameHandler(SMSG_REMOVED_SPELL,"SMSG_REMOVED_SPELL", Handle_RemoveSpell)

AddGameHandler(SMSG_LOOT_RESPONSE,"SMSG_LOOT_RESPONSE",Handle_lootResponse)
AddGameHandler(SMSG_BATTLEMAP_ENTER_RESPONSE,"SMSG_BATTLEMAP_ENTER_RESPONSE",Handle_EnterBattleResponse)
AddGameHandler(SMSG_BATTLEMAP_QUIT_RESPONSE,"SMSG_BATTLEMAP_QUIT_RESPONSE",Handle_BattleResult)
AddGameHandler(SMSG_UPDATE_SCENE_PASS_INFO,"SMSG_UPDATE_SCENE_PASS_INFO",Handle_UpdateSceneInfo)

--equip
AddGameHandler(SMSG_INTENSIFY_ITEM_RESPONSE,"SMSG_INTENSIFY_ITEM_RESPONSE",Handle_IntensifyEquipResponse)
AddGameHandler(SMSG_MERGE_ITEM_RESPONSE,"SMSG_MERGE_ITEM_RESPONSE",Handle_UpgradeEquipResponse)
AddGameHandler(SMSG_GAME_AUTH_CHALLENGE, "SMSG_GAME_AUTH_CHALLENGE",HandleGameAuthChallengeResponse )
AddGameHandler(SMSG_GAME_AUTH_SESSION_RESPONSE,"SMSG_GAME_AUTH_SESSION_RESPONSE",HandleGameAuthSessionResponse )
AddGameHandler(SMSG_GAME_CHAR_ENUM_RESPONSE, "SMSG_GAME_CHAR_ENUM_RESPONSE", HandlerGameCharEnumResponse )
AddGameHandler(SMSG_GAME_CHAR_CREATE_RESPONSE,"SMSG_GAME_CHAR_CREATE_RESPONSE", HandlerGameCharCreateResponse )
AddGameHandler(SMSG_GAME_PLAYER_LOGIN_RESPONSE, "SMSG_GAME_PLAYER_LOGIN_RESPONSE", HandleGamePlayerLoginResponse)

AddGameHandler(SMSG_GAME_MODIFY_TEAM_RESPONSE,"SMSG_GAME_MODIFY_TEAM_RESPONSE",HandleGameModifyTeamResp)

AddGameHandler(SMSG_GAME_ASSIGN_EXP_RESPONSE,"SMSG_GAME_ASSIGN_EXP_RESPONSE",Handle_AssignExpResponse)
