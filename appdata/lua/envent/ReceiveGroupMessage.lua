--[[
处理收到的群消息

提前收到的声明数据为：
fromqq     消息的qq号码 number类型
fromgroup  消息的群号码 number类型
message    消息内容     string类型
id         消息id       number类型
fromAnonymous 消息是否匿名 bool类型


注意：拦截消息后请将变量handled置true，表示消息已被拦截，如：
handled = true

下面的代码为我当前接待喵逻辑使用的代码，可以重写也可以按自己需求进行更改
详细请参考readme
]]

local solve = require("app.messageSolve")
if solve(message,fromqq,fromgroup,id) then
    handled = true
end
