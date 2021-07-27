local function checkQQInfo(qq,msg)
    local info = cq.qqInfo(qq)
    return XmlApi.Get("aff_qq",tostring(qq)) == "" or
        info.login_days > 300 or
        (info.login_days > 60 and info.level >= 20) or
        (msg or ""):find(tostring(qq))
end


return function (data)
    if XmlApi.Get("joinCheck",tostring(data.group)) == "on"
        and XmlApi.Get("joinCheck",tostring(data.qq).."qq") == "" then
        if not checkQQInfo(data.qq,data.msg) then
            cq.groupAddRequest(data.tag,"add",false,"请在加群申请里写上自己的qq号，以证明你不是机器人，谢谢")
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

            local a,b = math.random(30,99),math.random(0,10)
            local sent = {}
            table.insert(sent,cq.sendGroupMsg(data.group,cq.code.at(data.qq)..
            "欢迎加入本群，请在300秒内*私聊我*发送答案，不然会被移出本群\r\n"..
                "问题：假设有"..a.."个820开发板，每个袋子只能装"..b.."个，至少要多少个袋子才能装得下？"))
            XmlApi.Set("joinCheck",tostring(data.qq).."qq","wait")
            local pass
            for i=1,300 do
                sys.wait(1000)
                pass = tonumber(XmlApi.Get("joinCheck",tostring(data.qq).."qq")) == (a-1)//b+1
                if pass then break end
                if i%100==0 and i~=300 then
                    table.insert(sent,cq.sendGroupMsg(data.group,cq.code.at(data.qq)..
                    "请在"..tostring(300-i).."秒内\r\n*私聊我*\r\n发送答案\r\n"..
                    "问题：假设有"..a.."个820开发板，每个袋子只能装"..b.."个，至少要多少个袋子才能装得下？"))
                end
            end
            for _,j in pairs(sent) do
                cq.deleteMsg(j)
            end
            if pass then
                cq.groupBan(data.group,data.qq,0)
            else
                cq.groupKick(data.group,data.qq,false)
            end
            XmlApi.Delete("joinCheck",tostring(data.qq).."qq")
        end)
    end
end
