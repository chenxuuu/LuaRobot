
local Groups = require("luat_groups")

return {
check = function (data)
    for i=1,#Groups do
        if Groups[i] == data.group then return true end
    end
end,
run = function (data,sendMessage)
    local last = XmlApi.Get("repeatCheck",tostring(data.qq))
    if last == "" then
        last = {}
    else
        last = jsonDecode(last)
    end
    for i=1,#last do
        if last[i]["msg"] == data.msg and last[i]["group"] ~= data.group and os.time() - last[i]["time"] < 3600  then
            sendMessage(cq.code.at(data.qq).."\r\n您已经在别的群里发送过这条消息了，请不要重复发送。")
            return
        end
    end
    if #last >= 3 then
        table.remove(last,1)
    end
    table.insert(last,{msg=data.msg,group=data.group,time=os.time()})
    last = jsonEncode(last)
    XmlApi.Set("repeatCheck",tostring(data.qq),last)
end
}
