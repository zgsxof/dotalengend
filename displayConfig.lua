verCode = 
{
  none  = 0,
  last  = 1,  -- 最新
  revised = 2,  -- 修正版
  sub   = 3,  -- 次版本
  main  = 4,  -- 主版本
  deprecated = 5, -- 废弃]
  ver   = 12354, -- 版本号
  text    = "1.0.0",
}

LOAD_CCS_FILE_BY_CSB = 1
LOAD_CCS_FILE_BY_JSON = 2
LOAD_CCS_FILE_BY_EXPORTJSON = 3

LOAD_CCS_FILE = LOAD_CCS_FILE_BY_CSB

LOAD_ARMATURE_BY_CCS = 1
LOAD_ARMATURE_BY_DRAGON_BONES = 2
LOAD_ARMATURE_BY_SPINE = 3

LOAD_ARMATURE = LOAD_ARMATURE_BY_CCS

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

-- auto scale mode
--CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
--cclog(string.format("WinSize width:%f,height:%f",cc.Director:getInstance():getWinSize().width,cc.Director:getInstance():getWinSize().height))
local screenSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
if screenSize.width / screenSize.height > config.designWidth/config.designHeight then
    CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
else
    CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
end
