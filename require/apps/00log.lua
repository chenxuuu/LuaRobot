local groupName = {
    [201848376] = "合宙群01",
    [604902189] = "合宙群02",
    [1092305811] = "合宙群03",
    [877164555] = "合宙群04",
    [851800257] = "合宙群05",
    [387396364] = "合宙群06",
    [423804427] = "合宙群07",
    [823812859] = "合宙群08",
    [679177589] = "WiFi群",
    [967368887] = "合宙群10",
    [627242078] = "合宙群11",
    [799971630] = "合宙群12",
    [151645843] = "合宙群13",
    [710412579] = "合宙群14",
    [553477984] = "合宙群15",
    [952343033] = "iRTU1群",
    [1027923658] = "iRTU2群",
    [1061642968] = "LuatOS群",
    [827963649] = "CPE群",
    [489193389] = "GPSTracker群",
    [221504157] = "训练营一期",
    [1108271783] = "魔盒",
}

local function saveLog(g,q,t)
    local temp = 1
    while temp < #t do
        local ss,ee = t:find("%[CQ:image,file=.-,url=.-%]",temp)
        if ss then
            t = t:gsub("%[CQ:image,file=.-%]","[image"..t:match("%[CQ:image,file=.-,url=(.-)%]").."]",1)
            temp = ee
        else
            break
        end
    end
    asyncHttpGet("https://qq.papapoi.com/qqmsg/post.php?g="..string.urlEncode(tostring(g))..
    "&q="..string.urlEncode(tostring(q))..
    "&m="..string.urlEncode((Utils.ConvertBase64(CQ.Decode(t)))))
    print("已上传消息记录")
end

local Groups = require("luat_groups")

local function getName(group,qq)
    local info = cq.groupMemberInfo(group,qq)
    return info.card ~= "" and info.card or info.nickname
end

return {
check = function (data)
    for i=1,#Groups do
        if Groups[i] == data.group then return true end
    end
end,
run = function (data,sendMessage)
    local qqName = getName(data.group,data.qq)
    sys.taskInit(function()
        saveLog(data.group,qqName.."("..tostring(data.qq)..")",data.msg)
    end)
    if groupName[data.group] then
        Mqtt.Publish("luaRobot/message/"..data.group, jsonEncode({
            group = tostring(data.group),
            qq = qqName,
            msg = data.msg:gsub("%[.-%]","[特殊]"):sub(1,100),--限制前100字
            name = groupName[data.group],
        }), 0)
    end
end
}
