require("scripts.user_dataDefine")
local storyboard = require( "storyboard" )

local language = getLanguage()
local M = {}

M.classList = {}
M.userData = {}
M.kidsList = {}
M.deviceList = {}

function M.getClassName(class_id)
    for i = 1, #M.classList do
        local classData = M.classList[i]
        if(classData.id == class_id) then
            return classData.name
        end
    end
    
    return ""
end

function M.freeClassList()
    for i = #M.classList, 1, -1 do
        table.remove(M.classList, i) 
    end
end

function M.freeUserData()
    for i = #M.userData, 1, -1 do
        table.remove(M.userData, i) 
    end
end

function M.freeKidsList()
    for i = #M.kidsList, 1, -1 do
        table.remove(M.kidsList, i) 
    end
end

function M.freeDeviceList()
    for i = #M.deviceList, 1, -1 do
        table.remove(M.deviceList, i) 
    end
end

function M.addClass(params)
    local classData = {}
    classData.id = params.id
    classData.name = params.name
    classData.desc = params.desc
    
    table.insert(M.classList, classData)
end

function M.addDevice(p)
    local deviceData ={}
    
    deviceData.id = p.id
    deviceData.type = p.type
    deviceData.token = p.token
    deviceData.locale = p.locale
    
    table.insert(M.deviceList, deviceData)
end

function M.addUser(p)
    M.userData.centerid = p.center_id  --원 아이디
    M.userData.centerName = p.center_name -- 원 이름
    M.userData.id = p.id --사용 아이디(DB 번호)
    M.userData.name = p.name  --이름
    M.userData.phonenum = p.phonenum -- 연락처
    M.userData.jobType = p.type  --원장, 교사, 학부모 타입(1, 2, 3)
    M.userData.jobSubType = p.subtype  --선생의 경우(1:반지정, 2:반지정없음) , 학부모 타입의 경우 아이와의 관계(1:아빠, 2:엄마, 3:할아버지,4:할머니 등등등...)
    M.userData.img = p.img  --원장, 교사의 경우 프로필 사진(full path)
    M.userData.profileImage = p.profileImage  --원장, 교사의 경우 프로필 사진(only file name)
    M.userData.approvalState = p.approval_state  --"1":승인완료, "0":미승인
    M.userData.className = p.class_name --클래스 이름
    M.userData.classId = p.class_id  --클래스 지정이 안된경우는 Blank 학부모의 경우 현재 액티브된 아이의 클래스 아이디, 교사의 경우 소속된 클래스에서 첫번째 클래스 아이디
    M.userData.ClassListOfTeacher = p.class --교사가 소속된 클래스 리스트(id, name)
    if (p.admin_yn and p.admin_yn == "1" ) then
        M.userData.isAdmin = true
    else
        M.userData.isAdmin = false
    end
    
--    M.userData.message_time = p.message_time
end

function M.addKid(params)
    local kidData ={}
    
    kidData.id = params.id
    kidData.name = params.name
    kidData.img = params.img
    kidData.birthday = params.birthday
    kidData.sex = params.sex
    kidData.approval_state = params.approval_state
    kidData.center_type = params.center_type
    kidData.center_id = params.center_id
    kidData.center_name = params.center_name
    kidData.class_id = params.class_id
    kidData.class_name = params.class_name
    kidData.registtime = params.registtime
    kidData.active = params.active --0:not active, 1:active
    kidData.profileImage = params.profileImage
    kidData.country_id = params.country_id
    kidData.country_name = params.country_name
    kidData.state_id = params.state_id
    kidData.state_name = params.state_name
    kidData.city_id = params.city_id
    kidData.city_name = params.city_name
    
    table.insert(M.kidsList, kidData)
end

function M.modifyKid(params)
    for i=1, #M.kidsList do
	local data = M.kidsList[i]
        if data.id == params.id then
            data.name = params.name
            data.img = params.img
            data.birthday = params.birthday
            data.sex = params.sex --1: 남자, 2:여자
            data.approval_state = params.approval_state --0:not approval, 1: approval
            data.center_type = params.center_type
            data.center_id = params.center_id
            data.center_name = params.center_name
            data.class_id = params.class_id
            data.class_name = params.class_name
            data.active = params.active --0:not active, 1:active
            data.profileImage = params.profileImage
            data.country_id = params.country_id
            data.country_name = params.country_name
            data.state_id = params.state_id
            data.state_name = params.state_name
            data.city_id = params.city_id
            data.city_name = params.city_name
        end
    end  
