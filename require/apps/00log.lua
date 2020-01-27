local function saveLog(g,q,t)
    local temp = 1
    while temp < #t do
        local ss,ee = t:find("%[CQ:image,file=.-%]",temp)
        if ss then
            t = t:gsub("%[CQ:image,file=.-%]","[image"..Utils.GetImageUrl(t:sub(ss,ee)).."]",1)
            temp = ee
        else
            break
        end
    end
    asyncHttpGet("https://qq.papapoi.com/qqmsg/post.php?g="..string.urlEncode(tostring(g))..
    "&q="..string.urlEncode(tostring(q))..
    "&m="..string.urlEncode((Utils.ConvertBase64(tostring(t)))))
    print("已上传消息记录")
end

local Groups = {
    423804427,--2
    851800257,--4g
    952343033,--irtu
    201848376,
    604902189,--1
    670342655,--task
    59994612,--测试群
}

return {
check = function (data)
    for i=1,#Groups do
        if Groups[i] == data.group then return true end
    end
end,
run = function (data,sendMessage)
    saveLog(data.group,tostring(data.qq),data.msg)
end
}
