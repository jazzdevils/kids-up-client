local mime = require("mime")
local apiurl = require("scripts.apiurl")
local utils = require("scripts.commonUtils")
local Api = {}
local params = {}
params.timeout = 10
Api.Queue_table = {} --api 큐를 담는곳(강제로 취소하기위한 api 핸들)

function Api.insertQueue(requestId)
    table.insert(Api.Queue_table, requestId)
end

function Api.cancelRequest()
    print("before free Queue : "..#Api.Queue_table)
    for i = #Api.Queue_table, 1, -1 do
        local requestId = Api.Queue_table[i]
        if (requestId) then
            network.cancel(requestId)
            
            table.remove(Api.Queue_table, i)
        end
    end
    
    print("after free Queue : "..#Api.Queue_table)
end

function Api.login_api(email, password, callback)
    local str = "email="..utils.escape(email)
    str = str.."&pw="..utils.escape(password)
    network.request( apiurl.LOGIN..str, "GET", callback, params )
end

function Api.email_check(email, callback)
    local str = "email="..email
    network.request( apiurl.EMAIL_CHECK..str, "GET", callback, params) 
end

function Api.join_api(email, password, callback)
    local headers = {}
    headers["Content-Type"] = "text/plain; charset=utf-8"
    
    local str 
    str = "email="..email.."&pw="..password
    network.request( apiurl.JOIN..str, "GET", callback, params) 
end

function Api.notice_get_api(centerId, classId, memberId, pageNo, pageSize, callback)
    local headers = {}
    headers["Content-Type"] = "text/plain; charset=utf-8"
    
    local str 
    str = "center_id="..centerId.."&class_id="..classId.."&member_id="..memberId.."&pageno="..pageNo.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.NOTICE..str, "GET", callback, params))
    print(apiurl.NOTICE..str)
end

function Api.notice_reply_get_api(noticeId, pageNo, pageSize, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "text/plain; charset=utf-8"
    
    local str 
    str = "notice_id="..noticeId.."&pageno="..pageNo.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.NOTICE_REPLYLIST..str, "GET", callback, params))
end

function Api.notice_reply_get_api2(noticeId, pageNo, pageSize, callback)
    local headers = {}
    headers["Content-Type"] = "text/plain; charset=utf-8"
    
    local str 
    str = "notice_id="..noticeId.."&pageno="..pageNo.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.NOTICE_REPLYLIST2..str, "GET", callback, params))
end

