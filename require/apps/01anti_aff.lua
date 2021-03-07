--local Groups = dofile("luat_groups")

return {--问问题
check = function (data)
    --for i=1,#Groups do
    --    if Groups[i] == data.group then
            return data.msg:find("curl.qcloud.com/.+") or data.msg:find("www.aliyun.com/.*userCode=.+")
    --    end
    --end
end,
run = function (data,sendMessage)
    cq.deleteMsg(data.id)
    if XmlApi.Get("aff",tostring(data.qq)) == "" then
        sendMessage(cq.code.at(data.qq).."请勿发送推广链接，该警告只提醒一次")
        XmlApi.Set("aff",tostring(data.qq),"warn")
    else
        cq.groupKick(data.group,data.qq,true)
        XmlApi.Set("aff",tostring(data.qq),"kick")
    end
    return true
end
}
