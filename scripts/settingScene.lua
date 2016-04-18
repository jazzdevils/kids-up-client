---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
--local json = require("json")
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
--local api = require("scripts.api")
local user = require("scripts.user_data")
--local authority = require("scripts.user_authority")
local sceneData = require("scripts.sceneData")
local lanCode = require("scripts.translatorLanguageCodes")
local userSetting = require("scripts.userSetting")
local func = require("scripts.commonFunc")
local advertising = require("scripts.advertisingControl")
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local navBar
local nameRect

--local activityIndicator
local settingTableView
local advertisingData
local tabBar

local function onRowTouch(event)
    local index = event.target.index
    local adminMenu = event.target.params.adminMenu
    
    if(event.phase == "release") then
        local options = {
            effect = "fromRight",
            time = 300,
        }
        if(index == 1)then  --광고
            if (advertisingData) then
                system.openURL(advertisingData.url)
--                utils.showWebView(advertisingData.url, advertisingData.title)
            end
        elseif(index == 2)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingNewsScene")
            storyboard.gotoScene("scripts.settingNewsScene", options)    
        elseif(index == 3)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingTermsConditionsScene")
            storyboard.gotoScene("scripts.settingTermsConditionsScene", options)    
        elseif(index == 4)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingFaqScene")
            storyboard.gotoScene("scripts.settingFaqScene", options)    
        elseif(index == 5)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingChangeUserInfoScene")
            storyboard.gotoScene("scripts.settingChangeUserInfoScene", options)        
        elseif(index == 6)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingChangePasswordScene")
            storyboard.gotoScene("scripts.settingChangePasswordScene", options)    
        elseif(index == 7)then    
