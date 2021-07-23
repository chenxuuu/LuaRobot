return function ()

--防止多次启动
if AppFirstStart then return end
AppFirstStart = true



local function getStarList(project)
    print("获取星星数。。。"..project)
    local info = HttpGet("https://gitee.com/api/v5/repos/"..project.."?access_token="..XmlApi.Get("settings","gitee_token"))
    if not info then return end
    local count = jsonDecode(info).stargazers_count
    local list = {}
    local sinfo = HttpGet("https://gitee.com/api/v5/repos/"..project.."/stargazers?access_token="..XmlApi.Get("settings","gitee_token").."&page="..math.floor(count/10+1).."&per_page=10")
    if not sinfo then return end
    local temp = jsonDecode(sinfo)
    for i=#temp,1,-1 do
        table.insert(list,temp[i].name)
    end
    sinfo = HttpGet("https://gitee.com/api/v5/repos/"..project.."/stargazers?access_token="..XmlApi.Get("settings","gitee_token").."&page="..math.floor(count/10).."&per_page=10")
    if not sinfo then return end
    temp = jsonDecode(sinfo)
    for i=#temp,1,-1 do
        if #list >= 10 then break end
        table.insert(list,temp[i].name)
    end
    return list,count
end

local lastList = {}
lastList = getStarList("hotdll/iRTU")
local lastListLuatOS = {}
lastListLuatOS = getStarList("openLuat/LuatOS")
sys.timerLoopStart(function ()
    local r,e = pcall(function ()
        local list = getStarList("hotdll/iRTU")
        Log.Info("lastList",table.concat(lastList,","))
        Log.Info("list",table.concat(list,","))
        if #lastList ~= 0 then
            for i=1,#list do
                local match
                for j=1,#lastList do
                    if lastList[j] == list[i] then
                        match = true
                        break
                    end
                end
                if match then break end
                cq.sendGroupMsg(952343033,list[i].."点了个小星星，谢谢~")
                cq.sendGroupMsg(1027923658,list[i].."点了个小星星，谢谢~")
            end
        end
        if #list >= 10 then
            lastList = list
        end
    end)
    if not r then print(e) end
    local r,e = pcall(function ()
        local list = getStarList("openLuat/LuatOS")
        Log.Info("lastListLuatOS",table.concat(lastListLuatOS,","))
        Log.Info("list",table.concat(list,","))
        if #lastListLuatOS ~= 0 then
            for i=1,#list do
                local match
                for j=1,#lastListLuatOS do
                    if lastListLuatOS[j] == list[i] then
                        match = true
                        break
                    end
                end
                if match then break end
                cq.sendGroupMsg(1061642968,list[i].."给LuatOS项目点了个小星星，谢谢~")
            end
        end
        if #list >= 10 then
            lastListLuatOS = list
        end
    end)
    if not r then print(e) end
end, 1*60*1000)

end
