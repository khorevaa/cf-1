
local miniz = require "miniz"
-- local json = require "json"
local cf = require "cf"
local path = require "path"
local fs = require "path.fs"

local END = "\xFF\xFF\xFF\x7F"

local function write(name, data)
    local file = assert(io.open(name, "wb"))
    file:write(data)
    file:close()
end

local function UnpackTo(dir, rd)
    local image, list
    image = cf.ReadImage(rd)
    list = image.List()
    local ret, res
    -- root
    rd:Seek(list["root"])
    ret, res = pcall(miniz.inflate, rd:ReadRowBody(), 0)
    assert(ret)
    local root = assert(cf.Parse(res:sub(4)))
    -- conf
    local confID = root[2]
    rd:Seek(list[confID])
    ret, res = pcall(miniz.inflate, rd:ReadRowBody(), 0)
    assert(ret)
    local conf = cf.Parse(res:sub(4))
    -- meta
    local containerCount = tonumber(conf[3], 10)
    for i = 4, containerCount+3 do
        local container = conf[i]
        local containerID = container[1]
        local metaClasses
        if containerID == "9cd510cd-abfc-11d4-9434-004095e12fc7" then
            metaClasses = container[2]
        elseif containerID == "9fcd25a0-4822-11d4-9414-008048da11f9" then
            metaClasses = container[2][2]
        elseif containerID == "e3687481-0a87-462c-a166-9f34594f9bba" then
            metaClasses = container[2]
        elseif containerID == "9de14907-ec23-4a07-96f0-85521cb6b53b" then
            metaClasses = container[2]
        elseif containerID == "51f2d5d8-ea4d-4064-8892-82951750031e" then
            metaClasses = container[2]
        elseif containerID == "e68182ea-4237-4383-967f-90c1e3370bc7" then
            metaClasses = container[2]
        end
        if metaClasses then
            local metaClassesCount = tonumber(metaClasses[3], 10)
            for j = 4, metaClassesCount+3 do
                local metaList = metaClasses[j]
                local metaID = metaList[1]
                local metaDataCount = tonumber(metaList[2], 10)
                if metaID == "061d872a-5787-460e-95ac-ed74ea3a3e84" then -- Document
                    fs.mkdir(path.join(dir, "Documents"))
                    for k = 3, metaDataCount+2 do
                        local documentID = metaList[k]
                        rd:Seek(list[documentID])
                        ret, res = pcall(miniz.inflate, rd:ReadRowBody(), 0)
                        assert(ret)
                        local document = cf.Parse(res:sub(4))
                        local documentName = document[2][10][2][3]:sub(2,-2)
                        local documentDir = path.join(dir, "Documents", documentName)
                        fs.mkdir(path.ansi(documentDir))
                        -- ObjectModule
                        local objectModuleID = documentID..".0"
                        if list[objectModuleID] then
                            rd:Seek(list[objectModuleID])
                            ret, res = pcall(miniz.inflate, rd:ReadRowBody(), 0)
                            assert(ret)
                            if res:sub(1,4) == END then
                                local rd = cf.StringReader(res)
                                local image = cf.ReadImage(rd)
                                local list = image.List()
                                if list["text"] then
                                    rd:Seek(list["text"])
                                    res = rd:ReadRowBody()
                                    write(path.ansi(documentDir.."/ObjectModule.bsl"), res)
                                end
                            else
                                write(path.ansi(documentDir.."/ObjectModule.bsl"), res)
                            end
                        end
                        -- ManagerModule
                        local managerModuleID = documentID..".2"
                        if list[managerModuleID] then
                            rd:Seek(list[managerModuleID])
                            ret, res = pcall(miniz.inflate, rd:ReadRowBody(), 0)
                            assert(ret)
                            if res:sub(1,4) == END then
                                local rd = cf.StringReader(res)
                                local image = cf.ReadImage(rd)
                                local list = image.List()
                                if list["text"] then
                                    rd:Seek(list["text"])
                                    res = rd:ReadRowBody()
                                    write(path.ansi(documentDir.."/ManagerModule.bsl"), res)
                                end
                            else
                                write(path.ansi(documentDir.."/ManagerModule.bsl"), res)
                            end
                        end
                    end
                end
            end
        end
    end
end

local file = assert(io.open(arg[1] or "C:/temp/RU/1Cv8.cf", "rb"))
local dir = arg[2] or "C:/temp/RU/1Cv8_cf_result/"
dir = dir:sub(-1) == '/' and dir or dir..'/'
fs.mkdir(dir)
-- ProFi = require 'ProFi'
-- ProFi:start()
UnpackTo(dir, cf.FileReader(file))
-- ProFi:stop()
-- ProFi:writeReport( 'MyProfilingReport2.txt' )