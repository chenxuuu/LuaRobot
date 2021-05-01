local function checkQQInfo(qq,msg)
    local info = cq.qqInfo(qq)
    return info.login_days > 300 or
        (info.login_days > 60 and info.level >= 20) or
        (msg or ""):find(tostring(qq))
end


return function (data)
    if XmlApi.Get("joinCheck",tostring(data.group)) == "on"
        and XmlApi.Get("joinCheck",tostring(data.qq).."qq") == "" then
        if not checkQQInfo(data.qq,data.msg) then
            cq.groupAddRequest(data.tag,"add",false,"请在加群申请里写上自己的qq号，以证明你不是机器人")
            return
        end
        cq.groupAddRequest(data.tag,"add",true)
        sys.taskInit(function()
            sys.wait(1000)
            local count = 0
            while cq.groupBan(data.group,data.qq,600) ~= "ok" do
                count = count + 1
                if count > 20 then
                    cq.groupKick(data.group,data.qq,false)
                    return
                end
                sys.wait(500)
            end

            local a,b = math.random(0,10),os.date("*t").day
            local sent = cq.sendGroupMsg(data.group,cq.code.at(data.qq)..
            "欢迎加入本群，请在100秒内*私聊我*发送答案，不然会被移出本群\r\n"..
                "问题："..a.."+今天的日期 等于多少？")
            XmlApi.Set("joinCheck",tostring(data.qq).."qq","wait")
            local pass
            for i=1,120 do
                sys.wait(1000)
                pass = tonumber(XmlApi.Get("joinCheck",tostring(data.qq).."qq")) == a+b
                if pass then break end
            end
            cq.deleteMsg(sent)
            if pass then
                cq.groupBan(data.group,data.qq,0)
            else
                cq.groupKick(data.group,data.qq,false)
            end
            XmlApi.Delete("joinCheck",tostring(data.qq).."qq")
        end)
    end
end
