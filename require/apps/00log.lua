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
    sys.taskInit(function()
        saveLog(data.group,getName(data.group,data.qq).."("..tostring(data.qq)..")",data.msg)
    end)
    Mqtt.Publish("luaRobot/message/"..data.group, jsonEncode({
        group = tostring(data.group),
        qq = tostring(data.qq),
        msg = data.msg:gsub("%[.-%]","[特殊]"):sub(1,100),--限制前100字
    }), 0)
end
}
