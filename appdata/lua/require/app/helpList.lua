--人员列表
local members = {
    290927815,
    80005350,
    1760580801,
    1468647147,
    124200583,
    739657917,
    389627265
}

return function (time)
    local t = os.date("*t",time)
    local day = t.yday - t.wday--取整，每周唯一的某一天
    math.randomseed(day+t.year*1000)--固定随机数种子，使结果保持一致性

    --打乱顺序
    for i=1,#members do
        local random = math.random(1,#members)
        local temp = members[i]
        members[i] = members[random]
        members[random] = temp
    end

    return members
end
