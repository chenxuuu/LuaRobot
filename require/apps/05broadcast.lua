local Groups = require("luat_groups")

return {--问问题
check = function (data)
    return data.msg:find("群发") == 1 and
    LuaEnvName == "private" and
    XmlApi.Get("adminList",tostring(data.qq)) == "admin"
end,
run = function (data,sendMessage)
    sys.taskInit(function()
        sendMessage("开始发送到"..#Groups.."个群。。")
        for i,j in pairs(Groups) do
            cq.sendGroupMsg(j,data.msg:sub(7))
            sys.wait(1000)
        end
        sendMessage("发完了")
    end)
    return true
end
}
