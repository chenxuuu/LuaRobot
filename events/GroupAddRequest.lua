return function (data)
    if XmlApi.Get("joinCheck",tostring(data.group)) == "on"
        and XmlApi.Get("joinCheck",tostring(data.qq).."qq") == "" then
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

            local a,b = math.random(0,100),math.random(0,100)
            cq.sendGroupMsg(data.group,cq.code.at(data.qq)..
            "欢迎加入本群，请在120秒内向我私聊发送答案，不然会被移出本群\r\n"..
                "问题："..a.."+"..b.."等于多少？")
            XmlApi.Set("joinCheck",tostring(data.qq).."qq","wait")
            sys.wait(120*1000)
            if tonumber(XmlApi.Get("joinCheck",tostring(data.qq).."qq")) ~= a+b then
                cq.groupKick(data.group,data.qq,false)
            end
            cq.groupBan(data.group,data.qq,0)
            XmlApi.Delete("joinCheck",tostring(data.qq).."qq")
        end)
    end
end
