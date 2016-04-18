---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_sharePanel")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local userSetting = require("scripts.userSetting")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local user = require("scripts.user_data")
local sceneData = require("scripts.sceneData")
local push = require("scripts.push")
--local api = require("scripts.api")
local widget = require("widget")
local func = require("scripts.commonFunc")

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90
local profileImg
local PROFILE_IMG_EXIST = false

local new_message_icon 
local btn_message

local new_notice_icon
local btn_notice

local new_event_icon
local btn_event

local new_menu_icon
local btn_mealMenu
                                
local new_manage_icon
local btn_management

local new_alarm_icon
local btn_alarm

local imageTimer

local function onTouchMenu(event)
    if event.phase == "ended" then        
        if(event.target.name == "btn_alarm") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else    
                storyboard.isAction = true
                storyboard.purgeScene("scripts.newsScene")
                storyboard.gotoScene("scripts.newsScene", "crossFade", 300)
            end
        elseif(event.target.name == "btn_management") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                storyboard.isAction = true
                if user.userData.jobType == __DIRECTOR__ then
                    storyboard.purgeScene("scripts.mngDirectorScene")
                    storyboard.gotoScene("scripts.mngDirectorScene", "crossFade", 300)
                elseif user.userData.jobType == __TEACHER__ then
                    storyboard.purgeScene("scripts.mngTeacherScene")
                    storyboard.gotoScene("scripts.mngTeacherScene", "crossFade", 300)    
                end
            end    
        elseif(event.target.name == "btn_message") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                storyboard.isAction = true
                storyboard.purgeScene("scripts.messageScene")
                storyboard.gotoScene("scripts.messageScene", "crossFade", 300)
            end
        elseif(event.target.name == "btn_settings") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingScene")
            storyboard.gotoScene("scripts.settingScene", "crossFade", 300)
        elseif(event.target.name == "btn_notice") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                storyboard.isAction = true
                storyboard.purgeScene("scripts.noticeScene")
                storyboard.gotoScene("scripts.noticeScene", "crossFade", 300)
            end
        elseif(event.target.name == "btn_schedule") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                storyboard.isAction = true
                storyboard.purgeScene("scripts.calendarScene")
                storyboard.gotoScene("scripts.calendarScene", "crossFade", 300)
            end
        elseif(event.target.name == "btn_event") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                storyboard.isAction = true
                storyboard.purgeScene("scripts.eventScene")
                storyboard.gotoScene("scripts.eventScene", "crossFade", 300)
            end
        elseif(event.target.name == "btn_album") then
            --storyboard.gotoScene("scripts.albumListScene", "crossFade", 300)
            utils.showMessage("goto services Scene")
        elseif(event.target.name == "btn_mealMenu") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                storyboard.isAction = true
                storyboard.purgeScene("scripts.mealMenuListScene")
                storyboard.gotoScene("scripts.mealMenuListScene", "crossFade", 300)
            end
        elseif(event.target.name == "btn_services") then
            if user.userData.approvalState ~= '1' then
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            else
                utils.showMessage("goto services Scene")
            end
        elseif(event.target.name == "info_edit") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.memberInfoUpdateScene")
            storyboard.gotoScene("scripts.memberInfoUpdateScene", "crossFade", 300)
        elseif(event.target.name == "btn_class") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.mngClassListScene")
            storyboard.gotoScene("scripts.mngClassListScene", "crossFade", 300)
        end
        
        return true
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    if utils.IS_Demo_mode(storyboard, false) == false then
        push:updateDeviceToken()
    end    
    
    __DEFAULT_HOMESCENE_NAME__ = storyboard.getCurrentSceneName()
    
    sceneData.freeAllSceneData() --공유데이터 모두 삭제
    
    userSetting.loadSetting() --사용자의 환경설정 파일로딩
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    group:insert(bg)
    
    local bg_box = display.newImageRect(group, "images/bg_set/bg_menu_big_top.png", __appContentWidth__ - 40, 100)
    bg_box.anchorY = 0
    bg_box.x = display.contentCenterX
    if(display.contentHeight < 500) then
        bg_box.y = 30
    else
        bg_box.y = 70
    end
    bg_box.alpha = 0.5
    group:insert(bg_box)
    bg_box.name = "info_edit"
    bg_box:addEventListener("touch", onTouchMenu)
    
    if(utils.fileExist(user.userData.profileImage, system.DocumentsDirectory) == true) then
        PROFILE_IMG_EXIST = true
        profileImg = display.newImageRect(group, user.userData.profileImage, system.DocumentsDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    else
        profileImg = display.newImageRect(group, "images/main_menu_icons/pic_photo_80x80.png", PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
        if (user.userData.profileImage and user.userData.profileImage ~= "") then
            local function imageDownloadListener( event )
                if ( event.isError ) then
                elseif ( event.phase == "began" ) then
                elseif ( event.phase == "ended" ) then
                    if(event.response.filename and event.response.baseDirectory) then
                        profileImg:removeSelf()
                        profileImg = nil
                        profileImg = display.newImageRect(group, event.response.filename, event.response.baseDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
                        profileImg.anchorX = 0
                        profileImg.x = 30
                        profileImg.anchorY = 0
                        profileImg.y = bg_box.y + (bg_box.height - profileImg.height) * 0.5
                        profileImg.name = "info_edit"
                        profileImg:addEventListener("touch", onTouchMenu)
                    end
                end
            end
            network.download(
                user.userData.img,
                "GET",
                imageDownloadListener,
                user.userData.profileImage,
                system.DocumentsDirectory
            )
        end
    end

    profileImg.anchorX = 0
    profileImg.x = 30
    profileImg.anchorY = 0
    profileImg.y = bg_box.y + (bg_box.height - profileImg.height) * 0.5
    profileImg.name = "info_edit"
    profileImg:addEventListener("touch", onTouchMenu)
    
    local profileImgFrame  = display.newImageRect(group, "images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 4, PROFILE_IMAGE_SIZE_HEIGHT + 4)
    profileImgFrame.anchorX = 0
    profileImgFrame.anchorY = 0
    profileImgFrame.x = profileImg.x - 1
    profileImgFrame.y = profileImg.y - 1
    
    local typeText = language["mngHomeScene"]["type1"]
    if user.userData.jobType == __TEACHER__ then
        typeText = language["mngHomeScene"]["type2"]
    end
    local type_text_options = 
    {
        parent = group,
        text = typeText,
        font = native.systemFontBold,   
        fontSize = __textLabelFontSize__,
        align = "left"  
    }
    local type_txt_name = display.newText(type_text_options)
    type_txt_name.anchorX = 0
    type_txt_name.anchorY = 0
    type_txt_name.x = profileImg.x + profileImg.width + 10
    type_txt_name.y = profileImg.y
    type_txt_name:setFillColor( 0, 0, 0 )
    group:insert(type_txt_name)
    
    local name_text_options = 
    {
        parent = group,
        text = user.userData.name,
        font = native.systemFontBold,   
        fontSize = __textLabelFontSize__,
        align = "left"  
    }
    local txt_name = display.newText(name_text_options)
    txt_name.anchorX = 0
    txt_name.anchorY = 0
    txt_name.x = profileImg.x + profileImg.width + 10
    txt_name.y = profileImg.y + 25
    txt_name:setFillColor( 0, 0, 0 )
    group:insert(txt_name)
    
    local centerNameTextOptions = 
    {
        parent = group,
        text = user.userData.centerName,
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "left"  
    }
    local centerNameLabel = display.newText(centerNameTextOptions)
    centerNameLabel.anchorX = 0
    centerNameLabel.anchorY = 0
    centerNameLabel.x = txt_name.x
    centerNameLabel.y = txt_name.y + txt_name.height + 5
    centerNameLabel:setFillColor( 0, 0, 0 )
    group:insert(centerNameLabel)
    
    local strClassName = ""
    if user.userData.jobType == __DIRECTOR__ then
        if user.userData.ClassListOfTeacher and #user.userData.ClassListOfTeacher > 0 then
            user.userData.classId = user.userData.ClassListOfTeacher[1].id --기본으로 첫번째 클래스 아이디를 호출
            user.userData.className = user.userData.ClassListOfTeacher[1].name
        end
    elseif user.userData.jobType == __TEACHER__ then
        user.userData.classId = user.userData.ClassListOfTeacher[1].id --기본으로 첫번째 클래스 아이디를 호출
        user.userData.className = user.userData.ClassListOfTeacher[1].name
        
        strClassName = user.getClassNameOfTeacher4Display()
    end
    
    local centerClassName_text_options = 
    {
        parent = group,
        text = strClassName,
        x = txt_name.x,
        y = centerNameLabel.y + centerNameLabel.height + 5,
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "left"  
    }
    local txt_centerClassName = display.newText(centerClassName_text_options)
    txt_centerClassName.anchorX = 0
    txt_centerClassName.anchorY = 0
    txt_centerClassName:setFillColor( 0, 0, 0 )
    group:insert(txt_centerClassName)
    
    local bg_bottom_box = display.newImageRect(group, "images/bg_set/bg_menu_big_bottom.png", __appContentWidth__ - 40, 265)
    bg_bottom_box.anchorY = 0
    bg_bottom_box.x = display.contentCenterX
    bg_bottom_box.y = bg_box.y + bg_box.height
    bg_bottom_box.alpha = 0.5
    group:insert(bg_bottom_box)
    
    local cellWidht = (__appContentWidth__ - 20) / 3
    local startX = 20

--    begin 1Row
    btn_alarm = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_alarm.png",
        overFile = "images/main_menu_icons/btn_main_alarm_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_alarm)
    btn_alarm.x = startX + (cellWidht / 2)
    btn_alarm.anchorY = 0
    btn_alarm.y = bg_bottom_box.y + 5
    btn_alarm.name = "btn_alarm"
    
    local introduce_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_news"],     
        x = startX + (cellWidht / 2),
        y = btn_alarm.y + btn_alarm.height,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_introduce = display.newText(introduce_text_options)
    txt_introduce.anchorY = 0
    txt_introduce:setFillColor(0.4, 0.5, 0.6)
    
    btn_message = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_news.png",
        overFile = "images/main_menu_icons/btn_main_news_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_message)
    btn_message.x = display.contentCenterX
    btn_message.anchorY = 0
    btn_message.y = btn_alarm.y
    btn_message.name = "btn_message"
   
    local news_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_news"],     
        x = display.contentCenterX,
        y = txt_introduce.y,  
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_news = display.newText(news_text_options)
    txt_news.anchorY = 0
    txt_news:setFillColor( 0.4, 0.5, 0.6)
    
    btn_notice = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_notice.png",
        overFile = "images/main_menu_icons/btn_main_notice_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_notice)
    btn_notice.x = display.contentCenterX + cellWidht - 10
    btn_notice.anchorY = 0
    btn_notice.y = btn_message.y
    btn_notice.name = "btn_notice"
    
    local notice_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_notice"],     
        x = btn_notice.x,
        y = txt_introduce.y,   
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local notice_txt = display.newText(notice_text_options)
    notice_txt.anchorY = 0
    notice_txt:setFillColor( 0.4, 0.5, 0.6)
    
--    begin 2Row
    btn_mealMenu = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_lunch.png",
        overFile = "images/main_menu_icons/btn_main_lunch_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_mealMenu)
    btn_mealMenu.anchorY = 0
    btn_mealMenu.x = btn_alarm.x
    btn_mealMenu.y = notice_txt.y + notice_txt.height + 10
    btn_mealMenu.name = "btn_mealMenu"
    
    local meal_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_mealmenu"],     
        x = startX + (cellWidht / 2),
        y = btn_mealMenu.y + btn_mealMenu.height,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_mealMenu = display.newText(meal_text_options)
    txt_mealMenu.anchorY = 0
    txt_mealMenu:setFillColor(0.4, 0.5, 0.6)
    txt_mealMenu:addEventListener("touch", onTouchMenu)
    
    btn_event = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_event.png",
        overFile = "images/main_menu_icons/btn_main_event_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_event)
    btn_event.anchorY = 0
    btn_event.x = display.contentCenterX
    btn_event.y = btn_mealMenu.y
    btn_event.name = "btn_event"
    
    local event_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_event"],     
        x = display.contentCenterX,
        y = txt_mealMenu.y,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_event = display.newText(event_text_options)
    txt_event.anchorY = 0
    txt_event:setFillColor(0.4, 0.5, 0.6)
    
    local btn_schedule = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_schedule.png",
        overFile = "images/main_menu_icons/btn_main_schedule_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_schedule)
    btn_schedule.anchorY = 0
    btn_schedule.x = btn_notice.x
    btn_schedule.y = btn_mealMenu.y
    btn_schedule.name = "btn_schedule"
        
    local schedule_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_schedule"],     
        x = notice_txt.x,
        y = txt_mealMenu.y,
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_class = display.newText(schedule_text_options)
    txt_class.anchorY = 0
    txt_class:setFillColor(0.4, 0.5, 0.6)
    
    btn_management = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_services.png",
        overFile = "images/main_menu_icons/btn_main_services_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_management)
    btn_management.x = btn_alarm.x
    btn_management.anchorY = 0
    btn_management.y = txt_mealMenu.y + txt_mealMenu.height + 10
    btn_management.name = "btn_management"
    
    local mng_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_management"],
        x = startX + (cellWidht / 2),
        y = btn_management.y + btn_management.height,  
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_management = display.newText(mng_text_options)
    txt_management.anchorY = 0
    txt_management:setFillColor(0.4, 0.5, 0.6)
    
    local btn_settings = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_setting.png",
        overFile = "images/main_menu_icons/btn_main_setting_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_settings)
    btn_settings.anchorY = 0
    btn_settings.x = display.contentCenterX
    btn_settings.y = txt_mealMenu.y + txt_mealMenu.height + 10
    btn_settings.name = "btn_settings"
    
    local settings_text_options = 
    {
        parent = group,
        text = language["mngHomeScene"]["mnu_setting"],     
        x = display.contentCenterX,
        y = btn_settings.y + btn_settings.height,
        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_settings = display.newText(settings_text_options)
    txt_settings.anchorY = 0
    txt_settings:setFillColor(0.4, 0.5, 0.6)
    
    local logo_footer = display.newImageRect(group, "images/logo/logo_footer.png", __backgroundWidth__, 30)
    logo_footer.x = display.contentCenterX
    logo_footer.anchorY = 0
    logo_footer.y = __appContentHeight__ - logo_footer.height
    group:insert(logo_footer)
    
    local footer = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    footer.x = display.contentCenterX
    footer.anchorY = 0
    footer.y = __appContentHeight__ - logo_footer.height - footer.height
    group:insert(footer)
    
    if utils.IS_Demo_mode( storyboard, false) == true then
--      체험하기 로그아웃 버튼
        local tourClose_button = widget.newButton
        {
            width = bg_bottom_box.width ,
            height = 40 ,
            left = 0,--display.contentCenterX - (155/2)  , 
--            top = display.contentCenterY + 105, 
            defaultFile = "images/button/btn_purple_1_normal.png",
            overFile = "images/button/btn_purple_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            labelYOffset = -2,
            fontSize = __textSubMenuFontSize__,
            label = language["tourScene"]["tour_close"],
            onRelease = function(event)
                            if event.phase == "ended" then --or event.phase == "cancelled" then
                                local options = {
                                    effect = "fromRight",
                                    time = 300,
                                    params = {
                                        fromLogout = true,
                                    }
                                }   
                        --        사용자 데이타 free
                                user.freeClassList()
                                user.freeKidsList()
                                user.freeUserData()
                                user.freeDeviceList()

                        --        씬 데이타 free
                                sceneData.freeAllSceneData()

                                utils.setAppPropertyData("logined","0")
                                storyboard.returnTo = nil
                                local deviceType = storyboard.state.DEVICE_TYPE
                                local deviceToken = storyboard.state.DEVICE_TOKEN
                                storyboard.state = {}
                                storyboard.state.DEVICE_TYPE = deviceType
                                storyboard.state.DEVICE_TOKEN  = deviceToken
                                storyboard.purgeScene("scripts.top")
                                storyboard.gotoScene("scripts.top", options)  
                            end
                        end
        }
        tourClose_button.x = display.contentCenterX
        tourClose_button.ancherY = 0
        tourClose_button.y = bg_bottom_box.y + bg_bottom_box.height + (tourClose_button.height * 0.5) + 2
        group:insert(tourClose_button)
    end
    
--  N maker
    display.remove(new_message_icon)
    display.remove(new_notice_icon)
    display.remove(new_event_icon)
    display.remove(new_menu_icon)
    display.remove(new_manage_icon)
    display.remove(new_alarm_icon)
    
    __NEW_MESSAGE_COUNT__   = 0
    __NEW_NOTICE_COUNT__    = 0
    __NEW_EVENT_COUNT__     = 0
    __NEW_MENU_COUNT__      = 0
    __NEW_MANAGE_COUNT__    = 0
    __NEW_MAMATALK_COUNT__  = 0
    __NEW_NEWS_COUNT__      = 0
            
    new_message_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_message_icon.anchorY = 0
    new_message_icon.x = btn_message.x - btn_message.width * 0.5 + 10
    new_message_icon.y = btn_message.y
    new_message_icon.isVisible = false
    __NEW_ICON_SET__.new_message_icon = new_message_icon
    group:insert(new_message_icon)

    new_notice_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_notice_icon.anchorY = 0
    new_notice_icon.x = btn_notice.x - btn_notice.width * 0.5 + 10
    new_notice_icon.y = btn_notice.y
    new_notice_icon.isVisible = false
    __NEW_ICON_SET__.new_notice_icon = new_notice_icon
    group:insert(new_notice_icon)

    new_event_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_event_icon.anchorY = 0
    new_event_icon.x = btn_event.x - btn_event.width * 0.5 + 10
    new_event_icon.y = btn_event.y
    new_event_icon.isVisible = false
    __NEW_ICON_SET__.new_event_icon = new_event_icon
    group:insert(new_event_icon)

    new_menu_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_menu_icon.anchorY = 0
    new_menu_icon.x = btn_mealMenu.x - btn_mealMenu.width * 0.5 + 10
    new_menu_icon.y = btn_mealMenu.y
    new_menu_icon.isVisible = false
    __NEW_ICON_SET__.new_menu_icon = new_menu_icon
    group:insert(new_menu_icon)

    new_alarm_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_alarm_icon.anchorY = 0
    new_alarm_icon.x = btn_alarm.x - btn_alarm.width * 0.5 + 10
    new_alarm_icon.y = btn_alarm.y
    new_alarm_icon.isVisible = false
    __NEW_ICON_SET__.new_alarm_icon = new_alarm_icon
    group:insert(new_alarm_icon)

    new_manage_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_manage_icon.anchorY = 0
    new_manage_icon.x = btn_management.x - btn_management.width * 0.5 + 10
    new_manage_icon.y = btn_management.y
    new_manage_icon.isVisible = false
    __NEW_ICON_SET__.new_manage_icon = new_manage_icon
    group:insert(new_manage_icon)
            
    func.get_news4Home() --새로운 새소식 갱신
    
--    if utils.IS_Demo_mode( storyboard, false) == false then
--        if user.userData.jobType == __DIRECTOR__ and user.userData.approvalState == '1' then 
--            if #user.classList == 0 then --원장이면서 인증을 받았으나 아직 반 개설이 안되어 있는경우 메세지...
--                utils.showMessage(language["mngHomeScene"]["no_class"], 7000)
--                
--                local function onPageSwipeOnTimer( event )
--                    if btn_management.alpha == 0 then
--                       transition.to(btn_management, {time = 300, alpha = 1})
--                    else
--                       transition.to(btn_management, {time = 300, alpha = 0})
--                    end
--                end
--                
--                imageTimer = timer.performWithDelay(500, onPageSwipeOnTimer, 0)
--            end
--        end
--    end
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.removeAll()
    
    func.refresh_Home_New_icon()
    
    if utils.IS_Demo_mode( storyboard, false) == true then
        utils.create_iOSPushPopup4Tour(user.userData.jobType)
    else
        --  아이콘의 뱃지 카운트 리셋  
        native.setProperty( "applicationIconBadgeNumber", 0 ) 
        
        if user.userData.jobType == __DIRECTOR__ and user.userData.approvalState == '1' then 
            if #user.classList == 0 then --원장이면서 인증을 받았으나 아직 반 개설이 안되어 있는경우 메세지...
                utils.showMessage(language["mngHomeScene"]["no_class"], 5000)
                
                local function onPageSwipeOnTimer( event )
                    if btn_management.alpha == 0 then
                       transition.to(btn_management, {time = 400, alpha = 1})
                    else
                       transition.to(btn_management, {time = 400, alpha = 0})
                    end
                end
                
                imageTimer = timer.performWithDelay(500, onPageSwipeOnTimer, 0)
            else
                if btn_management.alpha ~= 1 then
                    btn_management.alpha = 1
                end
            end
        end
    end
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if(imageTimer) then
        timer.cancel(imageTimer) 
        imageTimer = nil
    end
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    print( "Showing overlay: " .. event.sceneName )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    print( "Overlay removed: " .. event.sceneName )    
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene

