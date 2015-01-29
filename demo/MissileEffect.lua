local SpellDisplay = require("demo.SpellDisplay")
local MissileEffect = class("MissileEffect", SpellDisplay)

missile_type = 
{
	unit = 1,
	dest = 2,
}

path_type = 
{
	line = 1,
	parabola = 2,
}

MissileEffect.__index = MissileEffect

function MissileEffect:ctor( spell,caster,targetOrDest,time,pathtype )
	cclog("---------add MissileEffect")
	self._time = time
	self._caster = caster
	self._spell = spell
	self._spellinfo = spell:GetSpellInfo()
	self._effectEntry = GetSpellEffectEntry(self._spellinfo.visual)

	self._src = self._caster:GetBonePos2("LArm")
	local casterPosx = self._caster:getPositionX()
	local armaturePosx = self._caster._armature:getPositionX()

	
	if iskindof(targetOrDest,"GameObject") then
		self._type = missile_type.unit
		--local y = targetOrDest:GetBonePos2("TorsoTop").y
		local y = targetOrDest:getPositionY() + targetOrDest:GetObjectSize().height/2
		self._dest = cc.p(targetOrDest:getPositionX(),y )--targetOrDest:GetBonePos2("TorsoTop")

		self._target = targetOrDest

		self._pathtype = path_type.line
	else
		self._type = missile_type.dest
		self._dest = targetOrDest

		self._pathtype = path_type.parabola
	end

	self:Init()

	self:pos(cc.p(casterPosx,self._src.y))

	self:start()
end

function MissileEffect:Init()
	local effectPath = ""
	if self._effectEntry then
		effectPath = self._effectEntry.VisualEffects[SpellPhase.PHASE_MISSILE]
	end
	if effectPath == "" then return false end

	local filename = string.format("%s/%s",effectPath,effectPath)
	self._armature = ccui.loadArmature( filename )
	self._armature:getAnimation():playWithIndex(0)
	self:addChild(self._armature)

	local function movementEventCallback( armature, type, movementID )
		if type == ccs.MovementEventType.loopComplete then

	    elseif type == ccs.MovementEventType.complete then
	    	if movementID ~= "Loop" then --if movementID == "Start" then
	    		local data = armature:getAnimation():getAnimationData()
		    	if data:getMovement("Loop") ~= nil then
		    		armature:getAnimation():play("Loop")
		    	else
		    		local display = armature:getParent()
			    	if display then
			    		display:End()
			    	end
		    	end
		    	
		    end
	    end
	end
	self._armature:getAnimation():setMovementEventCallFunc(movementEventCallback);

--self:ShowBoundingBox()
	return true

end

function MissileEffect:onExit()
	cclog("--missile onExit")
	self:unscheduleUpdate()
end

function MissileEffect:start()
	
	if self._pathtype == path_type.line then
		self:line()
	else
		self:parabola()
	end
end

function MissileEffect:line( )
	local time = self._caster:GetDistancePoint(self._dest)
	if self._type == missile_type.unit then

	elseif self._type == missile_type.dest then

	end
	
	self:scheduleUpdateWithPriorityLua(handler(self,self.update),0)

	local handler = function(event)
    	if event == "exit" then
        	self:onExit()
    	elseif event == "cleanup" then
      		self:unregisterScriptHandler()
    	end
    end

    self:registerScriptHandler(handler)
end

function MissileEffect:parabola()
	--贝塞尔曲线
	
	local sx,sy = self._src.x,self._src.y
	local ex,ey = self._dest.x,self._dest.y

	local bezier = {
        cc.p(sx,sy),
        cc.p(sx+(ex-sx)*0.5, sy+(ey-sy)*0.5+400),
        cc.p(self._dest.x,self._dest.y),
    }
    --self._time = 2

    local bezierTo = cc.BezierTo:create(self._time,bezier)
	local rotateTo

    if self._caster:isFlip() then
	    self:setRotation(-110)
		rotateTo = cc.RotateTo:create(self._time,-250)
	else
		self:setRotation(-70)
		rotateTo = cc.RotateTo:create(self._time,70)
	end

	local action = cc.Sequence:create( cc.Spawn:create(bezierTo,rotateTo),cc.CallFunc:create(self.AreaEffect) )
	self:runAction(action)
end

