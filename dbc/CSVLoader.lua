local CSVLoader = CSVLoader or {}

local CSVformat =
{
	["x"] = {handler = getU32,size = 4},
	["X"] = {handler = getU32,size = 4},
	["n"] = {handler = getU32,size = 4},
	["i"] = {handler = getU32,size = 4},
	["f"] = {handler = getFloat,size = 4},
	["b"] = {handler = getByte,size = 1},
	["s"] = {handler = getString,size = 4},
}

function CSVLoader.load(entry)
    local dbcStore = {}
	local filename = cc.getFullPath(entry.filename)
	if cc.isFileExist(filename) == false then
         cclog("required dbc : "..entry.filename.." not found")
         return nil
    end
    --local data = io.readfile(filename)
    local function readFileFrom2thLine(path)
        local file = io.open(path, "r")
        if file then
            local content = {}
            local i = 0
            for l in file:lines() do
                if i ~= 0 then
                    content[i] = l
                end
                i = i + 1
            end 
            io.close(file)
            return content
        end
        return nil
    end
    --要滤去第一行的内容，因为第一行是字段的说明
    local data = readFileFrom2thLine(filename)
    --[[
    local context = cc.FileUtils:getInstance():getStringFromFile(filename)--readFileFrom2thLine(filename)
    local data = string.split(context,"\n")]]
    filename = entry.filename

    entry.filename = nil		-- 删除filename字段

    local fmtLen = string.len(entry.fmt)
    local fmtTable = {}
    local oneRecordSize = 0
    local indexpos = -1
    for i=1,fmtLen do
    	fmtTable[i] = string.sub(entry.fmt,i,i)
    	if fmtTable[i] == "n" then
    		indexpos = oneRecordSize
    	end
    	oneRecordSize = oneRecordSize + CSVformat[fmtTable[i]].size
    end
    entry.fmt = nil 			-- 删除fmt字段

    function setValue(dstTable,srcTable,valueTable,deep)
        local step = 0
        for k,v in ipairs(srcTable) do
            if type(v) == "table" then
                local tempTable = {}        
                if v.name then                      -- 表有名字,是一个数组
                    dstTable[v.name] = tempTable
                else
                    dstTable[k-1] = tempTable       -- 表没名字,说明是一个结构体
                end
                step = step + setValue(tempTable,v,valueTable,step+deep)
            else
                step = step + 1
                fmt = fmtTable[step+deep]
                if type(v) == "number" or v == "" then
                    dstTable[k-1] = valueTable[step+deep]
                    if fmt ~= "s" then
                        dstTable[k-1] = tonumber(valueTable[step+deep])
                    end
                else
                    if fmt == "s" then
                        dstTable[v] = valueTable[step+deep]
                    else
                        dstTable[v] = tonumber(valueTable[step+deep])
                    end
                end
            end
        end
        return step
    end

    for k,v in pairs(data) do
        local tmp = string.split(data[k], ",")
        local id = tonumber(tmp[1])
        --table.remove(tmp,1)
        if not dbcStore[id] then dbcStore[id] = {} end
        if dbcStore[id] then
            setValue(dbcStore[id],entry,tmp,0)
        end
    end 
    

    return dbcStore
end

function loadCSVFile( entry )
    local retTable = {}
    local filename = cc.getFullPath(entry.filename)
    if cc.isFileExist(filename) == false then
         cclog("required dbc : "..entry.filename.." not found")
         return nil
    end

    local fmtLen = string.len(entry.fmt)
    local fmtTable = {}
    for i=1,fmtLen do
        fmtTable[i] = string.sub(entry.fmt,i,i)
    end
    entry.fmt = nil             -- 删除fmt字段

    local data = cc.FileUtils:getInstance():getStringFromFile(filename)
    local lineStr = string.split(data,"\n")
    local titles = string.split(lineStr[1],",")
    local ID = 1
    for i = 2,#lineStr do
        local content = string.split(lineStr[i],",")
        local ID = content[1]
        retTable[ID] = {}
        for j = 2,#titles do
            retTable[ID][titles[j]] = content[j]
        end
    end

    return retTable
end

return CSVLoader