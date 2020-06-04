local Groups = {
    423804427,--2
    851800257,--4g
    952343033,--irtu
    201848376,
    604902189,--1
    670342655,--task
    1092305811,--cat1
}

return {
check = function (data)
        if LuaEnvName == "private" then
            return true
        end
    for i=1,#Groups do
        if Groups[i] == data.group then return true end
    end
end,
run = function (data,sendMessage)
    local time = os.date("*t")
    if time.hour < 8 or time.hour > 18 or time.wday == 1 or time.wday == 7 then
        if LuaEnvName == "private" then
            sendMessage("机器人工作时间为周一至周五 8:00-18:00")
        end
        return true
    end
end
}
