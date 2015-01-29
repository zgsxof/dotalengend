
local Hero = import("..models.Hero")
local HeroView = import("..views.HeroView")

local ObjectController = class("ObjectController", function()
    return display.newNode()
end)

function ObjectController:ctor()

    -- 注册帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.tick))
    self:scheduleUpdate()

    -- 在视图清理后，检查模型上注册的事件，看看是否存在内存泄露
    self:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "exit" then
            self.player:getComponent("components.behavior.EventProtocol"):dumpAllEventListeners()
        end
    end)
end

function ObjectController:AddObject( obj )
    self.views_ = {}

    self.views_[obj] = HeroView.new(obj)
        :pos(display.cx - 300, display.cy)
        :addTo(self)
end

function ObjectController:Attack( attacker,target,spellId )
    attacker:Attack(target) --逻辑上的攻击

    self.views_[attacker]:Attack(target) --表现上的攻击
end

return PlayDuelController
