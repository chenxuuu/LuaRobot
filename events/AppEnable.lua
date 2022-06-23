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
end, 1*60*1000)

local notify_list = require("luat_notify")

for group,info in pairs(notify_list) do
    sys.taskInit(function()
        while true do
            local delay = math.random(info.duration[1],info.duration[2])
            print("群"..group.."消息延时"..delay.."秒发送")
            sys.wait(delay*1000)
            local now = os.date("*t").hour
            if now >= info.time[1] and now <= info.time[2] then
                cq.sendGroupMsg(group,"温馨小提示~~o(*￣▽￣*)o~~\r\n"..info.text[math.random(1,#info.text)])
            end
        end
    end)
end

end
