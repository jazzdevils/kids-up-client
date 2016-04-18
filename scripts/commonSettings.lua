--====================================--
-- Youn don't need to modify
-- Config.__statusBarHeight__ set value
require ("config")

__IS_APP_RELEASE_MODE__ = true  -- 릴리즈모드(true), 테스트모드(false)

__LOCAL_APP_VERSION_ANDROID__ = "1.2.4"--system.getInfo( "appVersionString" ) -- Example "1.1.3"
__LOCAL_APP_VERSION_IOS__ = "1.2.4"

__SERVER_APP_INFO__ = {
    status = "",
    android = {
        version = "", 
        app_url = "",
        androidAppPackageName = "", --net.kidsup.mobile.android
        supportedAndroidStores = {"google", "samsung", "amazon", "nook" },
    },
    ios = {
        version = "", --test code
        app_url = "",
        iOSAppId = "", 
    },
}

__FLURRY_ANALYTICS_APPLICATION_KEY__ = "VZ23MJ84DRNHCN57DKK9"   --KidsUp
__SUPPORT_EMAIL__ = "support@kidsup.net"


if statusBarType == "hidden" then
    display.setStatusBar( display.HiddenStatusBar )
elseif statusBarType == "default" then 
    display.setStatusBar( display.DefaultStatusBar )
elseif statusBarType == "translucent" then 
    display.setStatusBar( display.TranslucentStatusBar )
elseif statusBarType == "dark" then 
    display.setStatusBar( display.DarkStatusBar ) 
end

 __statusBarHeight__ = display.topStatusBarContentHeight --display.statusBarHeight
-- - if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) then 
--    __statusBarHeight__ = __statusBarHeight__ * 0.5 
--end

--device type
__deviceType__ = ""
if ( system.getInfo("model") == "iPad"   or
     system.getInfo("model") == "iPhone" or
     system.getInfo("model") == "iPod" ) then
    __deviceType__ = "iphone"
else
--    if ( system.getInfo("model") ~= "Kindle Fire" or system.getInfo("model") ~= "Nook" ) then
--      store.init( "google", transactionCallback )
--      store.restore()
--    end
    __deviceType__ = "android"
end

__appContentWidth__ = display.contentWidth
__appContentHeight__ = display.contentHeight
 
__textFieldHeight__ = "30"
__textFieldFontSize__ = "14"
__textFieldFontSize16__ = "16"
__textTitleBarFontSize__ = "28"
__buttonFontSize__ = "13"
__textLabelFontSize__ = "13"
__textSubMenuFontSize__ = "16"
__navBarTitleFontSize__ = "20"
__textLabelFont14Size__ = "14"
__textLabelFont12Size__ = "12"
__text_padding__ = 20
__invitationCodeFontSize__ = 16

__LIST_SCENE_TEXT_SIZE__ = 13
__VIEW_SCENE_TEXT_SIZE__ = 13
__DEFAULT_FONT_SIZE__ = 13
__COMMENT_FONT_SIZE__ = 12
__INPUT_TEXT_FONT_SIZE__ = 13
__INPUT_TEXT_FONT_SIZE_SMALL__ = 11

if(__deviceType__ == "android") then
    __textFieldHeight__ = __textFieldHeight__ + 10
    __textFieldFontSize16__ = __textFieldFontSize16__ - 4
    __textTitleBarFontSize__ = __textTitleBarFontSize__ -4
    __buttonFontSize__ = __buttonFontSize__ - 1
    __textLabelFontSize__ = __textLabelFontSize__ - 1
    __textSubMenuFontSize__ = __textSubMenuFontSize__  - 1
    __navBarTitleFontSize__ = __navBarTitleFontSize__ - 4
    __textLabelFont14Size__ = __textLabelFont14Size__ - 1
    __textLabelFont12Size__ = __textLabelFont12Size__ - 1
    __text_padding__ = __text_padding__ - 4
    __LIST_SCENE_TEXT_SIZE__ = __LIST_SCENE_TEXT_SIZE__ - 2
    __DEFAULT_FONT_SIZE__ = __DEFAULT_FONT_SIZE__ - 1
    __COMMENT_FONT_SIZE__ = __COMMENT_FONT_SIZE__ - 2
    __INPUT_TEXT_FONT_SIZE__ = __INPUT_TEXT_FONT_SIZE__ - 1
    __INPUT_TEXT_FONT_SIZE_SMALL__ = __INPUT_TEXT_FONT_SIZE_SMALL__ - 1
    __invitationCodeFontSize__ = __invitationCodeFontSize__ - 1
