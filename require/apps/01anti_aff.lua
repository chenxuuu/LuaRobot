local Groups = require("luat_groups")

local affMatch = {
    "CURL.QCLOUD.COM/.+",
    "WWW.ALIYUN.COM/.*USERCODE=.+",
    "MI.ALIYUN.COM/SHOP/.+",
    "日赚%d",
    "时赚%d",
    "流量卡.*[^%d]1%d%d%d%d%d%d%d%d%d%d",
    "1%d%d%d%d%d%d%d%d%d%d[^%d].*流量卡",
    "www.jiepei.com/%?.*g=.+",
}

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

return {--检查广告
check = function (data)
    for i=1,#Groups do
        if Groups[i] == data.group then
            for _,j in pairs(affMatch) do
                if data.msg:upper():find(j) then
                    return true
                end
            end
        end
    end
end,
run = function (data,sendMessage)
    local check = cq.deleteMsg(data.id)
    if check ~= "ok" then
        sendMessage("有人发广告，撤回失败，请及时处理。"..atAdmin(data.group))
    else
        cq.groupKick(data.group,data.qq,true)
    end
    XmlApi.Set("aff_qq",tostring(data.qq),"ad")
    return true
end
}
