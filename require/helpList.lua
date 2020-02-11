local list = {
    290927815,--Delectate
    80005350,--稀饭
    389627265,--Wendal
    64034373,--柴
    1760580801,--盛
    1468647147,--毅
    124200583,--廖
    2362883341,--金
    278610562,--朱
    961726194,--晨
}

return function (time)
    --取整，每五天唯一的某一天，第42天时必须为99，且为第一天
    local ts = os.date("*t",time).yday - 2
    local l = ts%5 + 1--偏移
    ts = ts - (ts%5) + 59
    math.randomseed(ts)--固定随机数种子，使结果保持一致性
    local members = {}
    for i=1,#list do--临时存起来
        members[i] = list[i]
    end

    --打乱顺序
    for i=1,#members do
        local random = math.random(1,#members)
        local temp = members[i]
        members[i] = members[random]
        members[random] = temp
    end

    return members,l
end