end

function M.setFreeActiveKid()
    for i=1, #M.kidsList do
	local data = M.kidsList[i]
        data.active = "0"
    end  
    
    return nil
end

function M.setActiveKid(id)
    for i=1, #M.kidsList do
	local data = M.kidsList[i]
        if data.id == id then
            data.active = "1"
        else
            data.active = "0"
        end
    end  
    
    return nil
end

function M.getActiveKidData()
    for i=1, #M.kidsList do
	local data = M.kidsList[i]
        if data.active == "1" then
            return data
        end
    end  
    
    return nil
end

function M.getKidData(id)
    for i=1, #M.kidsList do
	local data = M.kidsList[i]
        if data.id == id then
            return data
        end
    end
    
    return nil
end

function M.getDeviceData()
    for i=1, #M.deviceList do
	local data = M.deviceList[i]
        if data.type == storyboard.state.DEVICE_TYPE and data.token == storyboard.state.DEVICE_TOKEN then
            return data
        end
    end
    
    return nil
end

function M.getClassNameOfTeacher4Display()
    local str = ""
    
    if #M.userData.ClassListOfTeacher > 1 then
        str = M.userData.className .." + " .. #M.userData.ClassListOfTeacher - 1
    else
        str = M.userData.className
    end
    
    return str
end

function M.getNameTagByAuthority()
    local strNameTag = ""
    
    if(M.userData.jobType == __DIRECTOR__) then
        --원장
        strNameTag = language["call_name"]["principal"].." : "..M.userData.name
    elseif(M.userData.jobType == __TEACHER__ and #M.userData.ClassListOfTeacher > 0) then  
        --반지정 있는 교사
--        strNameTag = language["call_name"]["teacher"].." : "..M.userData.name.." ("..M.getClassName(M.userData.classId)..")  "
        strNameTag = language["call_name"]["teacher"].." : "..M.userData.name.." ("..M.getClassNameOfTeacher4Display()..")  "
    elseif(M.userData.jobType == __TEACHER__ and M.userData.jobSubType == __TEACHER_NOCLASS__) then
        --반지정 없는 교사
        strNameTag = language["call_name"]["teacher"].." : "..M.userData.name
    elseif(M.userData.jobType == __PARENT__) then
        --학부모
        local activeKidData = M.getActiveKidData()
        local childName = activeKidData.name
        local center_name = activeKidData.center_name
--        local childBirthday = activeKidData.birthday
        local childClassName = activeKidData.class_name
--        strNameTag = "["..center_name.."] "..childClassName.." . "..childName 
        strNameTag = "["..childClassName.."] "..childName 
    end
    
    return strNameTag
end

function M.getActiveKid_IDByAuthority()
    if M.userData.jobType == __PARENT__ then
        return M.getActiveKidData().id
    else
        return ""
    end
end

function M.getCallNameByMemberType(memberType)
    local strNameTag = ""
    
    if(memberType == __DIRECTOR__) then
        --원장
        strNameTag = " ("..language["call_name"]["principal"]..")"
    elseif(memberType == __TEACHER__ ) then  
        --교사
        strNameTag = " ("..language["call_name"]["teacher"]..")"
    elseif(memberType == __PARENT__) then
        --학부모
        strNameTag = " ("..language["call_name"]["parent"]..")"
    end
    
    return strNameTag
end

function M.checkValidUserData(memberType)
--    사용자 관련 데이타 체크
--    M.classList = {}
--    M.userData = {}
--    M.kidsList = {}
--    M.deviceList = {}
--    local deviceListCnt = #M.deviceList --push 등록안할경우도 있기때문에 체크안함
    local kidsListCnt = #M.kidsList
    local classListCnt = #M.classList
        
    local result = true

    if(memberType == __DIRECTOR__) then
        --원장
        if M.userData.centerid == nil then
            result = false
        end
    elseif(memberType == __TEACHER__ ) then  
        --교사
        if M.userData.centerid == nil or classListCnt == 0 then
            result = false
        end
    elseif(memberType == __PARENT__) then
        --학부모
        if M.userData.centerid == nil or classListCnt == 0 or kidsListCnt == 0 then
            result = false
        end
    end
    
    return result
end

return M