function Api.image_api(userid, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    
--    local params = {}
--    params.body = "id="..userid
    network.request( apiurl.IMAGES, "POST", callback ) 
end

function Api.country_list_api(callback)
    network.request( apiurl.COUNTRY_LIST, "GET", callback)
end

function Api.state_list_api(country_id, center_type, cnt_flag, callback)
    network.request( apiurl.STATE_LIST.."country_id="..country_id.."&center_type="..center_type.."&cnt_flag="..cnt_flag, "GET", callback) 
end

function Api.city_list_api(state_id, center_type, cnt_flag, callback)
    network.request( apiurl.CITY_LIST.."state_id="..state_id.."&center_type="..center_type.."&cnt_flag="..cnt_flag, "GET", callback) 
end

function Api.center_list_api(center_type, country_id, state_id, city_id, callback)
    network.request( apiurl.CENTER_LIST.."center_type="..center_type.."&country_id="..country_id.."&state_id="..state_id.."&city_id="..city_id, "GET", callback) 
end

function Api.class_list_api(center_id, callback)
    network.request( apiurl.CLASS_LIST.."center_id="..center_id, "GET", callback) 
end

function Api.post_notice_contents(type, center_id, class_id, member_id, title, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "type="..type
    body = body.."&center_id="..center_id
    body = body.."&class_id="..class_id
    body = body.."&member_id="..member_id
    body = body.."&title="..utils.escape(title)
    body = body.."&contents="..utils.escape(contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.POST_NOTICE_CONTENTS, "POST", callback, params)
end

function Api.post_notice_imagezip(center_id, notice_id, filename, dir, callback)
    local headers = {}
    headers["Content-Type"] = "application/zip"
    headers["center_id"] = center_id
    headers["notice_id"] = notice_id

    local params = {}
    params.headers = headers
    params.body = {
        filename = filename,
        baseDirectory = dir
    }
    network.request( apiurl.POST_NOTICE_IMAGEZIP, "POST", callback, params)
end

function Api.post_notice_image(p, callback)
    local params = {}
    local path = system.pathForFile(p.filename, p.dir)
    local file, errStr = io.open( path, "rb" )
    if file then
        local img = mime.b64(file:read( "*a" ))
        io.close( file )
        file = nil

        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        headers["center_id"] = p.center_id
        local body = "image="..img
        body = body.."&notice_id="..p.notice_id
        body = body.."&filename="..p.filename
        params.headers = headers
        params.body = body
        params.progress = "upload"
    end
    network.request( apiurl.POST_NOTICE_IMAGE, "POST", callback, params)
end

function Api.delete_notice_image(p, callback)
    local str = "center_id="..p.center_id
    str = str.."&notice_id="..p.notice_id
    str = str.."&filename="..p.filename
    network.request( apiurl.DELETE_NOTICE_IMAGE..str, "GET", callback, params) 
end

function Api.delete_notice(notice_id, callback)
    local str = "notice_id="..notice_id
    network.request( apiurl.DELETE_NOTICE..str, "GET", callback, params) 
end

function Api.post_notice_reply(notice_id, member_id, contents, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["notice_id"] = notice_id
    headers["member_id"] = member_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_NOTICE_REPLY, "POST", callback, params)
end

function Api.post_notice_reply2(notice_id, member_id, kids_id, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["notice_id"] = notice_id
    headers["member_id"] = member_id
    headers["kids_id"] = kids_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_NOTICE_REPLY2, "POST", callback, params)
end

function Api.update_notice_contents(noticeId, classId, title, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "notice_id="..noticeId
    body = body.."&class_id="..classId
    body = body.."&title="..utils.escape(title)
    body = body.."&contents="..utils.escape(contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.UPDATE_NOTICE_CONTENTS, "POST", callback, params)
end

function Api.get_info_by_access(member_id, callback)
    local str = "member_id="..member_id
    network.request( apiurl.ACCESS..str, "GET", callback, params) 
end

function Api.update_member3_info(member_id, member_name, member_phonenum, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "member_id="..member_id
    body = body.."&member_name="..member_name
    body = body.."&phonenum="..member_phonenum
    local params = {}
    params.headers = headers
    params.body = body
    network.request( apiurl.UPDATE_MEMBER_TYPE3_INFO, "POST", callback, params) 
end

function Api.post_membertype1_info(p, callback)
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_type="..p.member_type
        body = body.."&center_type="..p.center_type
        body = body.."&country_id="..p.country_id
        body = body.."&state_id="..p.state_id
        body = body.."&city_id="..p.city_id
        body = body.."&center_name="..utils.escape(p.center_name)
        body = body.."&address_detail="..utils.escape(p.detail_address)
        body = body.."&member_name="..utils.escape(p.member_name)
        body = body.."&email="..utils.escape(p.email)
        body = body.."&pw="..utils.escape(p.pw)
        body = body.."&phonenum="..utils.escape(p.phonenum)
        body = body.."&locale="..utils.getLocale()
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_type="..p.member_type
            body = body.."&center_type="..p.center_type
            body = body.."&country_id="..p.country_id
            body = body.."&state_id="..p.state_id
            body = body.."&city_id="..p.city_id
            body = body.."&center_name="..utils.escape(p.center_name)
            body = body.."&address_detail="..utils.escape(p.detail_address)
            body = body.."&member_name="..utils.escape(p.member_name)
            body = body.."&email="..utils.escape(p.email)
            body = body.."&pw="..utils.escape(p.pw)
            body = body.."&phonenum="..utils.escape(p.phonenum)
            body = body.."&filename="..p.filename
            body = body.."&locale="..utils.getLocale()
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.POST_MEMBERTYPE1_INFO, "POST", callback, params)
end

function Api.post_membertype2_info(p, callback)
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_type="..p.member_type
        body = body.."&center_type="..p.center_type
        body = body.."&country_id="..p.country_id
        body = body.."&state_id="..p.state_id
        body = body.."&city_id="..p.city_id
        body = body.."&center_id="..p.center_id
        body = body.."&member_name="..utils.escape(p.member_name)
        body = body.."&email="..utils.escape(p.email)
        body = body.."&pw="..utils.escape(p.pw)
        body = body.."&phonenum="..utils.escape(p.phonenum)
        body = body.."&class_id="..p.class_id
        body = body.."&invitation_result="..p.invitationCodeInputResult
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_type="..p.member_type
            body = body.."&center_type="..p.center_type
            body = body.."&country_id="..p.country_id
            body = body.."&state_id="..p.state_id
            body = body.."&city_id="..p.city_id
            body = body.."&center_id="..p.center_id
            body = body.."&member_name="..utils.escape(p.member_name)
            body = body.."&email="..utils.escape(p.email)
            body = body.."&pw="..utils.escape(p.pw)
            body = body.."&phonenum="..utils.escape(p.phonenum)
            body = body.."&class_id="..p.class_id
            body = body.."&filename="..p.filename
            body = body.."&invitation_result="..p.invitationCodeInputResult
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.POST_MEMBERTYPE2_INFO, "POST", callback, params)
end

function Api.post_membertype3_info(p, callback)
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_type="..p.member_type
        body = body.."&center_type="..p.center_type
        body = body.."&country_id="..p.country_id
        body = body.."&state_id="..p.state_id
        body = body.."&city_id="..p.city_id
        body = body.."&center_id="..p.center_id
        body = body.."&member_name="..utils.escape(p.member_name)
        body = body.."&email="..utils.escape(p.email)
        body = body.."&pw="..utils.escape(p.pw)
        body = body.."&phonenum="..utils.escape(p.phonenum)
        body = body.."&class_id="..p.class_id
        body = body.."&kid_name="..utils.escape(p.kid_name)
        body = body.."&kid_birth="..p.kid_birth
        body = body.."&kid_sex="..p.kid_sex
        body = body.."&invitation_result="..p.invitationCodeInputResult
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_type="..p.member_type
            body = body.."&center_type="..p.center_type
            body = body.."&country_id="..p.country_id
            body = body.."&state_id="..p.state_id
            body = body.."&city_id="..p.city_id
            body = body.."&center_id="..p.center_id
            body = body.."&member_name="..utils.escape(p.member_name)
            body = body.."&email="..utils.escape(p.email)
            body = body.."&pw="..utils.escape(p.pw)
            body = body.."&phonenum="..utils.escape(p.phonenum)
            body = body.."&class_id="..p.class_id
            body = body.."&filename="..p.filename
            body = body.."&kid_name="..utils.escape(p.kid_name)
            body = body.."&kid_birth="..p.kid_birth
            body = body.."&kid_sex="..p.kid_sex
            body = body.."&invitation_result="..p.invitationCodeInputResult
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.POST_MEMBERTYPE3_INFO, "POST", callback, params)
end

function Api.add_kids_info(p, callback)
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_id="..p.member_id
        body = body.."&center_id="..p.center_id
        body = body.."&class_id="..p.class_id
        body = body.."&kids_name="..utils.escape(p.kids_name)
        body = body.."&kids_birthday="..p.kids_birthday
        body = body.."&kids_sex="..p.kids_sex
        body = body.."&kids_active="..p.kids_active
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_id="..p.member_id
            body = body.."&center_id="..p.center_id
            body = body.."&class_id="..p.class_id
            body = body.."&kids_name="..utils.escape(p.kids_name)
            body = body.."&kids_birthday="..p.kids_birthday
            body = body.."&kids_sex="..p.kids_sex
            body = body.."&kids_active="..p.kids_active
            body = body.."&filename="..p.filename
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.ADD_KIDS_INFO, "POST", callback, params)
end

