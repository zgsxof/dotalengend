-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end

require("init")

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local glview = sharedDirector:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("FairyTail",
            cc.rect(0, 0, config.width, config.height))
        sharedDirector:setOpenGLView(glview)
    end
    cclog("--------111")

    require("displayConfig")
    require("framework.display")

    local shader = { n = "gray",v = "TPC_noMvp.vsh", f = "gray.fsh" }
    display.addShader( shader )

    require("MyApp"):new()
end

xpcall(main, __G__TRACKBACK__)
