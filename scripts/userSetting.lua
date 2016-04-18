local loadsave = require("scripts.loadsave")
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")

local M = {}
M.settings = {
    toTranslatorLanguageCode = "",  --마이크로소프트에의해 번역할 목적언어(기본 없음)
    activeKidID = "",   --현재 부모가 선택한 아이 아이디(선생, 원장의 경우 기본값 "")
}

function M.saveSetting()
    if(user.userData.jobType == __PARENT__) then
        loadsave.saveTable(M.settings, __USER_SETTING_FILE_PARENT__, system.DocumentsDirectory)
    else
        loadsave.saveTable(M.settings, __USER_SETTING_FILE_TEACHER__, system.DocumentsDirectory)
    end
end

function M.loadSetting()
    local function tableMerge(t1, t2)
        for k,v in pairs(t2) do
            if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                    tableMerge(t1[k] or {}, t2[k] or {})
                else
                    t1[k] = v
                end
            else
                t1[k] = v
            end
        end
    end
    
    if(user.userData.jobType == __PARENT__) then
        if (utils.fileExist(__USER_SETTING_FILE_PARENT__, system.DocumentsDirectory) == true) then
            local local_settings = loadsave.loadTable(__USER_SETTING_FILE_PARENT__, system.DocumentsDirectory)
            tableMerge(M.settings, local_settings) --하위호환성 유지를 위해 로컬에환경 파일을 새로운 설정에 병합
        end
    else
        if (utils.fileExist(__USER_SETTING_FILE_TEACHER__, system.DocumentsDirectory) == true) then
            local local_settings = loadsave.loadTable(__USER_SETTING_FILE_TEACHER__, system.DocumentsDirectory)
            tableMerge(M.settings, local_settings) --하위호환성 유지를 위해 로컬에환경 파일을 새로운 설정에 병합
        end
    end
end

return M