function Api.update_kids_info(p, callback)
    local headers = {}
    headers["Content-Type"] = "multipart/form-data"
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_id="..p.member_id
        body = body.."&center_id="..p.center_id
        body = body.."&class_id="..p.class_id
        body = body.."&kids_id="..p.kids_id
        body = body.."&kids_name="..utils.escape(p.kids_name)
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_id="..p.member_id
            body = body.."&center_id="..p.center_id
            body = body.."&class_id="..p.class_id
            body = body.."&kids_id="..p.kids_id
            body = body.."&kids_name="..utils.escape(p.kids_name)
            body = body.."&filename="..p.filename
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.UPDATE_KIDS_INFO, "POST", callback, params)
end

function Api.add_album_data(p, callback)
    local str = "member_id="..p.member_id
    str = str.."&kids_id="..p.kids_id
    str = str.."&center_id="..p.center_id
    str = str.."&thread_type="..p.thread_type
    str = str.."&thread_id="..p.thread_id
    str = str.."&filename="..p.filename
    network.request( apiurl.ADD_ALBUM_DATA..str, "GET", callback, params) 
end

function Api.get_album_list(memberId, pageNo, pageSize, callback) --deprecated
    local str = "member_id="..memberId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_ALBUM_LIST..str, "GET", callback, params))
end

function Api.get_album_list2(memberId, kidsId, pageNo, pageSize, callback)
    local str = "member_id="..memberId
    str = str.."&kids_id="..kidsId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_ALBUM_LIST2..str, "GET", callback, params))
end

function Api.delete_album_data(memberId, kidsId, albumIdx, callback)
    local str = "member_id="..memberId
    str = str.."&kids_id="..kidsId
    str = str.."&album_idx="..albumIdx
    network.request( apiurl.DELETE_ALBUM_DATA..str, "GET", callback, params) 
end

function Api.get_schedule_list(centerId, memberId, month, callback) --deprecated
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&month="..month
    network.request( apiurl.SCHEDULE_LIST..str, "GET", callback, params) 
end

function Api.get_schedule_list2(centerId, memberId, kidsId, month, callback)
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&kids_id="..kidsId
    str = str.."&month="..month
    network.request( apiurl.SCHEDULE_LIST2..str, "GET", callback, params) 
end

function Api.get_schedule_detail(centerId, memberId, date, callback) --deprecated
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&date="..date
    network.request( apiurl.SCHEDULE_DETAIL..str, "GET", callback, params) 
end

function Api.get_schedule_detail2(centerId, memberId, kidsId, date, callback)
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&kids_id="..kidsId
    str = str.."&date="..date
    network.request( apiurl.SCHEDULE_DETAIL2..str, "GET", callback, params) 
end

function Api.add_schedule_data_thread(centerId, memberId, threadType, threadId, date, time, callback) --deprecated
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&thread_type="..threadType
    str = str.."&thread_id="..threadId
    str = str.."&date="..date
    str = str.."&time="..time
    network.request( apiurl.ADD_SCHEDULE_DATA_THREAD..str, "GET", callback, params) 
end

function Api.add_schedule_data_thread2(centerId, memberId, kidsId, threadType, threadId, date, time, callback)
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&kids_id="..kidsId
    str = str.."&thread_type="..threadType
    str = str.."&thread_id="..threadId
    str = str.."&date="..date
    str = str.."&time="..time
    network.request( apiurl.ADD_SCHEDULE_DATA_THREAD2..str, "GET", callback, params) 
end

function Api.delete_schedule_data(schedule_id, callback)
    local str = "schedule_id="..schedule_id
    network.request( apiurl.DELETE_SCHEDULE_DATA..str, "GET", callback, params) 
end

function Api.plus_notice_goodcnt(noticeId, memberId, callback)
    local str = "notice_id="..noticeId
    str = str.."&member_id="..memberId
    network.request( apiurl.PLUS_NOTICE_GOODCNT..str, "GET", callback, params) 
end

function Api.ask_approval_list(centerId, memberId, memberType, pageno, pagesize, callback)
    local str = "center_id="..centerId
    str = str.."&member_id="..memberId
    str = str.."&member_type="..memberType
    str = str.."&pageno="..pageno
    str = str.."&pagesize="..pagesize
    network.request( apiurl.ASK_APPROVAL_LIST..str, "GET", callback, params) 
end

