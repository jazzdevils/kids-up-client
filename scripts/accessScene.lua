---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local json = require("json")
local language = getLanguage()
local user = require("scripts.user_data")
local api = require("scripts.api")
local utils = require("scripts.commonUtils")

local M = {}
local activityIndicator
-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function getDataCallback(event)
    if ( event.isError ) then
        print( "Network error!")
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
--                    for i=1, #user.userData do
--                        user.userData[i] = nil
--                    end
                    user.freeUserData()
                    
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    local userParams = {
                        center_id = data.member.center_id,
                        center_name = data.member.center_name,
                        id = data.member.id,
                        name = data.member.name,
                        phonenum = data.member.phonenum,
                        type = data.member.type,
                        subtype = data.member.subtype,
                        img = data.member.img,
                        profileImage = profileImage,
                        approval_state = data.member.approval_state,
                        class_id = data.member.class_id,
                        class_name = data.member.class_name,
                        device_type = data.member.device_type,
                        device_token = data.member.device_token,
                        admin_yn = data.member.admin_yn,
                        class = data.class or {},
--                        message_time = data.message_time or {}
                    }
                    user.addUser(userParams)
                    if(data.member.img ~= "") then
                        if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                            network.download(
                                 data.member.img,
                                 "GET",
                                 function() end,
                                 profileImage,
                                 system.DocumentsDirectory
                            )
                        end
                    end
                    
                    for i = 1, #user.kidsList do
                        user.kidsList[i] = nil
                    end
                    local kids_count = data.member.kids_cnt
                    if(kids_count > 0) then
                        for i = 1, kids_count do
                            local kidData = data.member.kids[i] 
                            local profileImage = ""
                            if(kidData.img ~= "") then
                                profileImage = kidData.img:match("([^/]+)$")
                            end
                            local params = {
                                id = kidData.id,
                                name = kidData.name,
                                img = kidData.img,
                                birthday = kidData.birthday,
                                sex = kidData.sex,
                                approval_state = kidData.approval_state,
                                center_id = kidData.center_id,
                                center_name = kidData.center_name,
                                center_type = kidData.center_type,
                                class_id = kidData.class_id,
                                class_name = kidData.class_name,
                                registtime = kidData.registtime,
                                active = kidData.active,
                                profileImage = profileImage,
                                country_id = kidData.country_id,
                                country_name = kidData.country_name,
                                state_id = kidData.state_id,
                                state_name = kidData.state_name,
                                city_id = kidData.city_id,
                                city_name = kidData.city_name
                            }
                            user.addKid(params)
                                
                            if(kidData.img ~= "") then
                                if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                                    network.download(
                                         kidData.img,
                                         "GET",
                                         function() end,
                                         profileImage,
                                         system.DocumentsDirectory
                                    )
                                end
                            end
                        end
                    end
                    
                    user.freeDeviceList()
                    for i = 1, data.device_cnt do
                        local deviceData = data.devices[i]
                        local p = {
                            id = deviceData.id,
                            type = deviceData.type,
                            token = deviceData.token,
                            locale = deviceData.locale
                        }
                        user.addDevice(p)
                    end
                    
                    if data.member.approval_state == "1" then
                        local function classListCallback( event )
                            if ( event.isError ) then
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
--                                utils.showMessage(language["common"]["wrong_connection"])
                                storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                            else
                                print(event.status)
                                
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
                                
                                if(event.status == 200) then
                                    local data = json.decode(event.response)

                                    if (data) then
                                        if(data.status == "OK") then
                                            user.freeClassList()
                                            for i = 1, data.class_cnt do
                                                user.addClass(data.class[i])
                                            end
                                            
                                            if( user.checkValidUserData(user.userData.jobType) == true) then
                                                storyboard.purgeScene("scripts.homeScene")
                                                storyboard.gotoScene("scripts.homeScene", "crossFade", 300)
                                            else
                                                print("data valid error")
                                                storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                                            end
                                        else
                                            utils.showMessage(data.message)
                                            return true
                                        end
                                    end
                                end
                            end
                        end
                        activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
                        api.class_list_api(data.member.center_id, classListCallback)
                    else
                        storyboard.purgeScene("scripts.homeScene")
                        storyboard.gotoScene("scripts.homeScene", "crossFade", 300)
                    end
                else
                    print(language["loginScene"]["wrong_login"])
                    utils.showMessage(language["loginScene"]["wrong_login"])
                end
            end
        end
    end
    
    return true
