return {--问问题
check = function (data)
    return LuaEnvName == "private" and data.msg:find("%[CQ:forward,id=")
end,
run = function (data,sendMessage)
    cq.sendPrivateMsg(961726194,data.msg)
    sendMessage("收集完成！")
    return true
end
}
