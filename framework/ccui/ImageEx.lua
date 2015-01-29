local ui = ccui
local image = ui.ImageView
local d = display

function image:setShader(shaderName)
	--self:getVirtualRenderer()得到的是scale9sprite,所有还要再getSprite()得到Sprite
	 self:getVirtualRenderer():getSprite():setShader(shaderName)
end

function image:setUniform(name,value)
	--self:getVirtualRenderer()得到的是scale9sprite,所有还要再getSprite()得到Sprite
	self:getVirtualRenderer():getSprite():setUniform(name,value)
end