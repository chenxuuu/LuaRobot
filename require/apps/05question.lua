--机器人qq
local robot_qq = cq.loginInfo().qq

--触发列表
local d = {
    ["低功耗"] = {
        ["cat1"] = "合宙Cat1超低功耗方案http://ask.openluat.com/article/2081/0",
        ["cat4"] = "低功耗实践指南http://ask.openluat.com/article/437/0",
        ["2g"] = "低功耗实践指南http://ask.openluat.com/article/437/0",
    },
}

return {--问问题
check = function (data)
    return (data.msg:find("%[CQ:at,qq="..robot_qq.."%]") or LuaEnvName == "private") and
    data.msg:gsub("%[CQ:.-%]",""):len() > 1
end,
run = function (data,sendMessage)
    --原始信息
    local m = data.msg:gsub("%[CQ:.-%]"," ")
    m = CQ.Decode(m)
    while m:sub(1,1) == " " do m = m:sub(2) end

    local f
    for i,j in pairs(d) do
        if m:find(i) then
            local r = {}
            for a,b in pairs(j) do
                if m:find(a) then
                    sendMessage(cq.code.at(data.qq).."找到了以下资料\r\n"..b)
                    f = true--找到了
                    break
                end
                table.insert(r,a..":"..b)
            end
            if f then break end
            sendMessage(cq.code.at(data.qq).."没找到准确的，参考下资料吧\r\n"..table.concat(r,"\r\n"))
            f = true
        end
    end
    if not f then
        sendMessage(cq.code.at(data.qq).."没找到相关信息，搜一下？\r\nhttp://doc.openluat.com/search/"..m:urlEncode())
    end
    return true
end
}