function Api.post_dailymenu_data(p, callback)
    local params = {}
    local path = system.pathForFile(p.filename, p.dir)
    local file, errStr = io.open( path, "rb" )
    if file then
        local img = mime.b64(file:read( "*a" ))
        io.close( file )
        file = nil

        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        headers["center_id"] = p.center_id
        local body = "image="..img
        body = body.."&center_id="..p.center_id
        body = body.."&date="..p.date
        body = body.."&title="..utils.escape(p.title)
        body = body.."&member_id="..p.member_id
        body = body.."&filename="..p.filename
        body = body.."&class_id="..p.class_id
        params.headers = headers
        params.body = body
        params.progress = "upload"
    end
    network.request( apiurl.POST_DAILYMENU_DATA, "POST", callback, params)
end

function Api.get_dailymenu_list(centerId, classId, pageno, pagesize, callback)
    local str = "center_id="..centerId
    str = str.."&class_id="..classId
    str = str.."&pageno="..pageno
    str = str.."&pagesize="..pagesize
    table.insert(Api.Queue_table, network.request( apiurl.DAILYMENU_LIST..str, "GET", callback, params))
end

function Api.delete_dailymenu_data(centerId, date, filename, callback)
    local str = "center_id="..centerId
    str = str.."&date="..date
    str = str.."&filename="..filename
    network.request( apiurl.DELETE_DAILYMENU_DATA..str, "GET", callback, params) 
end

function Api.do_askapprove(memberId, memberType, kidsId, callback)
    local str = "member_id="..memberId
    str = str.."&member_type="..memberType
    str = str.."&kids_id="..kidsId
    network.request( apiurl.DO_ASKAPPROVE..str, "GET", callback, params) 
end

function Api.delete_askapprove(memberId, memberType, kidsId, callback)
    local str = "member_id="..memberId
    str = str.."&member_type="..memberType
    str = str.."&kids_id="..kidsId
    network.request( apiurl.DELETE_ASKAPPROVE..str, "GET", callback, params) 
end

function Api.activate_kids(memberId, kidsId, callback)
    local str = "member_id="..memberId
    str = str.."&kids_id="..kidsId
    network.request( apiurl.ACTIVATE_KIDS..str, "GET", callback, params) 
end

function Api.post_event_contents(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "type="..p.type
    body = body.."&center_id="..p.center_id
    body = body.."&class_id="..p.class_id
    body = body.."&member_id="..p.member_id
    body = body.."&title="..utils.escape(p.title)
    body = body.."&contents="..utils.escape(p.contents)
    body = body.."&address="..utils.escape(p.address)
    body = body.."&date="..p.date
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_EVENT_CONTENTS, "POST", callback, params)
end

function Api.get_event_list(centerId, classId, memberId, pageNo, pageSize, callback)
    local str = "center_id="..centerId
    str = str.."&class_id="..classId
    str = str.."&member_id="..memberId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_EVENT_LIST..str, "GET", callback, params))
end

function Api.post_event_image(p, callback)
    local params = {}
    local path = system.pathForFile(p.filename, p.dir)
    local file, errStr = io.open( path, "rb" )
    if file then
        local img = mime.b64(file:read( "*a" ))
        io.close( file )
        file = nil

        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        headers["center_id"] = p.center_id
        local body = "image="..img
        body = body.."&event_id="..p.event_id
        body = body.."&filename="..p.filename
        params.headers = headers
        params.body = body
        params.progress = "upload"
    end
    network.request( apiurl.POST_EVENT_IMAGE, "POST", callback, params)
end

function Api.post_event_reply(event_id, member_id, contents, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["event_id"] = event_id
    headers["member_id"] = member_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_EVENT_REPLY, "POST", callback, params)
end

function Api.post_event_reply2(event_id, member_id, kids_id, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["event_id"] = event_id
    headers["member_id"] = member_id
    headers["kids_id"] = kids_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_EVENT_REPLY2, "POST", callback, params)
end

function Api.get_event_reply_list(eventId, pageNo, pageSize, callback) --deprecated
    local str = "event_id="..eventId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_EVENT_REPLY_LIST..str, "GET", callback, params))
end

function Api.get_event_reply_list2(eventId, pageNo, pageSize, callback)
    local str = "event_id="..eventId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_EVENT_REPLY_LIST2..str, "GET", callback, params))
end

function Api.delete_event_image(p, callback)
    local str = "center_id="..p.center_id
    str = str.."&event_id="..p.event_id
    str = str.."&filename="..p.filename
    network.request( apiurl.DELETE_EVENT_IMAGE..str, "GET", callback, params) 
end

function Api.update_event_contents(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "event_id="..p.event_id
    body = body.."&class_id="..p.class_id
    body = body.."&title="..utils.escape(p.title)
    body = body.."&contents="..utils.escape(p.contents)
    body = body.."&address="..utils.escape(p.address)
    body = body.."&date="..p.date
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.UPDATE_EVENT_CONTENTS, "POST", callback, params)
end

function Api.delete_event(event_id, callback)
    local str = "event_id="..event_id
    network.request( apiurl.DELETE_EVENT..str, "GET", callback, params) 
end

function Api.plus_event_goodcnt(eventId, memberId, callback)
    local str = "event_id="..eventId
    str = str.."&member_id="..memberId
    network.request( apiurl.PLUS_EVENT_GOODCNT..str, "GET", callback, params) 
end

function Api.get_mng_class_list(center_id, callback)
    network.request( apiurl.GET_MNG_CLASS_LIST.."center_id="..center_id, "GET", callback) 
end

function Api.post_class_info(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&class_name="..utils.escape(p.class_name)
    body = body.."&class_desc="..utils.escape(p.class_desc)
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_CLASS_INFO, "POST", callback, params)
end

