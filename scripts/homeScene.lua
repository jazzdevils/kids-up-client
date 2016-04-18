---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local user = require("scripts.user_data")
local sceneData = require("scripts.sceneData")
local userSetting = require("scripts.userSetting")
local push = require("scripts.push")
--local api = require("scripts.api")
local widget = require("widget")
local func = require("scripts.commonFunc")

local activeKidData
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90

local new_message_icon 
local btn_message

local new_notice_icon
local btn_notice

local new_event_icon
local btn_event

local new_menu_icon
local btn_menu
                                
local new_mamatalk_icon
local btn_mamatalk

local new_alarm_icon
local btn_alarm

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onTouchMenu(event)
    if event.phase == "ended" then
        if(event.target.name ~= "mnu_kidslist" and event.target.name ~= "btn_settings") then
            if(activeKidData) then
                if(activeKidData.approval_state ~= "1") then
                    utils.showMessage( language["homeScene"]["not_approved_yet"] )
                    return false
                end
            else    
                utils.showMessage( language["homeScene"]["no_active_kids"] )
                return false
            end
        end
        
        if(event.target.name == "btn_alarm") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.newsScene")
            storyboard.gotoScene("scripts.newsScene", "crossFade", 300)
        elseif(event.target.name == "btn_message") then
--            local alert = native.showAlert( "subMenu", "goto message Scene", { "OK" }, nil)
            storyboard.isAction = true
            storyboard.purgeScene("scripts.messageScene")
            storyboard.gotoScene("scripts.messageScene", "crossFade", 300)
        elseif(event.target.name == "btn_notice") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.noticeScene")
            storyboard.gotoScene("scripts.noticeScene", "crossFade", 300)
        elseif(event.target.name == "btn_mamatalk") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.mamatalkScene")
            storyboard.gotoScene("scripts.mamatalkScene", "crossFade", 300)
        elseif(event.target.name == "btn_schedule") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.calendarScene")
            storyboard.gotoScene("scripts.calendarScene", "crossFade", 300)
        elseif(event.target.name == "btn_event") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.eventScene")
            storyboard.gotoScene("scripts.eventScene", "crossFade", 300)
        elseif(event.target.name == "btn_album") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.albumListScene")
            storyboard.gotoScene("scripts.albumListScene", "crossFade", 300)
        elseif(event.target.name == "btn_mealMenu") then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.mealMenuListScene")
            storyboard.gotoScene("scripts.mealMenuListScene", "crossFade", 300)
        elseif(event.target.name == "btn_settings") then
--            storyboard.showOverlay( "scripts.servicesScene" ,{effect = "fade", time=300, params ={text = "전체반이 공유할 수 있는 내용입니다."}, isModal = false} )
            storyboard.isAction = true
            storyboard.gotoScene("scripts.settingScene", "crossFade", 300)
        elseif(event.target.name == "mnu_kidslist") then
--            ga.track("homeButton")
            storyboard.isAction = true
            storyboard.purgeScene("scripts.kidslistScene")
            storyboard.gotoScene("scripts.kidslistScene", "crossFade", 300)
        end    
        
        return true
    end
end

