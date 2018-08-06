
local Module = {}

local null = setmetatable({}, {
    __tostring = function ()
        return "null"
    end
})

Module.null = null

return Module