end

local function updateMemberKidsInfo(event)
    if ( event.isError ) then
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
--                    for i=1, #user.userData do
--                        user.userData[i] = nil
--                    end
                    user.freeUserData()
                    
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    local userParams = {
                        center_id = data.member.center_id,
                        center_name = data.member.center_name,
                        id = data.member.id,
                        name = data.member.name,
                        phonenum = data.member.phonenum,
                        type = data.member.type,
                        subtype = data.member.subtype,
                        img = data.member.img,
                        profileImage = profileImage,
                        profileImage = profileImage,
                        approval_state = data.member.approval_state,
                        class_id = data.member.class_id,
                        class_name = data.member.class_name,
                        device_type = data.member.device_type,
                        device_token = data.member.device_token,
                        admin_yn = data.member.admin_yn,
                        class = data.class or {},
--                        message_time = data.message_time or {}
                    }
                    user.addUser(userParams)
                    if(data.member.img ~= "") then
                        if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                            network.download(
                                 data.member.img,
                                 "GET",
                                 function() end,
                                 profileImage,
                                 system.DocumentsDirectory
                            )
                        end
                    end
                    
                    for i = 1, #user.kidsList do
                        user.kidsList[i] = nil
                    end
                    local kids_count = data.member.kids_cnt
                    if(kids_count > 0) then
                        for i = 1, kids_count do
                            local kidData = data.member.kids[i] 
                            local profileImage = ""
                            if(kidData.img ~= "") then
                                profileImage = kidData.img:match("([^/]+)$")
                            end
                            local params = {
                                id = kidData.id,
                                name = kidData.name,
                                img = kidData.img,
                                birthday = kidData.birthday,
                                sex = kidData.sex,
                                approval_state = kidData.approval_state,
                                center_id = kidData.center_id,
                                center_name = kidData.center_name,
                                center_type = kidData.center_type,
                                class_id = kidData.class_id,
                                class_name = kidData.class_name,
                                registtime = kidData.registtime,
                                active = kidData.active,
                                profileImage = profileImage,
                                country_id = kidData.country_id,
                                country_name = kidData.country_name,
                                state_id = kidData.state_id,
                                state_name = kidData.state_name,
                                city_id = kidData.city_id,
                                city_name = kidData.city_name
                            }
                            user.addKid(params)
                                
                            if(kidData.img ~= "") then
                                if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                                    network.download(
                                         kidData.img,
                                         "GET",
                                         function() end,
                                         profileImage,
                                         system.DocumentsDirectory
                                    )
                                end
                            end
                        end
                    end
                    storyboard.purgeScene("scripts.kidslistScene")
                    storyboard.gotoScene("scripts.kidslistScene", "crossFade", 300)
                else
                    print(language["loginScene"]["wrong_login"])
                    utils.showMessage(language["joinScene"]["wrong_join"])
                end
            end
        end
    end
    
    return true
end

local function updateMemberInfo(event)
    if ( event.isError ) then
        print( "Network error!")
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
--                    for i=1, #user.userData do
--                        user.userData[i] = nil
--                    end
                    user.freeUserData()
                    
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    local userParams = {
                        center_id = data.member.center_id,
                        center_name = data.member.center_name,
                        id = data.member.id,
                        name = data.member.name,
                        phonenum = data.member.phonenum,
                        type = data.member.type,
                        subtype = data.member.subtype,
                        img = data.member.img,
                        profileImage = profileImage,
                        profileImage = profileImage,
                        approval_state = data.member.approval_state,
                        class_id = data.member.class_id,
                        class_name = data.member.class_name,
                        device_type = data.member.device_type,
                        device_token = data.member.device_token,
                        admin_yn = data.member.admin_yn,
                        class = data.class or {},
--                        message_time = data.message_time or {}
                    }
                    user.addUser(userParams)
                    if(data.member.img ~= "") then
                        if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                            network.download(
                                 data.member.img,
                                 "GET",
                                 function() end,
                                 profileImage,
                                 system.DocumentsDirectory
                            )
                        end
                    end
                    
                    if data.member.approval_state == "1" then
                        local function classListCallback( event )
                            if ( event.isError ) then
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
                                print( "Network error!")
