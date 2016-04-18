require("scripts.user_dataDefine")
local user = require("scripts.user_data")

local M = {}
local userAuthorityList = {
    [__MEAL_MENU_WRITE] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__},
    },
    [__MEAL_MENU_DELETE__] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__},
    },
    [__NOTICE_WRITE__] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__},
    },
    [__NOTICE_DELETE__] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__},
    },
    [__NOTICE_EDIT__] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__}, 
    },
    [__VIEW_COMFIRMED_COUNT__] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__}, 
    },
    [__SELECT_CLASS__] = {
        {__DIRECTOR__, 0},
        {__TEACHER__, __TEACHER_CLASS__}, 
        {__TEACHER__, __TEACHER_NOCLASS__}, 
--        {__PARENT__, __PARENT_MOM__}, --test data
    },
}

function M.validAuthorityByUser(case)
    local userAuthority = userAuthorityList[case]
    local jobType = user.userData.jobType
    local jobSubType = user.userData.jobSubType
    
    if(userAuthority) then
        for i = 1, #userAuthority do
            local data = userAuthority[i]
            if(jobType == __DIRECTOR__) then
                if(data[1] == jobType) then
                    return true
                end
            else
                if(data[1] == jobType) then 
                    if (jobSubType and jobSubType ~= "") then 
                        if(data[2] == jobSubType) then
                            return true
                        end
                    else
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

function M.validAuthority(case, jobType, subjobType)
    local userAuthority = userAuthorityList[case]
    
    if(userAuthority) then
        for i = 1, #userAuthority do
            local data = userAuthority[i]
            if(jobType == __DIRECTOR__) then
                if(data[1] == jobType) then
                    return true
                end
            else
                if(data[1] == jobType and data[2] == subjobType) then
                    return true
                end
            end
        end
    end
    
    return false
end

return M


