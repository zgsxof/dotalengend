local BaseObject = require("demo.BaseObject")
local SpellDisplay = class("SpellDisplay", BaseObject)

SpellDisplay.__index = SpellDisplay

function SpellDisplay:ctor(filename,spellstate)
	local jsonPath = string.format("%s/%s",filename,filename)
	self._armature = ccui.loadArmature( jsonPath )
	self._armature:getAnimation():playWithIndex(0)

	self._armature:pos(cc.pMul(cc.s2p(self:getVirtualRendererSize()),0.5))

	self:addChild(self._armature)
	--self:setSize( self._armature:getContentSize() )
	--[[
	local file = cc.getFullPath(jsonPath)
	local t = self:decode(file)]]
	
	--[[检测非BUFF或非飞行特效不能做成Loop
	if spellstate then
		if spellstate ~= SpellPhase.PHASE_STATE and spellstate ~= SpellPhase.PHASE_MISSILE then
			local data = self._armature:getAnimation():getAnimationData()
			if data:getMovement("Loop") ~= nil then
				assert(false,"only buff and missile effect can be loop")
			end
		end
	end
	]]
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
end

function SpellDisplay:decode( _json )
	local f = {mov = {}}
	local file = io.open(_json)
	if file then
		local json_str = file:read("*a")
		json_str = cjson.decode(json_str)
		f.character = json_str["armature_data"][1].name
		local anim_data = json_str["animation_data"]
		for k=1,#anim_data do
			local name = anim_data[k].name
			local mov_data = anim_data[k].mov_data
			for i=1,#mov_data do
				local mov = mov_data[i]
				if not f.mov[mov.name] then
					f.mov[mov.name] = {}
				end
				if not f.mov[mov.name][name] then
					f.mov[mov.name][name] = true
				end
			end
		end
		file:close()
	else
		assert(false,"没有找到目标文件")
	end
	return f
end


function SpellDisplay:End()
	--if self._armature then
	cclog("display removeFromParent")
	self:removeFromParent()
	--end
end

return SpellDisplay