--                                utils.showMessage(language["common"]["wrong_connection"])
                                storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                            else
                                print(event.status)
                                if(event.status == 200) then
                                    local data = json.decode(event.response)

                                    if (data) then
                                        if(data.status == "OK") then
                                            if(activityIndicator) then
                                                activityIndicator:destroy()
                                            end
                                            
                                            user.freeClassList()
                                            for i = 1, data.class_cnt do
                                                user.addClass(data.class[i])
                                            end
                                            
                                            if( user.checkValidUserData(user.userData.jobType) == true) then
                                                storyboard.purgeScene("scripts.mngHomeScene")
                                                storyboard.gotoScene("scripts.mngHomeScene", "crossFade", 300)
                                            else
                                                print("data valid error")
                                                storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                                            end
                                        else
                                            if(activityIndicator) then
                                                activityIndicator:destroy()
                                            end
                                            utils.showMessage(data.message)
                                            return true
                                        end
                                    end
                                end
                            end
                        end
                        activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
                        api.class_list_api(data.member.center_id, classListCallback)
                    else
                        storyboard.purgeScene("scripts.mngHomeScene")
                        storyboard.gotoScene("scripts.mngHomeScene", "crossFade", 300)
                    end
                else
                    print(language["loginScene"]["wrong_login"])
                    utils.showMessage(language["joinScene"]["wrong_join"])
                end
            end
        end
    end
    
    return true
end

function M:getKidsInfo(memberid)
    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
    api.get_info_by_access(memberid, getDataCallback)
end

function M:gotoKidsList(memberid)
    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
    api.get_info_by_access(memberid, updateMemberKidsInfo)
end

function M:updateMemberInfo(memberid)
    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
    api.get_info_by_access(memberid, updateMemberInfo)
end

local function autoAccesCallback(event)
    if ( event.isError ) then
        print( "Network error!")
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        if(activityIndicator) then
            activityIndicator:destroy()
        end

        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)

            if (data) then
                if(data.status == "OK") then
--                    for i=1, #user.userData do
--                        user.userData[i] = nil
--                    end
                    user.freeUserData()
                    
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    local userParams = {
                        center_id = data.member.center_id,
                        center_name = data.member.center_name,
                        id = data.member.id,
                        name = data.member.name,
                        phonenum = data.member.phonenum,
                        type = data.member.type,
                        subtype = data.member.subtype,
                        img = data.member.img,
                        profileImage = profileImage,
                        approval_state = data.member.approval_state,
                        class_id = data.member.class_id,
                        class_name = data.member.class_name,
                        device_type = data.member.device_type,
                        device_token = data.member.device_token,
                        admin_yn = data.member.admin_yn,
                        class = data.class or {},
--                        message_time = data.message_time or {}
                    }
                    user.addUser(userParams)
                    if(data.member.img ~= "") then
                        if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                            network.download(
                                 data.member.img,
                                 "GET",
                                 function() end,
                                 profileImage,
                                 system.DocumentsDirectory
                            )
                        end
                    end

                    user.freeDeviceList()
                    for i = 1, data.device_cnt do
                        local deviceData = data.devices[i]
                        local p = {
                            id = deviceData.id,
                            type = deviceData.type,
                            token = deviceData.token,
                            locale = deviceData.locale
                        }
                        user.addDevice(p)
                    end

                    if data.member.approval_state == "1" then
                        local function classListCallback( event )
                            if ( event.isError ) then
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
--                                utils.showMessage(language["common"]["wrong_connection"])
                                storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                            else
                                print(event.status)
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
                                if(event.status == 200) then
                                    local data = json.decode(event.response)
                                    if (data) then
                                        if(data.status == "OK") then
                                            user.freeClassList()
                                            for i = 1, data.class_cnt do
                                                user.addClass(data.class[i])
                                            end
                                            
                                            if( user.checkValidUserData(user.userData.jobType) == true) then
                                                storyboard.purgeScene("scripts.mngHomeScene")
                                                storyboard.gotoScene("scripts.mngHomeScene", "crossFade", 300)
                                            else
                                                print("data valid error")
                                                storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                                            end
                                        else
                                            utils.showMessage(data.message)
                                            return true
                                        end
                                    end
                                end
                            end
                        end
                        activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
                        api.class_list_api(data.member.center_id, classListCallback)
                    else
                        storyboard.purgeScene("scripts.mngHomeScene")
                        storyboard.gotoScene("scripts.mngHomeScene", "crossFade", 300)
                    end
                else
                    print(language["loginScene"]["wrong_login"])
                    utils.showMessage(language["loginScene"]["wrong_login"])
                end
            end
        end
    end

    return true
