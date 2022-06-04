return {--问问题
check = function (data)
    return data.msg:find("帮.+找.+") == 1 and data.msg:len() > 9
end,
run = function (data,sendMessage)
    local u,s = data.msg:match("帮(.+)找(.+)")
    if u and s then
        sendMessage("我帮"..u.."搜了一下"..s.."的资料：\r\nhttps://wiki.luatos.com/search.html?check_keywords=yes&area=default&q="..string.urlEncode(s))
    end
    return true
end
}
