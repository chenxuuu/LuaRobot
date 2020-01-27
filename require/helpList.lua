--人员列表
local members = {
    1760580801,--盛
    1468647147,--毅
    124200583,--廖
}

local mo = {
    290927815,--Delectate
    80005350,--稀饭
    389627265,--Wendal
    64034373,--柴
}

return function (time)
    local t = os.date("*t",time)
    t.hour = 0 t.min = 0 t.sec = 0
    local ts = os.time(t) - t.wday*3600*24--取整，每周唯一的某一天
    math.randomseed(ts)--固定随机数种子，使结果保持一致性

    table.insert(members,1,table.remove(mo,math.random(1,#mo)))--周日
    table.insert(members,table.remove(mo,math.random(1,#mo)))--周六
    for i=1,#mo do--剩下的
        table.insert(members,2,mo[i])
    end

    --打乱顺序
    for i=2,#members-1 do
        local random = math.random(2,#members-1)
        local temp = members[i]
        members[i] = members[random]
        members[random] = temp
    end

    return members
end
