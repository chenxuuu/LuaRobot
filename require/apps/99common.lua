return {--通用回复
check = function ()
    return true
end,
run = function (data,sendMessage)
    if data.qq == 1000000 then
        return true
    end
    local replyCommon = XmlApi.RandomGet("common",data.msg)
    if replyCommon ~= "" then
        sendMessage(replyCommon)
        return true
    end
    return false
end
}
