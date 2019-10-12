--[[
每分钟会被触发一次的脚本


下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

local time = os.date("*t")

--提醒第二天的东西
if time.hour == 20 and time.min == 0 then
    local listF = require("app.helpList")
    local list = listF(os.time()+3600*24)--获取明天的
    if time.wday == 7 then--周六了
        local listm = {
            "下面七天的值班顺序：",
            "周日"..cqCode_At(list[1]),
            "周一"..cqCode_At(list[2]),
            "周二"..cqCode_At(list[3]),
            "周三"..cqCode_At(list[4]),
            "周四"..cqCode_At(list[5]),
            "周五"..cqCode_At(list[6]),
            "周六"..cqCode_At(list[7]),
        }
        cqSendGroupMessage(941645382, table.concat(listm, "\r\n"))
    end
    local day = time.wday + 1
    if day == 8 then day = 1 end
    cqSendGroupMessage(941645382, "明天应由"..cqCode_At(list[day]).."值班")
end
--提醒今天的
if time.hour == 8 and time.min == 30 then
    local listF = require("app.helpList")
    local list = listF(os.time())--获取今天的
    cqSendGroupMessage(941645382, "今天应由"..cqCode_At(list[time.wday]).."值班")
end

function checkGitHub(url,save)
    local githubRss = apiHttpGet(url)
    if githubRss or githubRss ~= "" then--获取成功的话
        local xml2lua = loadfile(apiGetPath().."/data/app/com.papapoi.ReceiverMeow/lua/require/xml2lua.lua")()
        --Uses a handler that converts the XML to a Lua table
        local handler = loadfile(apiGetPath().."/data/app/com.papapoi.ReceiverMeow/lua/require/xmlhandler/tree.lua")()
        local parser = xml2lua.parser(handler)
        parser:parse(githubRss)
        local lastUpdate = handler.root.feed.updated
        if lastUpdate and lastUpdate ~= apiXmlGet("settings",save) then
            apiXmlSet("settings",save,lastUpdate)
            for i,j in pairs(handler.root.feed.entry) do
                --缩短网址
                local shortUrl = apiHttpPost("https://git.io/create","url="..j.link._attr.href:urlEncode())
                shortUrl = (not shortUrl or shortUrl == "") and j.link._attr.href or "https://biu.papapoi.com/"..shortUrl

                --返回结果
                local toSend = "更新时间(UTC)："..(lastUpdate):gsub("T"," "):gsub("Z"," ").."\r\n"..
                "提交内容："..j.title.."\r\n"..
                "查看变动代码："..shortUrl
                return true,toSend
            end
        end
    end
end


function checkGitRelease(url,save)
    local release = apiHttpGet(url)
    local d,r,e = jsonDecode(release)
    if not r then return end
    if d.id and tostring(d.id) ~= apiXmlGet("settings",save) then
        apiXmlSet("settings",save,tostring(d.id))
        --缩短网址
        local shortUrl = apiHttpPost("https://git.io/create","url="..d.html_url:urlEncode())
        shortUrl = (not shortUrl or shortUrl == "") and d.html_url or "https://biu.papapoi.com/"..shortUrl

        --返回结果
        local toSend = "更新时间(UTC)："..(d.created_at):gsub("T"," "):gsub("Z"," ").."\r\n"..
        "版本："..d.tag_name.."\r\n"..
        d.name.."\r\n"..
        d.body.."\r\n"..
        "查看更新："..shortUrl
        return true,toSend
    end
end

--检查GitHub项目是否有更新
if time.min % 10 == 0 then--十分钟检查一次
    local r,t = checkGitHub("https://github.com/openLuat/Luat_2G_RDA_8955/commits/master.atom","2g")
    if r and t then
        local text = "发现2G lua代码在GitHub上有更新\r\n"..t
        cqSendGroupMessage(952343033, text)
        cqSendGroupMessage(604902189, text)
        cqSendGroupMessage(670342655, text)
    end
    r,t = checkGitHub("https://github.com/openLuat/Luat_4G_ASR_1802/commits/master.atom","4g")
    if r and t then
        local text = "发现4G lua代码在GitHub上有更新\r\n"..t
        cqSendGroupMessage(952343033, text)
        cqSendGroupMessage(604902189, text)
        cqSendGroupMessage(670342655, text)
        cqSendGroupMessage(851800257, text)--4g群
    end

    r,t = checkGitHub("https://github.com/Jie2GG/Native.Csharp.Frame/commits/Final.atom","Native.sdk")
    if r and t then
        local text = "发现sdk代码在GitHub上有更新\r\n"..t
        cqSendGroupMessage(711841640, text)
    end

    r,t = checkGitRelease("https://api.github.com/repos/openLuat/Luat_2G_RDA_8955/releases/latest","2gRelease")
    if r and t then
        local text = "发现2g底层在GitHub上更新\r\n"..t
        cqSendGroupMessage(952343033, text)
        cqSendGroupMessage(604902189, text)
        cqSendGroupMessage(670342655, text)
    end

    r,t = checkGitRelease("https://api.github.com/repos/openLuat/Luat_4G_ASR_1802/releases/latest","4gRelease")
    if r and t then
        local text = "发现4g底层在GitHub上更新\r\n"..t
        cqSendGroupMessage(952343033, text)
        cqSendGroupMessage(604902189, text)
        cqSendGroupMessage(670342655, text)
        cqSendGroupMessage(851800257, text)--4g群
    end
end

