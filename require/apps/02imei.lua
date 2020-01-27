return {
check = function (data)
    if LuaEnvName == "private" or data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") then
        local imei = data.msg:gsub("%[CQ:.-%]",""):find("%d")
        return imei and imei:len() == 15
    end
end,
run = function (data,sendMessage)
    sys.taskInit(function()
    local replyResult = {}--最终要的信息

    local imei = data.msg:gsub("%[CQ:.-%]",""):match("%d+")
    local html = asyncHttpGet("http://erp.openluat.com/factory/v1/info?imei="..imei)
    if not html and html == "" then return end
    local d,r,e  = jsonDecode(html)
    if not (r and d) then return end
    if d["error"] == 0 then
        table.insert(replyResult,(LuaEnvName ~= "private" and Utils.CQCode_At(data.qq).."\r\n" or "")..
        "IMEI:"..d.imei.."\r\n"..
        "出厂固件:"..(d.firmware_file:match("(AirM2M_.+)%.rar") or "无记录").."\r\n"..
        "工单号:"..d.order_id.."\r\n"..
        "袋号:"..d.packed_packet_id.."\r\n"..
        "包装(真空袋):"..(d.packed_packet == 1 and "通过 "..d.packed_packet_time or "无数据").."\r\n"..
        "品质部门检测:"..(d.qc_pass == 1 and "通过 "..d.qc_time or "无数据").."\r\n"..
        "批量校准测试:"..(d.calib_pass == 1 and "通过 "..d.calib_time or "无数据").."\r\n"..
        "订制软件升级:"..(d.upgrade_pass == 1 and "通过 "..d.upgrade_time or "无数据").."\r\n"..
        "硬件功能检测:"..(d.ft_pass == 1 and "通过 "..d.ft_time or "无数据").."\r\n"..
        "写入IMEI串号:"..(d.write_imei_pass == 1 and "通过 "..d.write_imei_time or "无数据"))
    else
        table.insert(replyResult,Utils.CQCode_At(data.qq).."\r\n".."查询出错:"..d.message)
    end

    if LuaEnvName == "private" then--私聊回复设备信息
        local result = {}

        local cookie = XmlApi.Get("settings", "iotCookie")
        local html = asyncHttpGet("https://iot.openluat.com/api/site/device/"..imei.."/info",nil,nil,cookie)
        if not html or html == "" then
            table.insert(result, "设备绑定信息查询失败")
        else
            local d,r,e  = jsonDecode(html)
            if r and d then
                table.insert(result,
                "项目名："..d.data.project.."\r\n"..
                "项目创建时间："..d.data.project_creation_time.."\r\n"..
                "ProductKey："..(data.qq == Utils.setting.AdminQQ and d.data.project_key.."\r\n" or d.data.project_key:sub(1,5).."...后面省略\r\n")..
                "创建人："..d.data.project_creator.."\r\n"..
                "创建人手机号："..(data.qq == Utils.setting.AdminQQ and d.data.project_creator_phone.."\r\n" or d.data.project_creator_phone:sub(1,5).."...后面省略\r\n")..
                "设备创建时间："..d.data.device_creation_time)
            end
        end

        html = asyncHttpGet("https://iot.openluat.com/api/site/admin/device?page=0&page_size=10&search_imei="..imei,nil,nil,cookie)
        if not html or html == "" then
            table.insert(result,"设备项目信息查询失败")
        else
            local d,r,e  = jsonDecode(html)
            if r and d then
                if #d.data.data ~= 0 then
                    table.insert(result,
                    "固件名："..d.data.data[1].firmware.."\r\n"..
                    "软件版本："..d.data.data[1].version)
                else
                    table.insert(result,"设备项目信息查询结果为空")
                end
            end
        end

        html = asyncHttpGet("https://iot.openluat.com/api/site/device/"..imei.."/upgrade_record?t1=0&t2="..os.time().."&page=0&page_size=1",nil,nil,cookie)
        if not html or html == "" then
            table.insert(result,"上次升级请求信息查询失败")
        else
            if html:find("%[%]") then
                html = asyncHttpGet("https://iot.openluat.com/api/site/device/"..imei.."/upgrade_record?t1=0&t2="..os.time().."&page=0&page_size=1&prefail=1",nil,nil,cookie)
                if not html or html == "" then
                    html = "none"
                end
            end
            local d,r,e  = jsonDecode(html)
            if r and d then
                if #d.data.records ~= 0 then
                    table.insert(result,
                    "上次上报时间："..d.data.records[1].time.."\r\n"..
                    "上次上报固件："..d.data.records[1].firmware_name.."\r\n"..
                    "上次上报版本："..d.data.records[1].device_version)
                else
                    table.insert(result,"上次升级请求信息查询结果为空")
                end
            end
        end

        table.insert(replyResult,table.concat(result,"\r\n"))
    end

    sendMessage(table.concat(replyResult,"\r\n-----------------\r\n"))

    end)
    return true
end,
}
