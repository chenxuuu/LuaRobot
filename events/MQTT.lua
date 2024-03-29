--[[
处理MQTT各消息的逻辑

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

--对各个topic进行订阅
local function subscribe()
    local topics = {
        "luaRobot/image",
        "luaRobot/record",
        "luaRobot/text",
        XmlApi.Get("settings","ci_notify"),
    }
    for i=1,#topics do
        local count = 0
        while true do
            local result = Mqtt.Subscribe(topics[i], 0)
            Log.Debug(StateName,"MQTT订阅："..(result and "成功" or "失败")..","..topics[i])
            count = count + 1
            if count > 10 or result then
                break
            end
        end
    end
end

return function (message)
    --连接成功，马上订阅
    if message.t == "connected" then subscribe() return end

    if message.t == "receive" then
        Log.Debug(StateName,"MQTT收到消息："..message.topic..","..message.payload)
        if message.topic == "luaRobot/image" then

        elseif message.topic == "luaRobot/record" then
            --cq.sendPrivateMsg(961726194,cq.code.record(message.payload))
        elseif message.topic == "luaRobot/text" then

        elseif message.topic == XmlApi.Get("settings","ci_notify") then
            local msg = message.payload
            local url = msg:match(" (https://github.com/openLuat/LuatOS/actions/runs/%d+)\r*\n")
            if url then
                local para = jsonEncode({url=url})
                local su = HttpPost("https://xn--ugt.cc/api/set.php",para)
                local j,r = jsonDecode(su)
                if r and j then
                    msg = msg:gsub("https://github.com/openLuat/LuatOS/actions/runs/%d+\r*\n",j.content.url.."\r\n")
                end
            end
            cq.sendGroupMsg(772800628,"编译炸了，快来看看：\r\n"..msg)
        end
    end
end

