
local upload = class("uploadClass", function() 
    return ccs.loadLayer("Upload/Upload.json") 
end)

function upload:update(dt)
    --cclog("upload update")
end

function upload:reload()
    cclog("upload reload")
end

function upload:onEnter()
  -- body
  self.AM = AssetsManager:new("http://192.168.1.111/package.zip","http://192.168.1.111/version","d:/")
  self.AM:update()
  self.AM:registerScriptHandler(handler(self,self.updateHandler))
end

function upload:updateHandler(event)
  if type(event) ~= "number" then
      if event == "success" then
           
      else
                    
      end
      cclog(event)
      if network.startup(GlobalVarTable.LoginAddress) == true then
        game.enter(GAMESTATE_LOGIN)
      else
        self:getChild("TextArea"):setText("连接登陆服务器失败")
      end
  else
                 
  end
end

return upload