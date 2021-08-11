local Groups = require("luat_groups")
local function check(group)
    for i=1,#Groups do
        if Groups[i] == group then
            return true
        end
    end
end

return function (data)
    if check(data.group) then
        XmlApi.Set("aff_qq",tostring(data.qq),"ad")
    end
end

