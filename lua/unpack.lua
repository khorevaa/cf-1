
local fs = require "path.fs"
local miniz = require "miniz"
local cf = require "cf"

local END = "\xFF\xFF\xFF\x7F"

local function write(name, data)
    local file = assert(io.open(name, "wb"))
    file:write(data)
    file:close()
end

local function UnpackTo(dst, rd)

    local Image = cf.ReadImage(rd)
    local ret, res

    for _, id, body, packed in Image.Rows() do
        if packed then
            ret, res = pcall(miniz.inflate, body, 0)
            if not ret then -- xml?
                write(dst .. id, body)
            else
                if res:sub(1, 4) == END then
                    local dir = dst .. id .. "/"
                    fs.mkdir(dir)
                    UnpackTo(dir, cf.StringReader(res))
                else
                    write(dst .. id, res)
                end
            end
        else
            write(dst .. id, body)
        end
    end

end

local file = assert(io.open(arg[1] or "C:/temp/RU/1Cv8.cf", "rb"))
local dir = arg[2] or "C:/temp/RU/1Cv8_cf/"
dir = dir:sub(-1) == '/' and dir or dir..'/'
fs.mkdir(dir)
-- ProFi = require 'ProFi'
-- ProFi:start()
UnpackTo(dir, cf.FileReader(file))
-- ProFi:stop()
-- ProFi:writeReport( 'ProfilingReport.txt' )