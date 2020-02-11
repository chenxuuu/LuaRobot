return {--查下次的人
check = function (data)
    return data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") and data.group == 941645382
end,
run = function (data,sendMessage)
    if data.msg:find("开") then
        XmlApi.Set("settings","help_notify","on")
        sendMessage("自动提醒已打开")
    elseif data.msg:find("关") then
        XmlApi.Set("settings","help_notify","off")
        sendMessage("自动提醒已关闭")
    else
        local listF = require("helpList")
        local list,l = listF(os.time())--获取五天的
        local listm = {"下面是五天的值班顺序："}
        for i=1,5 do
            table.insert(listm,"第"..i.."天"..
                Utils.CQCode_At(list[i*2])..
                Utils.CQCode_At(list[i*2-1])..
                (i == l and "（今天）" or "")
            )
        end
        table.insert(listm,"今日日期："..os.date("%Y-%m-%d"))
        sendMessage(table.concat(listm, "\r\n")..
            "\r\n自动提醒状态："..XmlApi.Get("settings","help_notify"))
    end
    return true
end,
}
