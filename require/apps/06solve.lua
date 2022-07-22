local solveList = {
"电压不稳",
"耀斑干扰",
"你看错了",
"灵异事件",
"设备进水",
"逻辑错误",
"设备短路",
"供电不足",
"网络波动",
"设备起火",
"温度过低",
"温度过高",
"他在骗人",
"电压不稳",
"耀斑干扰",
}

return {--问问题
check = function (data)
    return data.msg:find("帮.+解决.+") == 1 and data.msg:len() > 12
end,
run = function (data,sendMessage)
    local u,s = data.msg:match("帮(.+)解决(.+)")
    if u and s then
        sendMessage([[正在启动宇宙无敌问题解决工具...
正在为]]..u.."查找"..s..[[的可能原因...
加载问题解决器！
[CQ:image,file=10575002e63688e99a9c5533966ef3e6.image,url=https://c2cpicdw.qpic.cn/offpic_new/961726194//961726194-1996835544-10575002E63688E99A9C5533966EF3E6/0?term=3]
正在分析，请稍候...]])
        sys.timerStart(sendMessage,3000,"我知道原因了！原因是"..solveList[math.random(1,#solveList)])
    end
    return true
end
}
