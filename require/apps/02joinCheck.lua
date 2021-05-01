--local Groups = dofile("luat_groups")

return {--问问题
check = function (data)
    return LuaEnvName == "private" and XmlApi.Get("joinCheck",tostring(data.qq).."qq") ~= ""
end,
run = function (data,sendMessage)
    sendMessage("已收到验证信息，如果结果正确，会自动解除禁言。时间到达之前，你可以修改本答案")
    XmlApi.Set("joinCheck",tostring(data.qq).."qq",data.msg)
    return true
end
}
