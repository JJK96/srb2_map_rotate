local map_rotation_random = CV_RegisterVar({"map_rotation_random", "Off", CV_NETVAR, CV_OnOff})

local rotation_maps = ""
local order = {}
local shuffled = false
local maps = {}
local num_maps = 0 --increased later

local print_table = function(table)
    for k,v in pairs(table) do
        print(k .. ': ' .. v)
    end
end


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

local shuffle = function(tbl)
  for i = #tbl, 2, -1 do
    local j = P_RandomKey(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

local get_index = function(table, mapnum)
    for k,v in pairs(table) do
        if v == mapnum then
            return k
        end
    end
end

COM_AddCommand("shuffle_maps", function(player, args)
    shuffled = shuffle(shuffled)
end)

local next_map = function()
    local newindex = nil
    local map_table = order
    local index = get_index(map_table, gamemap)
    if map_rotation_random.value then
        if get_index(shuffled, gamemap) == num_maps-1 then
            shuffled = shuffle(shuffled)
            newindex = 0
        end
        map_table = shuffled
        index = get_index(map_table, gamemap)
    end
    if newindex == nil then
        newindex = (index+1) % num_maps
    end
    return map_table[newindex]
end

addHook("MapLoad", function(mapnum)
    if maps[mapnum] then
        G_SetCustomExitVars(next_map())
    end
end)

COM_AddCommand("rotation_maps", function(player, args)
    if args == nil then
        local usage = "rotation_maps <maps>:\nto set the maps that should be in the rotation.\ne.g. rotation_maps \"R0 R1 R2 RX\""
        CONS_Printf(player, usage)
    else
        num_maps = 0
        order = {}
        shuffled = {}
        maps = {}
        rotation_maps = args
        for map in string.gmatch(args, "%S+") do
            local mapnum = to_map_number(map)
            maps[mapnum] = true
            order[num_maps] = mapnum
            shuffled[num_maps] = mapnum
            num_maps = num_maps + 1
        end
        shuffled = shuffle(shuffled)
    end
    local string = "Rotation maps: " .. rotation_maps
    CONS_Printf(player, string)
end)
