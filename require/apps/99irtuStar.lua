local admin = {
    [80005350] = 1,
    [891652120] = 1,
    [961726194] = 1,
}

local function getStarList()
    local info = HttpGet("https://gitee.com/api/v5/repos/hotdll/iRTU?access_token="..XmlApi.Get("settings","gitee_token"))
    local count = jsonDecode(info).stargazers_count
    local list = {}
    local sinfo = HttpGet("https://gitee.com/api/v5/repos/hotdll/iRTU/stargazers?access_token="..XmlApi.Get("settings","gitee_token").."&page="..math.floor(count/10+1).."&per_page=10")
    local temp = jsonDecode(sinfo)
    for i=#temp,1,-1 do
        table.insert(list,temp[i].name)
    end
    local sinfo = HttpGet("https://gitee.com/api/v5/repos/hotdll/iRTU/stargazers?access_token="..XmlApi.Get("settings","gitee_token").."&page="..math.floor(count/10).."&per_page=10")
    local temp = jsonDecode(sinfo)
    for i=#temp,1,-1 do
        if #list >= 10 then break end
        table.insert(list,temp[i].name)
    end
    return "最近有这些朋友点了star：\r\n"..table.concat(list,"、").."\r\n现在有"..count.."个星星啦"
end

return {
check = function (data)
    return data.group == 1027923658 or data.group == 952343033
end,
run = function (data,sendMessage)
    if XmlApi.Get("starCheck",tostring(data.qq).."qq") ~= "ok" and XmlApi.Get("starCheck",tostring(data.qq)) ~= tostring(math.floor(os.time()/(3600*24))) then
        XmlApi.Set("starCheck",tostring(data.qq),tostring(math.floor(os.time()/(3600*24))))
        sendMessage("尊敬的"..cq.code.at(data.qq).."：\r\n"..
        "为了便于更好地提供支持服务，即日起，将只为给irtu的gitee项目点过star的用户进行免费支持，未点star的用户提问将忽略，禁止白嫖。\r\n"..
        "只要点个star我们就是朋友了，点击star地址：https://gitee.com/hotdll/iRTU\r\n"..
        "[CQ:image,file=1247a270c68a9b3ce179b805f213d4df.image,url=http://c2cpicdw.qpic.cn/offpic_new/961726194//961726194-3541165760-1247A270C68A9B3CE179B805F213D4DF/0?term=3]")
    end
    if data.msg:find("star") and admin[data.qq] and data.msg:find("CQ:at") then
        local qq = data.msg:match("(%d+)")
        XmlApi.Set("starCheck",tostring(qq).."qq","ok")
        sendMessage("感谢"..cq.code.at(qq).."朋友的star！")
    end
    if data.msg:lower() == "查star" then
        sendMessage(cq.code.at(data.qq)..getStarList())
    end
    return true
end
}
