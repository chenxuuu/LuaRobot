return {--问问题
check = function (data)
    return data.msg:find("帮他搜") == 1 and data.msg:len() > 9
end,
run = function (data,sendMessage)
    local s = data.msg:sub(10)
    sendMessage(s.."的资料都不会找？这么搜，懂了吗\r\nhttps://doc.openluat.com/search/"..string.urlEncode(s))
    return true
end
}
