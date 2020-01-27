return {--查下次的人
check = function (data)
    return data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") and data.group == 941645382
end,
run = function (data,sendMessage)
    local listF = require("helpList")
    local list = listF(os.time())--获取一周的
    local listm = {
        "下面是这七天的值班顺序：",
        "周日"..Utils.CQCode_At(list[1]),
        "周一"..Utils.CQCode_At(list[2]),
        "周二"..Utils.CQCode_At(list[3]),
        "周三"..Utils.CQCode_At(list[4]),
        "周四"..Utils.CQCode_At(list[5]),
        "周五"..Utils.CQCode_At(list[6]),
        "周六"..Utils.CQCode_At(list[7]),
    }
    sendMessage(table.concat(listm, "\r\n"))
    return true
end,
}
