local BaseObject = class("BaseObject", function() 
	return ccui.image({image=""}) 
end)
BaseObject.__index = BaseObject

function BaseObject:ctor( )
	-- body
end

function BaseObject:DoPause()
	for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        if iskindof(child,"BaseObject") then
        	child:DoPause()
        else
        	child:pause()
        end
    end

end

function BaseObject:Remove( )
    cclog("obj remove and cleanup")
    self:removeFromParent()
end

function BaseObject:DoResume()
	for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        if iskindof(child,"BaseObject") then
        	child:DoResume()
        else
        	child:resume()
        end
    end
end

function BaseObject:isFlip(  )
    return self._flip
end

function BaseObject:setFlip(bFlip)
    if self._flip ~= bFlip then
        self._armature:setScaleX( self._armature:getScaleX() * -1 )
        self._flip = bFlip
    end
end

function BaseObject:Load( filename )
    local name
    if type(filename) == "table" then
        local pngPath = filename.pngPath
        local plistPath = filename.plistPath
        local xmlPath = filename.xmlPath
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(pngPath,plistPath,xmlPath)
        cclog("addAnimation filename:"..pngPath)
        local _xml = cc.getFullPath(xmlPath);
        require("Common.LuaXml")
        local skeleton = xml.load(_xml)
        name = skeleton:find("armatures"):find("armature").name
        self._info = skeleton
    else
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(filename)
        cclog("addAnimation filename:"..filename)
        local t = string.split(filename,"/")
        name = t[1]--string.ipextension(filename)
    end

    cclog("addAnimation name:"..name)
    self._armature = ccs.Armature:create(name)
    self._armature:getAnimation():playWithIndex(0)
local rect = self._armature:getBoundingBox()
    --
    if tolua.type(self) == "cc.Sprite" then
        self:addChild(self._armature)
        self._armature:pos(cc.pMul(cc.s2p(self:getContentSize()),0.5))
    else
        self:addChild(self._armature)
        self._armature:pos(cc.pMul(cc.s2p(self:getVirtualRendererSize()),0.5))
    end
    local rect = self._armature:getBoundingBox()
    self._objSize = cc.size(self._armature:getContentSize().width/2,self._armature:getContentSize().height/2)--self._armature:getContentSize().width/2

end

function BaseObject:Play( action,loop )
    self._armature:getAnimation():play( action ) 
    if self._info then
        local rate = self._info.frameRate/60
        self._armature:getAnimation():setSpeedScale(rate)
    end
end

return BaseObject