function Api.update_class_info(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "class_id="..p.class_id
    body = body.."&class_name="..utils.escape(p.class_name)
    body = body.."&class_desc="..utils.escape(p.class_desc)
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.UPDATE_CLASS_INFO, "POST", callback, params)
end

function Api.delete_class_info(class_id, callback)
    network.request( apiurl.DELETE_CLASS_INFO.."class_id="..class_id, "GET", callback) 
end

function Api.send_notice_read(notice_id, member_id, callback)
    local str = "notice_id="..notice_id
    str = str.."&member_id="..member_id
    network.request( apiurl.SEND_NOTICE_READ..str, "GET", callback) 
end

function Api.send_event_read(event_id, member_id, callback)
    local str = "event_id="..event_id
    str = str.."&member_id="..member_id
    network.request( apiurl.SEND_EVENT_READ..str, "GET", callback) 
end

function Api.get_member_info(member_id, callback)
    network.request( apiurl.GET_MEMBER_INFO.."member_id="..member_id, "GET", callback) 
end

function Api.update_member2_info(p, callback)
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_id="..p.member_id
        body = body.."&center_id="..p.center_id
        body = body.."&class_id="..p.class_id
        body = body.."&member_name="..utils.escape(p.member_name)
        body = body.."&phonenum="..utils.escape(p.phonenum)
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_id="..p.member_id
            body = body.."&center_id="..p.center_id
            body = body.."&class_id="..p.class_id
            body = body.."&member_name="..utils.escape(p.member_name)
            body = body.."&phonenum="..utils.escape(p.phonenum)
            body = body.."&filename="..p.filename
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.UPDATE_MEMBERTYPE2_INFO, "POST", callback, params)
end

function Api.update_member1_info(p, callback)
    local params = {}
    
    if p.filename == nil or p.filename == "" then
        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        local body = "member_id="..p.member_id
        body = body.."&member_name="..utils.escape(p.member_name)
        body = body.."&phonenum="..utils.escape(p.phonenum)
        params.headers = headers
        params.body = body
    else
        local path = system.pathForFile(p.filename, p.dir)
        local file, errStr = io.open( path, "rb" )
        if file then
            local img = mime.b64(file:read( "*a" ))
            io.close( file )
            file = nil

            local headers = {}
            headers["Content-Type"] = "multipart/form-data"
            local body = "image="..img
            body = body.."&member_id="..p.member_id
            body = body.."&member_name="..utils.escape(p.member_name)
            body = body.."&phonenum="..utils.escape(p.phonenum)
            body = body.."&filename="..p.filename
            params.headers = headers
            params.body = body
            params.progress = "upload"
        end
    end
    network.request( apiurl.UPDATE_MEMBERTYPE1_INFO, "POST", callback, params)
end

function Api.add_schedule_data(p, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&date="..p.date
    body = body.."&member_id="..p.member_id
    body = body.."&title="..utils.escape(p.title)
    body = body.."&detail="..utils.escape(p.detail)
    body = body.."&time="..p.time
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.ADD_SCHEDULE_DATA, "POST", callback, params)
end

function Api.add_schedule_data2(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&date="..p.date
    body = body.."&member_id="..p.member_id
    body = body.."&kids_id="..p.kids_id
    body = body.."&title="..utils.escape(p.title)
    body = body.."&detail="..utils.escape(p.detail)
    body = body.."&time="..p.time
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.ADD_SCHEDULE_DATA2, "POST", callback, params)
end

function Api.post_mamatalk_contents(p, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&class_id="..p.class_id
    body = body.."&member_id="..p.member_id
    body = body.."&title="..utils.escape(p.title)
    body = body.."&contents="..utils.escape(p.contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.POST_MAMATALK_CONTENTS, "POST", callback, params)
end

function Api.post_mamatalk_contents2(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&class_id="..p.class_id
    body = body.."&member_id="..p.member_id
    body = body.."&kids_id="..p.kids_id
    body = body.."&title="..utils.escape(p.title)
    body = body.."&contents="..utils.escape(p.contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.POST_MAMATALK_CONTENTS2, "POST", callback, params)
end

function Api.post_mamatalk_image(p, callback)
    local params = {}
    local path = system.pathForFile(p.filename, p.dir)
    local file, errStr = io.open( path, "rb" )
    if file then
        local img = mime.b64(file:read( "*a" ))
        io.close( file )
        file = nil

        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        headers["center_id"] = p.center_id
        local body = "image="..img
        body = body.."&mamatalk_id="..p.mamatalk_id
        body = body.."&filename="..p.filename
        params.headers = headers
        params.body = body
        params.progress = "upload"
    end
    network.request( apiurl.POST_MAMATALK_IMAGE, "POST", callback, params)
end

function Api.get_mamatalk_list(centerId, classId, pageNo, pageSize, callback)
    local str = "center_id="..centerId
    str = str.."&class_id="..classId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_MAMATALK_LIST..str, "GET", callback, params)) 
end

function Api.update_device_token(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "member_id="..p.member_id
    body = body.."&device_type="..p.device_type
    body = body.."&device_token="..utils.escape(p.device_token)
    body = body.."&locale="..utils.getLocale()
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.UPDATE_DEVICE_TOKEN, "POST", callback, params)
end

function Api.delete_notice_reply(noticeId, replyId, callback)
    local str = "notice_id="..noticeId
    str = str.."&reply_id="..replyId
    network.request( apiurl.DELETE_NOTICE_REPLY..str, "GET", callback, params) 
end

