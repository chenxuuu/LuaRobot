--人员列表
local members = {
    1760580801,--盛
    1468647147,--毅
    124200583,--廖
    961726194,--晨
}

local mo = {
    290927815,--Delectate
    80005350,--稀饭
    389627265,--Wendal
}

return function (time)
    local t = os.date("*t",time)
    local day = t.yday - t.wday--取整，每周唯一的某一天
    math.randomseed(day+t.year*1000)--固定随机数种子，使结果保持一致性

    table.insert(members,1,table.remove(mo,math.random(1,#mo)))--周日
    table.insert(members,table.remove(mo,math.random(1,#mo)))--周六
    table.insert(members,2,mo[1])--剩下的

    --打乱顺序
    for i=2,#members-1 do
        local random = math.random(2,#members-1)
        local temp = members[i]
        members[i] = members[random]
        members[random] = temp
    end

    return members
end