local function onBgTap(event)
    local filePath = system.pathForFile( "data/particle_texture.json")
    local f = io.open( filePath, "r" )
    local fileData = f:read( "*a" )
    f:close()

    local emitterParams = json.decode( fileData )

    local emitter1 = display.newEmitter( emitterParams )

    emitter1.anchorX = 0
    emitter1.anchorY = 0
    emitter1.x = event.x
    emitter1.y = event.y
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
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
--    bg:addEventListener("tap", onBgTap)
    
    local bg_box = display.newImageRect(group, "images/bg_set/bg_menu_big_top.png", display.contentWidth - 40, 100)
    bg_box.anchorY = 0
    bg_box.x = display.contentCenterX
    if(display.contentHeight < 500) then
        bg_box.y = 30
    else
        bg_box.y = 70
    end
    
    bg_box.alpha = 0.5
    group:insert(bg_box)
    bg_box.name = "mnu_kidslist"
    bg_box:addEventListener("touch", onTouchMenu)
    
    if userSetting.settings.activeKidID and userSetting.settings.activeKidID ~="" then
        activeKidData = user.getKidData(userSetting.settings.activeKidID)
        if activeKidData then
            user.setActiveKid(userSetting.settings.activeKidID) --파일에 있는 아이의 아이디가 액티브아이디
            
            user.userData.classId = activeKidData.class_id --액티브된 아이의 반아이디와 이름을 넘겨줌
            user.userData.className = activeKidData.class_name
        else
            activeKidData = user.getActiveKidData()
        end
    else
        activeKidData = user.getActiveKidData()
    end
    
    local icon_sex = nil
    local btn_profile
    if(activeKidData and activeKidData.profileImage ~= "") then
        if(utils.fileExist(activeKidData.profileImage, system.DocumentsDirectory) == true) then
            btn_profile = display.newImageRect(group, activeKidData.profileImage, system.DocumentsDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
        else
            local defaultImage = "images/main_menu_icons/pic_photo_80x90.png"
            btn_profile = display.newImageRect(group, defaultImage, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
            if activeKidData.profileImage then
                local function imageDownloadListener( event )
                    if ( event.isError ) then
                    elseif ( event.phase == "began" ) then
                    elseif ( event.phase == "ended" ) then
                        if(event.response.filename and event.response.baseDirectory) then
                            btn_profile:removeSelf()
                            btn_profile = nil
                            btn_profile = display.newImageRect(group, event.response.filename, event.response.baseDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
                            btn_profile.anchorX = 0
                            btn_profile.anchorY = 0
                            btn_profile.x = 30
                            btn_profile.y = bg_box.y + 6 
                            group:insert(btn_profile)
                        end
                    end
                end
                network.download(
                    activeKidData.img,
                    "GET",
                    imageDownloadListener,
                    activeKidData.profileImage,
                    system.DocumentsDirectory
                )
            end
        end
    else
        local defaultImage = "images/main_menu_icons/pic_photo_80x90.png"
        btn_profile = display.newImageRect(group, defaultImage, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    end
        
    btn_profile.anchorX = 0
    btn_profile.anchorY = 0
    btn_profile.x = 30
    btn_profile.y = bg_box.y + 6 
    group:insert(btn_profile)  
    
    local profileImageFrame = display.newImageRect("images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 4, PROFILE_IMAGE_SIZE_HEIGHT + 4)
    profileImageFrame.anchorX = 0
    profileImageFrame.anchorY = 0
    profileImageFrame.x = btn_profile.x - 2
    profileImageFrame.y = btn_profile.y - 2
    group:insert(profileImageFrame)
    
    if(activeKidData) then
        if(activeKidData.sex == __BOY_TYPE__) then
            icon_sex = display.newImageRect("images/assets1/icon_boy.png", 18 , 18)
        else
            icon_sex = display.newImageRect("images/assets1/icon_girl.png", 18 , 18)
        end
        icon_sex.anchorX = 0
        icon_sex.anchorY = 0
        icon_sex.x = btn_profile.x + btn_profile.width - icon_sex.width - 2
        icon_sex.y = btn_profile.y + btn_profile.height - icon_sex.height - 2
        icon_sex:toFront()
        group:insert(icon_sex)
    end
    
    local tmpNameTxt 
    if(activeKidData and activeKidData.name ~= "") then
        tmpNameTxt = activeKidData.name
    else
        tmpNameTxt = ""
    end
    local name_text_options = 
    {
        parent = group,
        text = tmpNameTxt,     
        x = btn_profile.x + btn_profile.width + 10,
        y = btn_profile.y + 10,
--        width = 128,     
        font = native.systemFont,   
        fontSize = __textLabelFontSize__,
        align = "left"  
    }
    local txt_name = display.newText(name_text_options)
    txt_name.anchorX = 0
    txt_name.anchorY = 0
    txt_name:setFillColor( 0, 0, 0 )
    group:insert(txt_name)
        
    local tmpBirthdayTxt 
    if(activeKidData and activeKidData.birthday ~= "") then
        local lifeDays = utils.getLifeTimeFromBirthday(string.sub(activeKidData.birthday, 1, 4)
            , string.sub(activeKidData.birthday, 5, 6), string.sub(activeKidData.birthday, 7, 8))
            
        tmpBirthdayTxt = utils.convert2LocaleDateString(string.sub(activeKidData.birthday, 1, 4), string.sub(activeKidData.birthday, 5, 6)
            , string.sub(activeKidData.birthday, 7, 8)).." ("..lifeDays..language["homeScene"]["life_days"]..")"
    else
        tmpBirthdayTxt = ""
    end
    local birthday_text_options = 
    {
        parent = group,
        text = tmpBirthdayTxt,
        x = txt_name.x,
        y = txt_name.y + txt_name.height + 3,
--        width = 128,     
        font = native.systemFont,   
        fontSize = __buttonFontSize__,
        align = "left"  
    }
    local txt_birthday = display.newText(birthday_text_options)
    txt_birthday.anchorX = 0
    txt_birthday.anchorY = 0
    txt_birthday:setFillColor( 0, 0, 0 )
    group:insert(txt_birthday)
    
    local centerName = ""
    local className = ""
    if(activeKidData) then
        if(activeKidData.center_id and activeKidData.center_id ~= "") then
            centerName  = activeKidData.center_name
            className = activeKidData.class_name
        end
    end
        
    if(centerName ~= "" and className ~= "") then
        local centerName_text_options = 
        {
            parent = group,
            text = centerName,
            x = txt_name.x,
            y = txt_birthday.y + txt_birthday.height + 3,
    --        width = 160,     
            font = native.systemFont,   
            fontSize = __buttonFontSize__,
            align = "left"  
        }
        
        local txt_centerName = display.newText(centerName_text_options)
        txt_centerName.anchorX = 0
        txt_centerName.anchorY = 0
        txt_centerName:setFillColor( 0, 0, 0 )
        group:insert(txt_centerName)
        
        local className_text_options = 
        {
            parent = group,
            text = className,
            x = txt_name.x,
            y = txt_centerName.y + txt_centerName.height + 3,
    --        width = 160,     
            font = native.systemFont,   
            fontSize = __buttonFontSize__,
            align = "left"  
        }
        
        local txt_className = display.newText(className_text_options)
        txt_className.anchorX = 0
        txt_className.anchorY = 0
        txt_className:setFillColor( 0, 0, 0 )
        group:insert(txt_className)
    end
        
    local bg_bottom_box = display.newImageRect(group, "images/bg_set/bg_menu_big_bottom.png", display.contentWidth - 40, 265)
    bg_bottom_box.anchorY = 0
    bg_bottom_box.x = display.contentCenterX
    bg_bottom_box.y = bg_box.y + bg_box.height
    bg_bottom_box.alpha = 0.5
    group:insert(bg_bottom_box)
    
    
--    begin 1Row
    local cellWidht = (display.contentWidth - 20) / 3
    local startX = 20
    
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
        text = language["homeScene"]["mnu_message"],     
        x = display.contentCenterX,
        y = txt_introduce.y,
--        width = 60,     
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
        text = language["homeScene"]["mnu_notice"],     
        x = btn_notice.x,
        y = txt_introduce.y,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local notice_txt = display.newText(notice_text_options)
    notice_txt.anchorY = 0
    notice_txt:setFillColor( 0.4, 0.5, 0.6)
--    end 1Row
    
--    begin 2Row
    btn_mamatalk = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_diary.png",
        overFile = "images/main_menu_icons/btn_main_diary_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_mamatalk)
    btn_mamatalk.anchorY = 0
    btn_mamatalk.x = btn_alarm.x
    btn_mamatalk.y = notice_txt.y + notice_txt.height + 10
    btn_mamatalk.name = "btn_mamatalk"
    
    local mamatalk_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_mamatalk"],     
        x = btn_mamatalk.x,
        y = btn_mamatalk.y + btn_mamatalk.height,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_story = display.newText(mamatalk_text_options)
    txt_story.anchorY = 0
    txt_story:setFillColor(0.4, 0.5, 0.6)
    
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
    btn_schedule.x = display.contentCenterX
    btn_schedule.y = btn_mamatalk.y
    btn_schedule.name = "btn_schedule"
    
    local schedule_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_schedule"],     
        x = display.contentCenterX,
        y = txt_story.y,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_schedule = display.newText(schedule_text_options)
    txt_schedule.anchorY = 0
    txt_schedule:setFillColor(0.4, 0.5, 0.6)
    
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
    btn_event.x = btn_notice.x
    btn_event.y = btn_mamatalk.y
    btn_event.name = "btn_event"
    
    local event_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_event"],     
        x = btn_event.x,
        y = txt_schedule.y,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local event_txt = display.newText(event_text_options)
    event_txt.anchorY = 0
    event_txt:setFillColor( 0.4, 0.5, 0.6)
--    end 2Row

--    begin 3Row
    local btn_album = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_album.png",
        overFile = "images/main_menu_icons/btn_main_album_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_album)
    btn_album.anchorY = 0
    btn_album.x = btn_alarm.x
    btn_album.y = event_txt.y + event_txt.height + 10
    btn_album.name = "btn_album"
    
    local album_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_album"],     
        x = btn_album.x,
        y = btn_album.y + btn_album.height,
        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_album = display.newText(album_text_options)
    txt_album.anchorY = 0
    txt_album:setFillColor(0.4, 0.5, 0.6)
    
    btn_menu = widget.newButton
    {
        width = 60,
        height = 60,
        defaultFile = "images/main_menu_icons/btn_main_lunch.png",
        overFile = "images/main_menu_icons/btn_main_lunch_touched.png",
        onEvent = onTouchMenu,
    }
    group:insert(btn_menu)
    btn_menu.anchorY = 0
    btn_menu.x = display.contentCenterX
    btn_menu.y = btn_album.y
    btn_menu.name = "btn_mealMenu"
    
    local require_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_mealmenu"],     
        x = display.contentCenterX,
        y = txt_album.y,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local txt_require = display.newText(require_text_options)
    txt_require.anchorY = 0
    txt_require:setFillColor(0.4, 0.5, 0.6)
    
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
    btn_settings.x = btn_notice.x
    btn_settings.y = btn_menu.y
    btn_settings.name = "btn_settings"
    
    local settings_text_options = 
    {
        parent = group,
        text = language["homeScene"]["mnu_setting"],     
        x = btn_settings.x,
        y = txt_require.y,
--        width = 60,     
        font = native.systemFontBold,   
        fontSize = __buttonFontSize__,
        align = "center"  
    }
    local settings_txt = display.newText(settings_text_options)
    settings_txt.anchorY = 0
    settings_txt:setFillColor(0.4, 0.5, 0.6)
    
    local logo_footer = display.newImageRect(group, "images/logo/logo_footer.png", __backgroundWidth__, 30)
    logo_footer.x = display.contentWidth / 2
    logo_footer.anchorY = 0
    logo_footer.y = display.contentHeight - logo_footer.height
    group:insert(logo_footer)
    
    local footer = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    footer.x = display.contentWidth / 2
    footer.anchorY = 0
    footer.y = display.contentHeight - logo_footer.height - footer.height
    group:insert(footer)
    
    if utils.IS_Demo_mode( storyboard, false) == true then
--      체험하기 로그아웃 버튼
        local tourClose_button = widget.newButton
        {
            width = bg_bottom_box.width ,
            height = 40 ,
            left = 0,--display.contentCenterX - (155/2)  , 
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
    
--  N marker  
    display.remove(new_message_icon)
    display.remove(new_notice_icon)
    display.remove(new_event_icon)
    display.remove(new_menu_icon)
    display.remove(new_mamatalk_icon)
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
    new_menu_icon.x = btn_menu.x - btn_menu.width * 0.5 + 10
    new_menu_icon.y = btn_menu.y
    new_menu_icon.isVisible = false
    __NEW_ICON_SET__.new_menu_icon = new_menu_icon
    group:insert(new_menu_icon)
    
    new_mamatalk_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_mamatalk_icon.anchorY = 0
    new_mamatalk_icon.x = btn_mamatalk.x - btn_mamatalk.width * 0.5 + 10
    new_mamatalk_icon.y = btn_mamatalk.y
    new_mamatalk_icon.isVisible = false
    __NEW_ICON_SET__.new_mamatalk_icon = new_mamatalk_icon
    group:insert(new_mamatalk_icon)
    
    new_alarm_icon = display.newImageRect("images/assets1/icon_menu_new.png",26, 31)
    new_alarm_icon.anchorY = 0
    new_alarm_icon.x = btn_alarm.x - btn_alarm.width * 0.5 + 10
    new_alarm_icon.y = btn_alarm.y
    new_alarm_icon.isVisible = false
    __NEW_ICON_SET__.new_alarm_icon = new_alarm_icon
    group:insert(new_alarm_icon)
    
    func.get_news4Home() --새로운 새소식 갱신
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    storyboard.removeAll()
    
    if utils.IS_Demo_mode( storyboard, false) == true then
        utils.create_iOSPushPopup4Tour(user.userData.jobType)
    else
        --  아이콘의 뱃지 카운트 리셋  
        native.setProperty( "applicationIconBadgeNumber", 0 )
    end
    
    if(activeKidData == nil or #user.kidsList == 0) then
        utils.showMessage( language["homeScene"]["no_active_kids"] )
    else
        func.refresh_Home_New_icon()
    end
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    
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