function Api.delete_event_reply(eventId, replyId, callback)
    local str = "event_id="..eventId
    str = str.."&reply_id="..replyId
    network.request( apiurl.DELETE_EVENT_REPLY..str, "GET", callback, params) 
end

function Api.get_notice_detail(noticeId, callback)
    local str = "notice_id="..noticeId
    network.request( apiurl.GET_NOTICE_DETAIL..str, "GET", callback, params) 
end

function Api.get_event_detail(eventId, callback)
    local str = "event_id="..eventId
    network.request( apiurl.GET_EVENT_DETAIL..str, "GET", callback, params) 
end

function Api.get_memberlist_notread_notice(noticeId, callback)
    local str = "notice_id="..noticeId
    network.request( apiurl.GET_MEMBERLIST_NOTREAD_NOTICE..str, "GET", callback, params) 
end

function Api.get_memberlist_notread_event(eventId, callback)
    local str = "event_id="..eventId
    network.request( apiurl.GET_MEMBERLIST_NOTREAD_EVENT..str, "GET", callback, params) 
end

function Api.delete_mamatalk_image(p, callback)
    local str = "mamatalk_id="..p.mamatalk_id
    str = str.."&filename="..p.filename
    network.request( apiurl.DELETE_MAMATALK_IMAGE..str, "GET", callback, params) 
end

function Api.post_mamatalk_reply(mamatalk_id, member_id, contents, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["mamatalk_id"] = mamatalk_id
    headers["member_id"] = member_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_MAMATALK_REPLY, "POST", callback, params)
end

function Api.post_mamatalk_reply2(mamatalk_id, member_id, kids_id, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["mamatalk_id"] = mamatalk_id
    headers["member_id"] = member_id
    headers["kids_id"] = kids_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_MAMATALK_REPLY2, "POST", callback, params)
end

function Api.delete_mamatalk_reply(mamatalkId, replyId, callback)
    local str = "mamatalk_id="..mamatalkId
    str = str.."&reply_id="..replyId
    network.request( apiurl.DELETE_MAMATALK_REPLY..str, "GET", callback, params) 
end

function Api.get_mamatalk_reply_list(mamatalkId, pageNo, pageSize, callback) --deprecated
    local str = "mamatalk_id="..mamatalkId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_MAMATALK_REPLY_LIST..str, "GET", callback, params)) 
end

function Api.get_mamatalk_reply_list2(mamatalkId, pageNo, pageSize, callback)
    local str = "mamatalk_id="..mamatalkId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_MAMATALK_REPLY_LIST2..str, "GET", callback, params)) 
end

function Api.update_mamatalk_contents(mamatalkId, classId, title, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "mamatalk_id="..mamatalkId
    body = body.."&class_id="..classId
    body = body.."&title="..utils.escape(title)
    body = body.."&contents="..utils.escape(contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.UPDATE_MAMATALK_CONTENTS, "POST", callback, params)
end

function Api.delete_mamatalk(mamatalk_id, callback)
    local str = "mamatalk_id="..mamatalk_id
    network.request( apiurl.DELETE_MAMATALK..str, "GET", callback, params) 
end

function Api.plus_mamatalk_goodcnt(mamatalkId, memberId, callback)
    local str = "mamatalk_id="..mamatalkId
    str = str.."&member_id="..memberId
    network.request( apiurl.PLUS_MAMATALK_GOODCNT..str, "GET", callback, params) 
end

function Api.get_mamatalk_detail(mamatalkId, callback)
    local str = "mamatalk_id="..mamatalkId
    network.request( apiurl.GET_MAMATALK_DETAIL..str, "GET", callback, params) 
end

function Api.set_push_receive_yn(memberId, pushKey, pushValue, callback)
    local str = "member_id="..memberId
    str = str.."&push_key="..pushKey
    str = str.."&push_value="..pushValue
    network.request( apiurl.SET_PUSH_RECEIVE_YN..str, "GET", callback, params) 
end

function Api.get_push_receive_yn_list(memberId, callback)
    local str = "member_id="..memberId
    network.request( apiurl.GET_PUSH_RECEIVE_YN_LIST..str, "GET", callback, params) 
end

function Api.push_not_read_notice_member_list(noticeId, callback)
    local str = "notice_id="..noticeId
    network.request( apiurl.PUSH_NOT_READ_NOTICE_MEMBER_LIST..str, "GET", callback, params) 
end

function Api.push_not_read_event_member_list(eventId, callback)
    local str = "event_id="..eventId
    network.request( apiurl.PUSH_NOT_READ_EVENT_MEMBER_LIST..str, "GET", callback, params) 
end

function Api.post_contact_contents(p, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&member_id="..p.member_id
    body = body.."&to_kids_id="..p.to_kids_id
    body = body.."&contents="..utils.escape(p.contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.POST_CONTACT_CONTENTS, "POST", callback, params)
end

function Api.post_contact_contents2(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&member_id="..p.member_id
    body = body.."&kids_id="..p.kids_id
    body = body.."&to_kids_id="..p.to_kids_id
    body = body.."&contents="..utils.escape(p.contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.POST_CONTACT_CONTENTS2, "POST", callback, params)
end

function Api.post_contact_image(p, callback)
    local params = {}
    local path = system.pathForFile(p.filename, p.dir)
    local file, errStr = io.open( path, "rb" )
    if file then
        local img = mime.b64(file:read( "*a" ))
        io.close( file )
        file = nil

        local headers = {}
        headers["Content-Type"] = "multipart/form-data"
        headers["center_id"] = p.center_id
        local body = "image="..img
        body = body.."&contact_id="..p.contact_id
        body = body.."&filename="..p.filename
        params.headers = headers
        params.body = body
        params.progress = "upload"
    end
    network.request( apiurl.POST_CONTACT_IMAGE, "POST", callback, params)
end

function Api.get_contact_list(centerId, month, memberId, pageNo, pageSize, callback) --deprecated
    local str = "center_id="..centerId.."&month="..month.."&member_id="..memberId.."&pageno="..pageNo.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_CONTACT_LIST..str, "GET", callback, params))
end

function Api.get_contact_list2(centerId, month, memberId, kidsId, pageNo, pageSize, callback)
    local str = "center_id="..centerId.."&month="..month.."&member_id="..memberId.."&kids_id="..kidsId.."&pageno="..pageNo.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_CONTACT_LIST2..str, "GET", callback, params))
end

function Api.delete_contact_image(p, callback)
    local str = "contact_id="..p.contact_id
    str = str.."&filename="..p.filename
    network.request( apiurl.DELETE_CONTACT_IMAGE..str, "GET", callback, params) 
end

function Api.post_contact_reply(contact_id, member_id, contents, callback) --deprecated
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["contact_id"] = contact_id
    headers["member_id"] = member_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_CONTACT_REPLY, "POST", callback, params)
end

function Api.post_contact_reply2(contact_id, member_id, kids_id, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"
    headers["contact_id"] = contact_id
    headers["member_id"] = member_id
    headers["kids_id"] = kids_id

    local body = contents
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.POST_CONTACT_REPLY2, "POST", callback, params)
end

function Api.get_contact_reply_list(contactId, memberId, pageNo, pageSize, callback) --deprecated
    local str = "contact_id="..contactId
    str = str.."&member_id="..memberId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_CONTACT_REPLY_LIST..str, "GET", callback, params))
end

function Api.get_contact_reply_list2(contactId, memberId, pageNo, pageSize, callback)
    local str = "contact_id="..contactId
    str = str.."&member_id="..memberId
    str = str.."&pageno="..pageNo
    str = str.."&pagesize="..pageSize
    table.insert(Api.Queue_table, network.request( apiurl.GET_CONTACT_REPLY_LIST2..str, "GET", callback, params))
end

function Api.delete_contact_reply(contactId, replyId, callback)
    local str = "contact_id="..contactId
    str = str.."&reply_id="..replyId
    network.request( apiurl.DELETE_CONTACT_REPLY..str, "GET", callback, params) 
end

