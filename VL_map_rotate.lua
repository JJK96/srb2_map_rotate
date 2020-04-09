local map_rotation_random = CV_RegisterVar({"map_rotation_random", "Off", CV_NETVAR, CV_OnOff})

local _maps = { "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R9", "RA", "RB", "RA", "RB", "RC", "RD", "RE", "RF", "RG", "RH", "RI", "RJ", "RK", "RL", "RM", "RN", "RO", "RP", "RQ", "RR", "RS", "RT", "RU", "RV", "RW", "RX", "LC" }

local order = {}
local maps = {}
local num_maps = 0 --increased later

local char_to_num = function(char)
    return string.byte(char)-string.byte("A")
end

local to_map_number = function(extended_map_number)
    local x = extended_map_number:sub(1,1)
    local y = extended_map_number:sub(2,2)
    local p = char_to_num(x)
    local q = tonumber(y)
    if q == nil then
        q = 10 + char_to_num(y)
    end
    return ((36*p + q) + 100)
end

for k,v in pairs(_maps) do
    local mapnum = to_map_number(v)
    maps[mapnum] = true
    order[num_maps] = mapnum
    num_maps = num_maps + 1
end

local get_index = function(mapnum)
    for k,v in pairs(order) do
        if v == mapnum then
            return k
        end
    end
end

local next_map = function()
    local newindex
    if map_rotation_random.value then
        newindex = P_RandomKey(num_maps)
    else
        local index = get_index(gamemap)
        newindex = (index+1) % num_maps
    end
    print(newindex)
    return order[newindex]
end

addHook("MapLoad", function(mapnum)
    if maps[mapnum] then
        G_SetCustomExitVars(next_map())
    end
end)
