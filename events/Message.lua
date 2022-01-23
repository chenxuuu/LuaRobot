--自动读取apps目录，加载所有功能
local apps = {}
local AppList = Utils.GetFileList(Utils.Path.."lua/require/apps/")

--按文件名排序
local tempList = {}
for i=0,AppList.Length-1 do
    local app = AppList[i]:match("/([^/]-)%.lua")
    if app then
        table.insert(tempList,app)
    end
end
table.sort(tempList)--排序

--加载每个文件
for i=1,#tempList do
    local t
    local _,info = pcall(function() t = require("apps."..tempList[i]) end)
    if t then
        table.insert(apps,t)
        Log.Debug(StateName,LuaEnvName.."加载app："..tempList[i])
    end
end
tempList = nil--释放临时table

return function (data)
    --封装一个发送消息接口
    --自动判断群聊与私聊
    local function sendMessage(s)
        if LuaEnvName ~= "private" then
            cq.sendGroupMsg(data.group,s)
        else
            cq.sendPrivateMsg(data.qq,s)
        end
    end

    data = {
        qq = data.qq,
        group = data.group,
        msg = data.msg:gsub("(.-gchatpic_new/)%d-(/.-)","%1123456%2")
    }

    --遍历所有功能
    for i=1,#apps do
        if apps[i].check and apps[i].check(data) then
            if apps[i].run(data,sendMessage) then
                break
            end
        end
    end
end

