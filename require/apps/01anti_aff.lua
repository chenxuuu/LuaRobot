local Groups = require("luat_groups")

local function atAdmin(g)
    local admins = {}
    local m = cq.groupMemberList(g)
    for i=1,#m do
        if m[i].role ~= "member" then
            table.insert(admins,cq.code.at(m[i].user_id))
        end
    end
    return table.concat(admins," ")
end

return {--问问题
check = function (data)
    for i=1,#Groups do
        if Groups[i] == data.group then
            return data.msg:upper():find("CURL.QCLOUD.COM/.+")
            or data.msg:upper():find("WWW.ALIYUN.COM/.*USERCODE=.+")
            or data.msg:upper():find("MI.ALIYUN.COM/SHOP/.+")
        end
    end
end,
run = function (data,sendMessage)
    local check = cq.deleteMsg(data.id)
    if check ~= "ok" then
        sendMessage("有人发广告，请及时处理。"..atAdmin(data.group))
    else
        if XmlApi.Get("aff",tostring(data.qq)) == "" then
            XmlApi.Set("aff",tostring(data.qq),"warn")
        else
            cq.groupKick(data.group,data.qq,true)
            XmlApi.Set("aff",tostring(data.qq),"kick")
        end
    end
    return true
end
}
