-----游戏启动引擎


local StartEngineScene = class ("StartEngineScene", function()
    return cc.Scene:create()
end)

function StartEngineScene:ctor(  )

  --cc.NotificationManager:getNotificationManager()

	local handler = function(event)

        --------------------------进入场景----------------------
		if event == "enter" then
			self:onEnterScene()
        --------------------------退出场景----------------------
    	elseif event == "exit" then
        	--self:onExitScene()
        --------------------------清理场景----------------------
    	elseif event == "cleanup" then
      		self:unregisterScriptHandler()
        	--self:onCleanupScene()
    	end
    end

    self:registerScriptHandler(handler)
    ----------------------清理缓存的条目-------------------------
    sharedFileUtils:purgeCachedEntries()

end

function StartEngineScene:onEnterScene( ... )

    self:initUI()

end


StartEngineScene.sprite = nil;
StartEngineScene.alpha = 0;
StartEngineScene.time = 60;

function StartEngineScene:initUI( ... )

    local layer = cc.LayerColor:create(cc.c4b(255,255,255,255),0,0)

    --layer:setBackColor(ccc4(255, 255, 255, 255))
    self:addChild(layer)

    --self._btnAni:setFontSize(25)
    --self._btnAni:setTextColor(0, 255, 0)
    --self._btnAni:ignoreContentAdaptWithSize(false)
    --self._btnAni:setSize(CCSizeMake(120, 40))

    --此时display并没有加载,所以c++的导出接口获取窗口大小
    --local winSize = CCDirector:sharedDirector():getWinSize()

    local img = "image/gameStartImg.png";
    if CONFIG_SDKID ~= nil and CONFIG_SDKID ~= 0  then
        img = "gameStartImg_"..CONFIG_SDKID..".png"
    end;

    self.sprite = cc.Sprite:create( img );
    self.sprite:setPosition(cc.p(winSize.width / 2,winSize.height / 2))
    layer:addChild(self.sprite);
    self.sprite:setOpacity(0);

    self.sharedScheduler = sharedDirector:getScheduler()

    if self.updateTimeID ~= nil then
      self.sharedScheduler:unscheduleScriptEntry(self.updateTimeID);
    end

    self.updateTimeID  = self.sharedScheduler:scheduleScriptFunc(function ( )  self:updateTime()  end, 0.034, false)
end


function StartEngineScene:updateTime(dt)
    self.time = self.time - 1;
    if self.time > 50 then
      self.alpha = self.alpha + (255 / 20)
    elseif self.time == 50 then
      self.alpha = 255;
    -- elseif self.time < 20 then
    --   self.alpha = self.alpha - (255 / 20)
    end;

    if self.alpha > 255 then self.alpha = 255 end;
    if self.alpha < 0 then self.alpha = 0 end;

    self.sprite:setOpacity(self.alpha);

    if self.time < 0 then
      self:onCleanupScene();
    end;
end;



function StartEngineScene:onCleanupScene( )
    if self.updateTimeID ~= nil then
      self.sharedScheduler:unscheduleScriptEntry(self.updateTimeID);
    end

    self.updateTimeID = 0;

   -- CCLuaLoadChunksFromZip("framework_precompiled.zip");
    self:removeAllChildren();
    
    --[[
    CCLuaLoadChunksFromZip("UF.zip");
    if self.upgrade == nil then
        self.upgrade = require("upgrade.upgrade").new();
    end
    ]]
    cclog("------ StartEngineScene:onCleanupScene( )")
    sGameMgr:checkVer()
end

return StartEngineScene
