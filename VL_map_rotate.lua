local map_rotation_random = CV_RegisterVar({"map_rotation_random", "Off", CV_NETVAR, CV_OnOff})

local rotation_maps = ""
local order = {}
local maps = {}
local num_maps = 0 --increased later

local char_to_num = function(char)
    return string.byte(char)-string.byte("A")
end

local to_map_number = function(extended_map_number)
    local num = tonumber(extended_map_number)
    if num != nil then
        return num
    end
    local x = extended_map_number:sub(1,1)
    local y = extended_map_number:sub(2,2)
    local p = char_to_num(x)
    local q = tonumber(y)
    if q == nil then
        q = 10 + char_to_num(y)
    end
    return ((36*p + q) + 100)
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
    return order[newindex]
end

addHook("MapLoad", function(mapnum)
    if maps[mapnum] then
        G_SetCustomExitVars(next_map())
    end
end)

COM_AddCommand("rotation_maps", function(player, args)
    if args == nil then
        local string = "Rotation maps: " .. rotation_maps
        local usage = "rotation_maps <maps>:\nto set the maps that should be in the rotation.\ne.g. rotation_maps \"R0 R1 R2 RX\""
        CONS_Printf(player, string)
        CONS_Printf(player, usage)
    else
        rotation_maps = args
        for map in string.gmatch(args, "%S+") do
            local mapnum = to_map_number(map)
            maps[mapnum] = true
            order[num_maps] = mapnum
            num_maps = num_maps + 1
        end
    end
end)
