--检查GitHub的最新commit记录
function checkGitHub(url,save)
    local githubRss = asyncHttpGet(url)
    if githubRss or githubRss ~= "" then--获取成功的话
        local xml2lua = loadfile(CQApi.AppDirectory.."lua/require/xml2lua.lua")()
        --Uses a handler that converts the XML to a Lua table
        local handler = loadfile(CQApi.AppDirectory.."lua/require/xmlhandler/tree.lua")()
        local parser = xml2lua.parser(handler)
        parser:parse(githubRss)
        local lastUpdate = handler.root.feed.updated
        if lastUpdate and lastUpdate ~= XmlApi.Get("settings",save) then
            XmlApi.Set("settings",save,lastUpdate)
            for i,j in pairs(handler.root.feed.entry) do
                --缩短网址
                local shortUrl = asyncHttpPost("https://git.io/create","url="..j.link._attr.href:urlEncode())
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
--检查GitHub的最新发布版本记录
function checkGitRelease(url,save)
    local release = asyncHttpGet(url)
    local d,r,e = jsonDecode(release)
    if not r or not d then return end
    if d.id and tostring(d.id) ~= XmlApi.Get("settings",save) then
        XmlApi.Set("settings",save,tostring(d.id))
        --缩短网址
        local shortUrl = asyncHttpPost("https://git.io/create","url="..d.html_url:urlEncode())
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

--获取延时
local function getDelay(h,m,s)
    local time = os.date("*t")
    time.hour = h
    time.min = m
    time.sec = s
    local ts = os.time(time)
    if os.time() < ts then
        return ts - os.time()
    else
        return ts - os.time() + 3600 * 24
    end
end

return function ()
    --防止多次启动
    if AppFirstStart then return end
    AppFirstStart = true

    --定时事件
    CQLog:Debug("lua插件","定时任务")
    sys.taskInit(function ()
        while true do
            local delay = getDelay(20,0,0)--晚上八点
            CQLog:Debug("lua插件","定时任务，延时"..delay.."秒")
            sys.wait(delay * 1000)

            if XmlApi.Get("settings","help_notify") == "on" then
                local time = os.date("*t")
                local listF = require("helpList")
                local list,l = listF(os.time()+3600*24)--获取明天的
                if l == 1 then--一轮了
                    local listm = {"下面是五天的值班顺序："}
                    for i=1,5 do
                        table.insert(listm,"第"..i.."天"..
                            Utils.CQCode_At(list[i*2])..
                            Utils.CQCode_At(list[i*2-1])
                        )
                    end
                    CQApi:SendGroupMessage(941645382, table.concat(listm, "\r\n"))
                end
                CQApi:SendGroupMessage(941645382, "明天应由"..
                    Utils.CQCode_At(list[l*2])..
                    Utils.CQCode_At(list[l*2-1])..
                    "值班")
            end

            CQLog:Debug("lua插件","定时任务开始执行")
        end
    end)

    sys.taskInit(function ()
        while true do
            local delay = getDelay(8,30,0)--早上八点半
            CQLog:Debug("lua插件","定时任务，延时"..delay.."秒")
            sys.wait(delay * 1000)

            if XmlApi.Get("settings","help_notify") == "on" then
                local time = os.date("*t")
                local listF = require("helpList")
                local list,l = listF(os.time())--获取今天的
                CQApi:SendGroupMessage(941645382, "今天应由"..
                    Utils.CQCode_At(list[l*2])..
                    Utils.CQCode_At(list[l*2-1])..
                    "值班")
            end

            CQLog:Debug("lua插件","定时任务开始执行")
        end
    end)


    --检查GitHub更新
    local Groups = {
        423804427,--2
        851800257,--4g
        --952343033,--irtu
        201848376,
        604902189,--1
        670342655,--task
    }
    --统一提醒检查处理
    local function gitCheck(f,url,tag,text)
        print("check git",tag)
        local r,t = f(url,tag)
        if r and t then
            local text = text.."\r\n"..t
            for i=1,#Groups do
                CQApi:SendGroupMessage(Groups[i], text)
            end
        end
    end
    sys.taskInit(function ()
        while true do
            CQLog:Debug("lua插件","检查GitHub更新，开始执行")
            local pr,info = pcall(function ()
                gitCheck(checkGitHub,
                    "https://github.com/openLuat/Luat_2G_RDA_8955/commits/master.atom",
                    "2g",
                    "发现2G lua代码在GitHub上有更新")
                gitCheck(checkGitHub,
                    "https://github.com/openLuat/Luat_4G_ASR_1802/commits/master.atom",
                    "4g",
                    "发现4G 1802 lua代码在GitHub上有更新")
                gitCheck(checkGitHub,
                    "https://github.com/openLuat/Luat_4G_ASR_1802S/commits/master.atom",
                    "4gs",
                    "发现4G 1802s lua代码在GitHub上有更新")
                gitCheck(checkGitRelease,
                    "https://api.github.com/repos/openLuat/Luat_2G_RDA_8955/releases/latest",
                    "2gRelease",
                    "发现2g底层在GitHub上更新")
                gitCheck(checkGitRelease,
                    "https://api.github.com/repos/openLuat/Luat_4G_ASR_1802/releases/latest",
                    "4gRelease",
                    "发现4g 1802底层在GitHub上更新")
                gitCheck(checkGitRelease,
                    "https://api.github.com/repos/openLuat/Luat_4G_ASR_1802S/releases/latest",
                    "4gsRelease",
                    "发现4g 1802s底层在GitHub上更新")
                local r,t = checkGitHub("https://github.com/Jie2GG/Native.Csharp.Frame/commits/Final.atom","Native.sdk")
                if r and t then CQApi:SendGroupMessage(711841640, "发现sdk代码在GitHub上有更新\r\n"..t) end
            end)
            if not pr then print(info) end
            CQLog:Debug("lua插件","检查GitHub更新，结束执行")
            sys.wait(600*1000)
        end
    end)
end