end

function M:gotoMngHomeSceneFromAutoAccess(appPropertyData)
    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
    api.get_info_by_access(appPropertyData.member.id, autoAccesCallback)
end

function M:gotoMngHomeSceneFromLogin(data)
    local profileImage = ""
    if(data.member.img ~= "") then
        profileImage = data.member.img:match("([^/]+)$")
    end
    
    user.freeUserData()
    local userParams = {
        center_id = data.member.center_id,
        center_name = data.member.center_name,
        id = data.member.id,
        name = data.member.name,
        phonenum = data.member.phonenum,
        type = data.member.type,
        subtype = data.member.subtype,
        img = data.member.img,
        profileImage = profileImage,
        approval_state = data.member.approval_state,
        class_id = data.member.class_id,
        class_name = data.member.class_name,
        admin_yn = data.member.admin_yn,
        class = data.class or {},
--        message_time = data.message_time or {}
    }
    user.addUser(userParams)
    
    local function callback(event)
        if ( event.isError ) then
            print( "Network error!")
        else
            print(event.status)
            if(event.status == 200) then
                print ( "RESPONSE: " .. event.response )
                local data = json.decode(event.response)

                if (data) then
                    if(data.status == "OK") then
                        user.freeDeviceList()
                        for i = 1, data.device_cnt do
                            local deviceData = data.devices[i]
                            local p = {
                                id = deviceData.id,
                                type = deviceData.type,
                                token = deviceData.token,
                                locale = deviceData.locale
                            }
                            user.addDevice(p)
                        end
                    else
                        print("device token update FAIL!")
                    end
                end
            end
        end
        
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        if data.member.approval_state == "1" then
            local function classListCallback( event )
                if ( event.isError ) then
                    if(activityIndicator) then
                        activityIndicator:destroy()
                    end
                    print( "Network error!")
--                    utils.showMessage( language["common"]["wrong_connection"] )
                    storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                else
                    print(event.status)
                    if(event.status == 200) then
                        local data = json.decode(event.response)

                        if (data) then
                            if(data.status == "OK") then
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
                                
                                user.freeClassList()
                                for i = 1, data.class_cnt do
                                    user.addClass(data.class[i])
                                end
                                
                                if( user.checkValidUserData(user.userData.jobType) == true) then
                                    storyboard.purgeScene("scripts.mngHomeScene")
                                    storyboard.gotoScene( "scripts.mngHomeScene", "crossFade", 300) 
                                else
                                    print("data valid error")
                                    storyboard.gotoScene("scripts.loginErrorScene", "crossFade", 300)
                                end
                            else
                                if(activityIndicator) then
                                    activityIndicator:destroy()
                                end
                                utils.showMessage( data.message )
                                return true
                            end
                        end
                    end
                end
            end
            activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
            api.class_list_api(data.member.center_id, classListCallback) 
        else
            if(activityIndicator) then
                activityIndicator:destroy()
            end
            storyboard.gotoScene( "scripts.mngHomeScene", "crossFade", 300) 
        end
        
        return true
    end
    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
    api.get_device_tokens(data.member.id, callback)    
end

return M