function Api.update_conatct_contents(contactId, contents, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "contact_id="..contactId
    body = body.."&contents="..utils.escape(contents)
    local params = {}
    params.headers = headers
    params.body = body

    network.request( apiurl.UPDATE_CONTACT_CONTENTS, "POST", callback, params)
end

function Api.delete_contact(contact_id, callback)
    local str = "contact_id="..contact_id
    network.request( apiurl.DELETE_CONTACT..str, "GET", callback, params) 
end

function Api.send_conatct_read(contact_id, member_id, callback) --deprecated
    local str = "contact_id="..contact_id
    str = str.."&member_id="..member_id
    network.request( apiurl.SEND_CONTACT_READ..str, "GET", callback) 
end

function Api.send_conatct_read2(contact_id, member_id, kids_id, callback)
    local str = "contact_id="..contact_id
    str = str.."&member_id="..member_id
    str = str.."&kids_id="..kids_id
    network.request( apiurl.SEND_CONTACT_READ2..str, "GET", callback) 
end

function Api.get_memberlist_notread_contact(contactId, callback)
    local str = "contact_id="..contactId
    network.request( apiurl.GET_MEMBERLIST_NOTREAD_CONTACT..str, "GET", callback, params) 
    print(apiurl.GET_MEMBERLIST_NOTREAD_CONTACT..str)
end

function Api.push_not_read_contact_member_list(contactId, callback)
    local str = "contact_id="..contactId
    network.request( apiurl.PUSH_NOT_READ_CONTACT_MEMBER_LIST..str, "GET", callback, params) 
end

function Api.get_kids_list(centerId, classId, callback)
    local str = "center_id="..centerId
    str = str.."&class_id="..classId
    network.request( apiurl.GET_KIDS_LIST..str, "GET", callback, params) 
end

function Api.get_center_type_list(countryId, callback)
    local str = "country_id="..countryId
    network.request( apiurl.GET_CENTER_TYPE_LIST..str, "GET", callback, params) 
end

function Api.check_attendance(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_id="..p.center_id
    body = body.."&date="..p.date
    body = body.."&class_id="..p.class_id
    body = body.."&kids_id_str="..p.kids_id_str
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.CHECK_ATTENDANCE, "POST", callback, params)
end

function Api.get_attendance_info(centerId, date, classId, callback)
    local str = "center_id="..centerId
    str = str.."&date="..date
    str = str.."&class_id="..classId
    network.request( apiurl.GET_ATTENDANCE_INFO..str, "GET", callback, params) 
end

function Api.change_kids_class(kidsId, classId, callback)
    local str = "kids_id="..kidsId
    str = str.."&class_id="..classId
    network.request( apiurl.CHANGE_KIDS_CLASS..str, "GET", callback, params) 
end

function Api.void_kids_approval(kidsId, callback)
    local str = "kids_id="..kidsId
    network.request( apiurl.VOID_KIDS_APPROVAL..str, "GET", callback, params) 
end

function Api.get_app_info(callback)
    network.request(apiurl.GET_APP_INFO, "GET", callback, params)
end

function Api.get_teacher_list(centerId, callback)
    local str = "center_id="..centerId
    network.request( apiurl.GET_TEACHER_LIST..str, "GET", callback, params) 
end

function Api.change_teacher_class(memberId, classId, callback)
    local str = "member_id="..memberId
    str = str.."&class_id="..classId
    network.request( apiurl.CHANGE_TEACHER_CLASS..str, "GET", callback, params) 
end

function Api.void_teacher_approval(memberId, callback)
    local str = "member_id="..memberId
    network.request( apiurl.VOID_TEACHER_APPROVAL..str, "GET", callback, params) 
end

function Api.get_invitation_code(centerId, callback)
    local str = "center_id="..centerId
    network.request( apiurl.GET_INVITATION_CODE..str, "GET", callback, params) 
end

function Api.set_invitation_code(centerId, invitationCode,  callback)
    local str = "center_id="..centerId
    str = str.."&invitation_code="..invitationCode
    network.request( apiurl.SET_INVITATION_CODE..str, "GET", callback, params) 
end

function Api.get_news(memberId, device_id, callback)
    local str = "member_id="..memberId
    str = str.."&device_id="..device_id
    network.request( apiurl.GET_NEWS..str, "GET", callback, params) 
end

function Api.get_news2(memberId, device_id, kids_id, callback)
    local str = "member_id="..memberId
    str = str.."&device_id="..device_id
    str = str.."&kids_id="..kids_id
    network.request( apiurl.GET_NEWS2..str, "GET", callback, params) 
end

function Api.clear_news(memberId, news_name, callback)
    local str = "member_id="..memberId
    str = str.."&badge_name="..news_name
    network.request( apiurl.CLEAR_NEWS..str, "GET", callback, params) 
end

function Api.clear_news2(memberId, news_name, kids_id, callback)
    local str = "member_id="..memberId
    str = str.."&badge_name="..news_name
    str = str.."&kids_id="..kids_id
    network.request( apiurl.CLEAR_NEWS2..str, "GET", callback, params) 
end

function Api.set_locale(p, callback)
    local str = "member_id="..p.member_id
    str = str.."&device_id="..p.device_id
    str = str.."&locale="..p.locale
    network.request( apiurl.SET_LOCALE..str, "GET", callback, params) 
end

function Api.change_password(memberId, current_password, new_password, callback)
    local str = "member_id="..memberId
    str = str.."&cur_pw="..current_password
    str = str.."&new_pw="..new_password
    network.request( apiurl.CHANGE_PASSWORD..str, "GET", callback, params) 
end

function Api.req_issue_pw(p, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "email="..p.email
    body = body.."&name="..utils.escape(p.name)
    body = body.."&locale="..utils.getLocale()
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.REQ_ISSUE_PW, "POST", callback, params)
end

function Api.get_device_tokens(memberId, callback)
    local str = "member_id="..memberId
    network.request( apiurl.GET_DEVICE_TOKENS..str, "GET", callback, params) 
end

function Api.get_news_list(memberId, device_id, callback)
    local str = "member_id="..memberId
    str = str.."&device_id="..device_id
    network.request( apiurl.GET_NEWS_LIST..str, "GET", callback, params) 
end

function Api.get_news_detail(memberId, device_id, seq, demoMode, callback) --deprecated
    local str = "member_id="..memberId
    str = str.."&device_id="..device_id
    str = str.."&seq="..seq
    if demoMode == true then
        str = str.."&demo=".."1" --체험모드
    else
        str = str.."&demo=".."0" --리얼모드
    end
    network.request( apiurl.GET_NEWS_DETAIL..str, "GET", callback, params) 
end

function Api.get_news_detail3(memberId, device_id, seq, kids_id, demoMode, callback)
    local str = "member_id="..memberId
    str = str.."&device_id="..device_id
    str = str.."&seq="..seq
    str = str.."&kids_id="..kids_id
    if demoMode == true then
        str = str.."&demo=".."1" --체험모드
    else
        str = str.."&demo=".."0" --리얼모드
    end
    network.request( apiurl.GET_NEWS_DETAIL3..str, "GET", callback, params) 
end

function Api.get_Center_Ask_Approval_List(callback)
    network.request( apiurl.GET_CENTER_ASK_APPROVAL_LIST, callback, params) 
end

function Api.do_Center_Ask_Approve(centerId, callback)
    local str = "center_id="..centerId
    network.request( apiurl.DO_CENTER_ASK_APPROVE..str, callback, params) 
end

function Api.delete_Center_Ask_Approve(centerId, callback)
    local str = "center_id="..centerId
    network.request( apiurl.DELETE_CENTER_ASK_APPROVE..str, callback, params) 
end

function Api.get_CenterList_byName(centerType, centerName, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "center_name="..utils.escape(centerName)
    body = body.."&center_type="..centerType
    
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.GET_CENTERLIST_BYNAME, "POST", callback, params)
end

function Api.set_message_time(center_id, set_yn, s_hours, s_min, e_hour, e_min, callback)
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local body = "&center_id="..center_id
    body = body.."&set_yn="..set_yn
    body = body.."&s_hours="..s_hours
    body = body.."&s_min="..s_min
    body = body.."&e_hour="..e_hour
    body = body.."&e_min="..e_min
    params.headers = headers
    params.body = body
    
    local params = {}
    params.headers = headers
    params.body = body

    network.request(apiurl.SET_MESSAGE_TIME, "POST", callback, params)
end

function Api.get_message_time(centerId, callback)
    local str = "center_id="..centerId
    network.request( apiurl.GET_MESSAGE_TIME..str, "GET", callback, params) 
end


return Api