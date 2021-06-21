return {--测试代码
check = function (data)
    return data.msg:find("%-%-lua") == 1 or LuaEnvName == "private"
end,
run = function (data,sendMessage)
    if data.qq == Utils.Setting.AdminQQ and data.msg:find("%-%-lua#") == 1 then
        local oldprint = print--临时更改print操作
        print = function (...)
            local r = {}
            for i=1,select('#', ...) do
                table.insert(r,tostring(select(i, ...)))
            end
            if #r == 0 then
                table.insert(r,"nil")
            end
            sendMessage(table.concat(r,"  "))
        end
        local result, info = pcall(function ()
            load(CQ.Decode(data.msg:sub(7)))()
        end)
        print = oldprint--改回来
        if result then
            sendMessage(cq.code.at(data.qq).."成功运行")
        else
            sendMessage(cq.code.at(data.qq).."运行失败\r\n"..tostring(info))
        end
    else
        sendMessage(cq.code.at(data.qq).."\r\n"..
            CQ.Encode(Utils.RunSandBox(CQ.Decode(data.msg))))
    end
    return true
end
}