end

__tableRowTouchDelay__ = 10

if __IS_APP_RELEASE_MODE__ == true then
    __SERVER_ADDR__ = "https://www.kidsup.net"
else
    __SERVER_ADDR__ = "http://52.68.76.51"
end

__WEB_PAGE_SERVER_ADDR__ = "https://www.kidsup.net"
__SERVER_WEB_ADDR__ = "http://web.kidsup.net/"

__WEBAPI_PORT__ = 5057

__APP_PROPERTY_FILE__ = "properties.json"

__NAVBAR_TXT_COLOR__ = { 187/255, 102/255, 0 }
__NAVBAR_BUTTON_COLOR__ = { 1, 1, 1 }

__POPUP_TITLE_BG_COLOR__ = { 238/255, 85/255, 51/255 }
__POPUP_TITLE_TXT_COLOR__ = { 1, 1, 1 }
__POPUP_TABLE_ROW_TXT_COLOR__ = { 125/255, 68/255, 0 }
__POPUP_TABLE_ROW_DATA1_BG_COLOR__ = { 1, 168/255, 15/255 }
__POPUP_TABLE_ROW_DATA2_BG_COLOR__ = { 1, 204/255, 0 }

__backgroundWidth__ = 360
__backgroundHeight__ = 570

__activeKidListColor__ = {1, 0.9, 0.67}
__UnRead_NoticeList_RowColor__ = {1, 0.9, 0.67}
__UnRead_NoticeList_FontColor__ = { 187/255, 102/255, 0 }
__Read_NoticeList_FontColor__ = {119/255, 136/255, 153/255}
__URL_LINK_COLOR__ = {0.93, 0.25, 0.21}

__EDITFIELD_FILL_COLOR__ = { 118/255, 135/255, 151/255 }
__PROGRESS_BAR_COLOR = { 239/255, 34/255, 17/255 }

__SELECT_CLASS_RECT_COLOR__ = { 255/255, 229/255, 170/255 }

__DEFAULT_HOMESCENE_NAME__ = ""

__TMP_FILE_EVENT_WRITE__ = "eventWriteTemp.json"
__TMP_FILE_NOTICE_WRITE__ = "noticeWriteTemp.json"
__TMP_FILE_CALENDAR_WRITE__ = "calendarWriteTemp.json"
__TMP_FILE_MAMATALK_WRITE__ = "mamatalkWriteTemp.json"
__TMP_FILE_MSG_PARENT_WRITE__ = "msgWriteParentTemp.json"
__TMP_FILE_MSG_TEACHER_WRITE__ = "msgWriteTeacherTemp.json"

__STRING_DELIMITER__ = "|" --캐리지 리턴으로 바꾸기위한 매직 코드

__DELETABLE_SCEDULE__ = "1" --삭제가능한 스케줄

__USER_SETTING_FILE_PARENT__ = "user_setting_p.json" --사용자 설정파일(학부모용)
__USER_SETTING_FILE_TEACHER__ = "user_setting_t.json" --사용자 설정파일(원장, 선생용)

__MESSAGE_FROM_HOME__ = "1" --가정에서 보내는 메세지(알림장)
__MESSAGE_FROM_CENTER__ = "2" --원에서 보내는 메세지(알림장)

__TITLE_LIMIT_LENGTH__ = 30
__CONTENTS_LIMIT_LENGTH__ = 50

__INVITATION_CODE__ = "" --원장이 발행한 초대코드

--새로운 소식 갯수저장
__NEW_MESSAGE_COUNT__   = 0
__NEW_NOTICE_COUNT__    = 0
__NEW_EVENT_COUNT__     = 0
__NEW_MENU_COUNT__      = 0
__NEW_MANAGE_COUNT__    = 0
__NEW_MAMATALK_COUNT__  = 0
__NEW_NEWS_COUNT__      = 0

__NEW_ICON_SET__ = { --N 마크 전역 사용
    new_message_icon = nil,
    new_notice_icon = nil,
    new_event_icon = nil,
    new_menu_icon = nil,
    new_mamatalk_icon = nil,
    new_alarm_icon = nil,
    new_manage_icon = nil,
}

__MEAL_MENU_CONTENT_LIMIT_LENGTH__ = 100

__DEMO_MODE_DEVICE_ID__ = "1" --체험모드의 device id


