--自动读取apps目录，加载所有功能
local apps = {}
import("System.IO")
local AppList = Directory.GetFiles(CQApi.AppDirectory.."lua/require/apps/")

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
        CQLog:Debug("lua插件",LuaEnvName.."加载app："..tempList[i])
    end
end
tempList = nil--释放临时table

return function (data)
    --封装一个发送消息接口
    --自动判断群聊与私聊
    local function sendMessage(s)
        if LuaEnvName ~= "private" then
            CQApi:SendGroupMessage(data.group,s)
        else
            CQApi:SendPrivateMessage(data.qq,s)
        end
    end

    --遍历所有功能
    for i=1,#apps do
        if apps[i].check and apps[i].check(data) then
            if apps[i].run(data,sendMessage) then
                break
            end
        end
    end
end