function MissileEffect:ShowBoundingBox( ... )
	if not self._armature then return end

	--local node = self._armature:getChildByTag(10086)
	--if node and node:getContentSize().width ~= 0 then return end

	self._armature:removeChildByTag(10086,true)

	local draw = cc.DrawNode:create()
    self._armature:addChild(draw, 10,10086)

    local rect = self._armature:getBoundingBox()
    local star2 = {
        cc.p(rect.x, rect.y), cc.p(rect.x + rect.width, rect.y),
        cc.p(rect.x + rect.width, rect.y + rect.height), cc.p(rect.x, rect.y + rect.height),
    }
    draw:drawPolygon(star2, table.getn(star2), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
    draw:setContentSize(cc.size(rect.width,rect.height))

    if self:getChildByTag(10087) then return end

    local draw2 = cc.DrawNode:create()
    self:addChild(draw2,10,10087)
    local rect2 = self:getBoundingBox()
    rect2.width = 5
    rect2.height = 5
     local star2 = {
        cc.p(rect2.x, rect2.y), cc.p(rect2.x + rect2.width, rect2.y),
        cc.p(rect2.x + rect2.width, rect2.y + rect2.height), cc.p(rect2.x, rect2.y + rect2.height),
    }
    draw2:drawPolygon(star2, table.getn(star2), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
end

function MissileEffect:getBoundBox( ... )

	local rect2 = self._armature:getBoundingBox()

	local pos = self:convertToWorldSpace(cc.p(self._armature:getPositionX(),self._armature:getPositionY()))
    local pos2 = self:convertToWorldSpace(cc.p(rect2.x,rect2.y))
    local rect = cc.rect(pos2.x,pos2.y,rect2.width,rect2.height)

    return rect
end

function MissileEffect:AreaEffect()
	self:End()
	
	--延时完毕后要播放区域特效
	if self._spell then
		self._spell:AreaEffect(self._dest)
	end
end

function MissileEffect:updatePos( t )
    local currentPos = cc.p(self:getPositionX(),self:getPositionY());
    local diff = cc.pSub( currentPos , self._previousPosition)
    self._startPosition = cc.pAdd( self._startPosition , diff )
    local newPos =  cc.pAdd( self._startPosition, cc.pMul(self._positionDelta ,t))
    self:setPosition(newPos);
    self._previousPosition = cc.p(newPos.x,newPos.y)
end

function MissileEffect:update( dt )
	if not self._passTime then self._passTime = 0 end
	self._passTime = self._passTime + dt

	local rect = self:getBoundBox()

	if not self._pos then
		local src
		if self._caster:isFlip() == false then
			self:pos(cc.p(self._src.x + rect.width,self._src.y))
		else
			self:pos(cc.p(self._src.x - rect.width,self._src.y))
		end
		self._pos = true
		self._src = cc.p(self:getPositionX(),self:getPositionY())
		local dst = self.dest
		local dis = cc.pGetDistance(self._src,self._dest)
		dis = self._caster:GetDistance(self._target)
		if self._time ~= 0 and dis ~= 0 then
			self._speed = dis/self._time
		else
			self._speed = self._spellinfo.speed
		end

		self._previousPosition = cc.p(self._armature:getPositionX(),self._armature:getPositionY())
		self._startPosition = cc.p(self._armature:getPositionX(),self._armature:getPositionY())
		self._positionDelta = cc.pSub(self._dest,self._src)
		
		--按照施法者与受击者的坐标位置来设置旋转
		local dy = self._target:getPositionY() - self._caster:getPositionY()
		local dx = self._target:getPositionX() - self._caster:getPositionX()
		local ang = math.atan2(dy, dx)
		if ang < 0 then ang = 2 * math.pi  + ang end
		local deg = 0 - math.deg(ang)
		cclog("degree:%d",deg)
		self._armature:setRotation(deg)
	
		return
	end


	if self._type == missile_type.unit then
		if self._target:IsDirty() then
			self._dest = cc.p(self._target:getPositionX(),self._target:getPositionY() + self._target:GetObjectSize().height/2)
		end
	end

	if self._time ~= 0 then
		self:updatePos(math.min(1,self._passTime/self._time))
	end

	if self._passTime >= self._time then
		cclog("---------release MissileEffect")
		self:End()
		return
	end


	if cc.rectContainsPoint(rect,self._dest) then
		cclog("---------release MissileEffect")
		self:End()
		return
	end

	if self._spell._SpellState == SpellState.SPELL_STATE_FINISHED then
		cclog("---------release MissileEffect")
		self:End()
		return
	end
end

return MissileEffect