--            utils.showMessage(language["common"]["preparing_service"])
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingAppInfoScene")
            storyboard.gotoScene("scripts.settingAppInfoScene", options)            
        elseif(index == 8)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingPush4ParentScene")
            storyboard.gotoScene("scripts.settingPush4ParentScene", options)
        elseif(index == 9)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingLanguageListScene")
            storyboard.gotoScene("scripts.settingLanguageListScene", options)    
        elseif(index == 10)then
            if __deviceType__ == "android" then
                local serviceName = "share"
                local isAvailable = native.canShowPopup( "social", serviceName )
                
                local function socialListener( event )
                    native.setKeyboardFocus(nil)
                end    
                
                if isAvailable then
                    native.showPopup( "social",
                    {
                        service = serviceName, 
                        message = language["socialShareScene"]["message"],
                        listener = socialListener,
                        image = 
                        {
                            { filename = "share_image.png", baseDir = system.ResourceDirectory },
                        },
                        url = { __WEB_PAGE_SERVER_ADDR__, }
                    })
                else
                    utils.showMessage( string.gsub(language["socialShareScene"]["error_android"], "_SERVICENAME_", serviceName), 3000)
                end
            else
                local options = {
                    effect = "fade",
                    time = 300,
                    params = {

                    },
                    isModal = true,
                }
                storyboard.showOverlay( "scripts.socialShareScene" ,options )
            end
        elseif(index == 11)then    
            native.showAlert(language["appTitle"],language["settingScene"]["logout_question"], 
                { language["settingScene"]["yes"], language["settingScene"]["no"] }, 
                function(event)
                    if "clicked" == event.action then
                        local i = event.index
                        if 1 == i then
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
                end
            ) 
        elseif(index == 12 and adminMenu == true)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.administratorScene")
            storyboard.gotoScene("scripts.administratorScene", options)        
        end
    end
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    local adminMenu = row.params.adminMenu
    
    if index == 1 then  
        row.rect = display.newRect(row.width/2, row.height/2, row.width, row.height - 4)
        row:insert(row.rect )
        
        if advertisingData then
            row.banner = display.newImageRect(advertisingData.image, row.rect.width - 2 , row.rect.height)
        else    
            row.banner = display.newImageRect("images/etc/default1.png", row.rect.width - 2 , row.rect.height)
        end
        row.banner.anchorY = 0
        row.banner.x = display.contentCenterX
        row.banner.y = (row.height - row.banner.height) /2
        row:insert(row.banner)
    elseif index == 2 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.news_icon = display.newImageRect("images/assets1/icon_setting_news.png", 24 , 24)
        row.news_icon.anchorX = 0
        row.news_icon.anchorY = 0
        row.news_icon.x = 10
        row.news_icon.y = (row.height - row.news_icon.height) /2
        row:insert(row.news_icon)
        
        row.news_txt = display.newText(language["settingScene"]["news"],0, 0, native.systemFontBold, 12)
        row.news_txt.anchorX = 0
        row.news_txt.anchorY = 0
        row.news_txt:setFillColor(0, 0, 0)
        row.news_txt.x = row.news_icon.x + row.news_icon.width + 10
        row.news_txt.y = (row.height - row.news_txt.height) /2
        row:insert(row.news_txt)
    elseif index == 3 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.rule_icon = display.newImageRect("images/assets1/icon_setting_rule.png", 24 , 24)
        row.rule_icon.anchorX = 0
        row.rule_icon.anchorY = 0
        row.rule_icon.x = 10
        row.rule_icon.y = (row.height - row.rule_icon.height) /2
        row:insert(row.rule_icon)
        
        row.rule_txt = display.newText(language["settingScene"]["policy"],0, 0, native.systemFontBold, 12)
        row.rule_txt.anchorX = 0
        row.rule_txt.anchorY = 0
        row.rule_txt:setFillColor(0, 0, 0)
        row.rule_txt.x = row.rule_icon.x + row.rule_icon.width + 10
        row.rule_txt.y = (row.height - row.rule_txt.height) /2
        row:insert(row.rule_txt)
    elseif index == 4 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.account_icon = display.newImageRect("images/assets1/icon_setting_help.png", 24 , 24)
        row.account_icon.anchorX = 0
        row.account_icon.anchorY = 0
        row.account_icon.x = 10
        row.account_icon.y = (row.height - row.account_icon.height) /2
        row:insert(row.account_icon)
        
        row.account_txt = display.newText(language["settingScene"]["faq"],0, 0, native.systemFontBold, 12)
        row.account_txt.anchorX = 0
        row.account_txt.anchorY = 0
        row.account_txt:setFillColor(0, 0, 0)
        row.account_txt.x = row.account_icon.x + row.account_icon.width + 10
        row.account_txt.y = (row.height - row.account_txt.height) /2
        row:insert(row.account_txt)
    elseif index == 5 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.userinfo_icon = display.newImageRect("images/assets1/icon_setting_account.png", 24 , 24)
        row.userinfo_icon.anchorX = 0
        row.userinfo_icon.anchorY = 0
        row.userinfo_icon.x = 10
        row.userinfo_icon.y = (row.height - row.userinfo_icon.height) /2
        row:insert(row.userinfo_icon)
        
        row.userinfo_txt = display.newText(language["settingScene"]["account_set"],0, 0, native.systemFontBold, 12)
        row.userinfo_txt.anchorX = 0
        row.userinfo_txt.anchorY = 0
        row.userinfo_txt:setFillColor(0, 0, 0)
        row.userinfo_txt.x = row.userinfo_icon.x + row.userinfo_icon.width + 10
        row.userinfo_txt.y = (row.height - row.userinfo_txt.height) /2
        row:insert(row.userinfo_txt)        
    elseif index == 6 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.pwd_icon = display.newImageRect("images/assets1/icon_setting_password.png", 24 , 24)
        row.pwd_icon.anchorX = 0
        row.pwd_icon.anchorY = 0
        row.pwd_icon.x = 10
        row.pwd_icon.y = (row.height - row.pwd_icon.height) /2
        row:insert(row.pwd_icon)
        
        row.password_txt = display.newText(language["settingScene"]["password_set"],0, 0, native.systemFontBold, 12)
        row.password_txt.anchorX = 0
        row.password_txt.anchorY = 0
        row.password_txt:setFillColor(0, 0, 0)
        row.password_txt.x = row.pwd_icon.x + row.pwd_icon.width + 10
        row.password_txt.y = (row.height - row.password_txt.height) /2
        row:insert(row.password_txt)    
    elseif index == 7 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.info_icon = display.newImageRect("images/assets1/icon_setting_info.png", 24 , 24)
        row.info_icon.anchorX = 0
        row.info_icon.anchorY = 0
        row.info_icon.x = 10
        row.info_icon.y = (row.height - row.info_icon.height) /2
        row:insert(row.info_icon)
        
        row.appInfo_txt = display.newText(language["settingScene"]["app_info"],0, 0, native.systemFontBold, 12)
        row.appInfo_txt.anchorX = 0
        row.appInfo_txt.anchorY = 0
        row.appInfo_txt:setFillColor(0, 0, 0)
        row.appInfo_txt.x = row.info_icon.x + row.info_icon.width + 10
        row.appInfo_txt.y = (row.height - row.appInfo_txt.height) /2
        row:insert(row.appInfo_txt)
    elseif index == 8 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.push_icon = display.newImageRect("images/assets1/icon_setting_push.png", 24 , 24)
        row.push_icon.anchorX = 0
        row.push_icon.anchorY = 0
        row.push_icon.x = 10
        row.push_icon.y = (row.height - row.push_icon.height) /2
        row:insert(row.push_icon)
        
        row.pushSet_txt = display.newText(language["settingScene"]["push_set"],0, 0, native.systemFontBold, 12)
        row.pushSet_txt.anchorX = 0
        row.pushSet_txt.anchorY = 0
        row.pushSet_txt:setFillColor(0, 0, 0)
        row.pushSet_txt.x = row.push_icon.x + row.push_icon.width + 10
        row.pushSet_txt.y = (row.height - row.pushSet_txt.height) /2
        row:insert(row.pushSet_txt)
    elseif index == 9 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.trans_icon = display.newImageRect("images/assets1/icon_setting_language.png", 24 , 24)
        row.trans_icon.anchorX = 0
        row.trans_icon.anchorY = 0
        row.trans_icon.x = 10
        row.trans_icon.y = (row.height - row.trans_icon.height) /2
        row:insert(row.trans_icon)
        
        row.trans_txt = display.newText(language["settingScene"]["translation_set"],0, 0, native.systemFontBold, 12)
        row.trans_txt.anchorX = 0
        row.trans_txt.anchorY = 0
        row.trans_txt:setFillColor(0, 0, 0)
        row.trans_txt.x = row.trans_icon.x + row.trans_icon.width + 10
        row.trans_txt.y = (row.height - row.trans_txt.height) /2
        row:insert(row.trans_txt)
        
        local transLang = lanCode:getLanguageCode(lanCode:getIndexOfLanguageCode(userSetting.settings.toTranslatorLanguageCode))
        row.transStatus_txt = display.newText(transLang.name,0, 0, native.systemFontBold, 12)
        row.transStatus_txt.anchorX = 0
        row.transStatus_txt.anchorY = 0
        row.transStatus_txt:setFillColor(0, 0, 0)
        row.transStatus_txt.x = row.width - row.transStatus_txt.width - 30
        row.transStatus_txt.y = (row.height - row.transStatus_txt.height) /2
        row:insert(row.transStatus_txt)
    elseif index == 10 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.share_icon = display.newImageRect("images/assets1/icon_setting_share.png", 24 , 24)
        row.share_icon.anchorX = 0
        row.share_icon.anchorY = 0
        row.share_icon.x = 10
        row.share_icon.y = (row.height - row.share_icon.height) /2
        row:insert(row.share_icon)
        
        row.share_txt = display.newText(language["socialShareScene"]["start_button"],0, 0, native.systemFontBold, 12)
        row.share_txt.anchorX = 0
        row.share_txt.anchorY = 0
        row.share_txt:setFillColor(0, 0, 0)
        row.share_txt.x = row.share_icon.x + row.share_icon.width + 10
        row.share_txt.y = (row.height - row.share_txt.height) /2
        row:insert(row.share_txt)
    elseif index == 11 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.logout_icon = display.newImageRect("images/assets1/icon_setting_logout.png", 24 , 24)
        row.logout_icon.anchorX = 0
        row.logout_icon.anchorY = 0
        row.logout_icon.x = 10
        row.logout_icon.y = (row.height - row.logout_icon.height) /2
        row:insert(row.logout_icon)
        
        row.logout_txt = display.newText(language["settingScene"]["logout"],0, 0, native.systemFontBold, 12)
        row.logout_txt.anchorX = 0
        row.logout_txt.anchorY = 0
        row.logout_txt:setFillColor(0, 0, 0)
        row.logout_txt.x = row.logout_icon.x + row.logout_icon.width + 10
        row.logout_txt.y = (row.height - row.logout_txt.height) /2
        row:insert(row.logout_txt)
    elseif index == 12 and adminMenu == true then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.admin_icon = display.newImageRect("images/assets1/icon_private.png", 24 , 24)
        row.admin_icon.anchorX = 0
        row.admin_icon.anchorY = 0
        row.admin_icon.x = 10
        row.admin_icon.y = (row.height - row.admin_icon.height) /2
        row:insert(row.admin_icon)
        
        row.admin_txt = display.newText("Administrator mode", 0, 0, native.systemFontBold, 12)
        row.admin_txt.anchorX = 0
        row.admin_txt.anchorY = 0
        row.admin_txt:setFillColor(0, 0, 0)
        row.admin_txt.x = row.admin_icon.x + row.admin_icon.width + 10
        row.admin_txt.y = (row.height - row.admin_txt.height) /2
        row:insert(row.admin_txt)    
    end
    
    if index == 1 then
        
    elseif index == 9 then
        
    else    
        row.arrow_icon = display.newImageRect("images/assets1/icon_setting_arrow.png", 24 , 24)
        row.arrow_icon.anchorX = 0
        row.arrow_icon.anchorY = 0
        row.arrow_icon.x = row.width - row.arrow_icon.width - 6
        row.arrow_icon.y = (row.height - row.arrow_icon.height) /2
        row:insert(row.arrow_icon)
    end
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "slideRight", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
--    advertisingData = advertising.getBannerByRandom()
    advertisingData = advertising.getBanner()
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["settingScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }

    nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    local tag_Opt = {
        parent = group,
        text = user.getNameTagByAuthority(),
        x = display.contentCenterX,
        width = __appContentWidth__,
        y = __statusBarHeight__ + 68,
        font = native.systemFontBold,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    
    local tabButton_width = __appContentWidth__/5 - 2--math.floor(display.actualContentWidth/5) - 2
    local tabButton_height = tabButton_width * 0.7--math.floor(tabButton_width * 0.7)
    
    local function canGotoSceneByAuthority()
        local rtn = true
        if user.userData.jobType == __PARENT__ then
            local activeKidData = user.getActiveKidData()
            if(activeKidData) then
                if(activeKidData.approval_state ~= "1") then
                    utils.showMessage( language["homeScene"]["not_approved_yet"] )
                    rtn = false
                end
            else    
                utils.showMessage( language["homeScene"]["no_active_kids"] )
                rtn = false
            end
        else
            if user.userData.approvalState ~= '1' then
                rtn = false
                if user.userData.jobType == __DIRECTOR__ then
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_director"])
                else
                    utils.showMessage(language["mngHomeScene"]["notapproval_msg_teacher"])
                end
            end    
        end
        
        return rtn
    end
    
    local tabButtonImages = func.getTabButtonImage()
    local tabButtons = {
        {
            label = language["tab_button"]["tab_button_1"],
            defaultFile = "images/bottom/btn_bottom_home_normal.png",
            overFile = "images/bottom/btn_bottom_home_selected.png",
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
--            size = 16,
            width = tabButton_width,
            height = tabButton_height,
            onPress = function() storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "crossFade", 300) end,
        },
        {
            label = language["tab_button"]["tab_button_2"],
            defaultFile = tabButtonImages.message.defaultFile,
            overFile = tabButtonImages.message.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            if canGotoSceneByAuthority() == true then
                                storyboard.isAction = true
                                storyboard.purgeScene("scripts.messageScene")
                                storyboard.gotoScene("scripts.messageScene", "crossFade", 300) 
                            end
                        end,
        },
        {
            label = language["tab_button"]["tab_button_3"],
            defaultFile = tabButtonImages.notice.defaultFile,
            overFile = tabButtonImages.notice.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            if canGotoSceneByAuthority() == true then
                                storyboard.isAction = true
                                storyboard.purgeScene("scripts.noticeScene")
                                storyboard.gotoScene("scripts.noticeScene", "crossFade", 300) 
                            end
                        end,
        },
        {
            label = language["tab_button"]["tab_button_4"],
            defaultFile = tabButtonImages.event.defaultFile,
            overFile = tabButtonImages.event.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            if canGotoSceneByAuthority() == true then
                                storyboard.isAction = true
                                storyboard.purgeScene("scripts.eventScene")
                                storyboard.gotoScene("scripts.eventScene", "crossFade", 300) 
                            end
                        end,
        },
        {
            label = language["tab_button"]["tab_button_5"],
            defaultFile = "images/bottom/btn_bottom_schedule_normal.png",
            overFile = "images/bottom/btn_bottom_schedule_selected.png",
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            if canGotoSceneByAuthority() == true then
                                storyboard.isAction = true
                                storyboard.purgeScene("scripts.calendarScene")
                                storyboard.gotoScene("scripts.calendarScene", "crossFade", 300) 
                            end
                        end,
        },
    }
    
    local tabBarBackgroundFile = "images/bottom/tabBarBg7.png"
    local tabBarLeft = "images/bottom/tabBar_tabSelectedLeft7.png"
    local tabBarMiddle = "images/bottom/tabBar_tabSelectedMiddle7.png"
    local tabBarRight = "images/bottom/tabBar_tabSelectedRight7.png"
    
    tabBar = widget.newTabBar{
        top =  display.contentHeight - tabButton_height,
        left = 0,
        width = __appContentWidth__,
        backgroundFile = tabBarBackgroundFile,
        tabSelectedLeftFile = tabBarLeft, 
        tabSelectedRightFile = tabBarRight,
        tabSelectedMiddleFile = tabBarMiddle,
        tabSelectedFrameWidth = 0,           
        tabSelectedFrameHeight = 0,--tabButton_height, 
        buttons = tabButtons,
        height = tabButton_height,
    }
    tabBar.x = display.contentWidth / 2
    group:insert(tabBar)
    tabBar:setSelected(0, false)
    
    navBar = widget.newNavigationBar({
            title = language["settingScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
        })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
--    native.setActivityIndicator( true )
    settingTableView = widget.newTableView{
        top = navBar.height + nameRect.height + 1,
--        top = navBar.height + 2,
        height = __appContentHeight__ - navBar.height- tabBar.height - nameRect.height - 3,
--        height = __appContentHeight__ - navBar.height- tabBar.height - 3,
        width = display.contentWidth,
        maxVelocity = 1, 
        rowTouchDelay = 60,
--        isLocked = true,
        hideBackground = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
--        noLine = true,
        listener = nil,
    }
    settingTableView.x = display.contentWidth / 2
    group:insert(settingTableView)   
        
    for i = 1, 11 do
        if i == 1 then
            settingTableView:insertRow{
                rowHeight = 60,
                rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                lineColor = { 0.5, 0.5, 0.5, 0 },
                params = {
                    adminMenu = false,
                }
            }
        else
            settingTableView:insertRow{
                rowHeight = 40,
                rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                lineColor = { 0.5, 0.5, 0.5, 0 },
                params = {
                    adminMenu = false,
                }
            }
        end
            
    end    
        
    if user.userData.isAdmin == true then
        settingTableView:insertRow{
            rowHeight = 40,
            rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
            lineColor = { 0.5, 0.5, 0.5, 0 },
            params = {
                adminMenu = true,
            }
        }
    end
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = __DEFAULT_HOMESCENE_NAME__
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





