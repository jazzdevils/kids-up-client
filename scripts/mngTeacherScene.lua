---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local user = require("scripts.user_data")
local authority = require("scripts.user_authority")
local sceneData = require("scripts.sceneData")
local lanCode = require("scripts.translatorLanguageCodes")
local userSetting = require("scripts.userSetting")
local func = require("scripts.commonFunc")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local navBar
local nameRect

local activityIndicator
local mngTableView

local function onRowTouch(event)
    local index = event.target.index
    local obj = event.target
    
    if(event.phase == "release") then
        local options = {
            effect = "fromRight",
            time = 300,
        }
        if(index == 1)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.mngInviteScene")
            storyboard.gotoScene("scripts.mngInviteScene", options)
        elseif(index == 2)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.mngRollBookScene")
            storyboard.gotoScene("scripts.mngRollBookScene", options)
        elseif(index == 3)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.askApprovalScene")
            storyboard.gotoScene("scripts.askApprovalScene", options)
        elseif(index == 4)then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.mngClassKidsScene")
            storyboard.gotoScene("scripts.mngClassKidsScene", options)
--        elseif(index == 5)then
--            storyboard.isAction = true
--            storyboard.purgeScene("scripts.mngMsgGetTimeScene")
--            storyboard.gotoScene("scripts.mngMsgGetTimeScene", options)
        end
    end
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    if index == 1 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.invite_icon = display.newImageRect("images/assets1/icon_setting_call.png", 24 , 24)
        row.invite_icon.anchorX = 0
        row.invite_icon.anchorY = 0
        row.invite_icon.x = 10
        row.invite_icon.y = (row.height - row.invite_icon.height) /2
        row:insert(row.invite_icon)
        
        row.invite_txt = display.newText(language["mngTeacherScene"]["invite"],0, 0, native.systemFontBold, 12)
        row.invite_txt.anchorX = 0
        row.invite_txt.anchorY = 0
        row.invite_txt:setFillColor(0, 0, 0)
        row.invite_txt.x = row.invite_icon.x + row.invite_icon.width + 10
        row.invite_txt.y = (row.height - row.invite_txt.height) /2
        row:insert(row.invite_txt)  
    elseif index == 2 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.rollbook_icon = display.newImageRect("images/assets1/icon_setting_cnf_attend.png", 24 , 24)
        row.rollbook_icon.anchorX = 0
        row.rollbook_icon.anchorY = 0
        row.rollbook_icon.x = 10
        row.rollbook_icon.y = (row.height - row.rollbook_icon.height) /2
        row:insert(row.rollbook_icon)
        
        row.rollbook_txt = display.newText(language["mngTeacherScene"]["roll_book"],0, 0, native.systemFontBold, 12)
        row.rollbook_txt.anchorX = 0
        row.rollbook_txt.anchorY = 0
        row.rollbook_txt:setFillColor(0, 0, 0)
        row.rollbook_txt.x = row.rollbook_icon.x + row.rollbook_icon.width + 10
        row.rollbook_txt.y = (row.height - row.rollbook_txt.height) /2
        row:insert(row.rollbook_txt)
    elseif index == 3 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.unapproval_icon = display.newImageRect("images/assets1/icon_setting_cnf_children.png", 24 , 24)
        row.unapproval_icon.anchorX = 0
        row.unapproval_icon.anchorY = 0
        row.unapproval_icon.x = 10
        row.unapproval_icon.y = (row.height - row.unapproval_icon.height) /2
        row:insert(row.unapproval_icon)
        
        row.unapproval_txt = display.newText(language["mngTeacherScene"]["notapplist"],0, 0, native.systemFontBold, 12)
        row.unapproval_txt.anchorX = 0
        row.unapproval_txt.anchorY = 0
        row.unapproval_txt:setFillColor(0, 0, 0)
        row.unapproval_txt.x = row.unapproval_icon.x + row.unapproval_icon.width + 10
        row.unapproval_txt.y = (row.height - row.unapproval_txt.height) /2
        row:insert(row.unapproval_txt)
    elseif index == 4 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row:insert(row.rect )
        
        row.managekids_icon = display.newImageRect("images/assets1/icon_setting_list_children.png", 24 , 24)
        row.managekids_icon.anchorX = 0
        row.managekids_icon.anchorY = 0
        row.managekids_icon.x = 10
        row.managekids_icon.y = (row.height - row.managekids_icon.height) /2
        row:insert(row.managekids_icon)
        
        row.managekids_txt = display.newText(language["mngTeacherScene"]["managekids"],0, 0, native.systemFontBold, 12)
        row.managekids_txt.anchorX = 0
        row.managekids_txt.anchorY = 0
        row.managekids_txt:setFillColor(0, 0, 0)
        row.managekids_txt.x = row.managekids_icon.x + row.managekids_icon.width + 10
        row.managekids_txt.y = (row.height - row.managekids_txt.height) /2
        row:insert(row.managekids_txt)
--    elseif index == 5 then
--        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
--        row:insert(row.rect )
--        
--        row.message_time_icon = display.newImageRect("images/assets1/icon_setting_list_children.png", 24 , 24)
--        row.message_time_icon.anchorX = 0
--        row.message_time_icon.anchorY = 0
--        row.message_time_icon.x = 10
--        row.message_time_icon.y = (row.height - row.message_time_icon.height) /2
--        row:insert(row.message_time_icon)
--        
--        row.message_time_txt = display.newText(language["mngTeacherScene"]["msg_confirm_time"],0, 0, native.systemFontBold, 12)
--        row.message_time_txt.anchorX = 0
--        row.message_time_txt.anchorY = 0
--        row.message_time_txt:setFillColor(0, 0, 0)
--        row.message_time_txt.x = row.message_time_icon.x + row.message_time_icon.width + 10
--        row.message_time_txt.y = (row.height - row.message_time_txt.height) /2
--        row:insert(row.message_time_txt)
    end    
    
    
    row.arrow_icon = display.newImageRect("images/assets1/icon_setting_arrow.png", 24 , 24)
    row.arrow_icon.anchorX = 0
    row.arrow_icon.anchorY = 0
    row.arrow_icon.x = row.width - row.arrow_icon.width - 6
    row.arrow_icon.y = (row.height - row.arrow_icon.height) /2
    row:insert(row.arrow_icon)
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
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    func.clear_news(user.userData.id, "manage")    
    
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
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.messageScene")
                            storyboard.gotoScene("scripts.messageScene", "crossFade", 300) 
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
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.noticeScene")
                            storyboard.gotoScene("scripts.noticeScene", "crossFade", 300) 
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
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.eventScene")
                            storyboard.gotoScene("scripts.eventScene", "crossFade", 300) 
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
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.calendarScene")
                            storyboard.gotoScene("scripts.calendarScene", "crossFade", 300) 
                        end,
        },
    }
    
    local tabBarBackgroundFile = "images/bottom/tabBarBg7.png"
    local tabBarLeft = "images/bottom/tabBar_tabSelectedLeft7.png"
    local tabBarMiddle = "images/bottom/tabBar_tabSelectedMiddle7.png"
    local tabBarRight = "images/bottom/tabBar_tabSelectedRight7.png"
    
    local tabBar = widget.newTabBar{
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
            title = language["mngTeacherScene"]["title"],
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
    mngTableView = widget.newTableView{
        top = navBar.height + nameRect.height + 10,
        height = __appContentHeight__ - navBar.height- tabBar.height - nameRect.height - __statusBarHeight__,
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
    mngTableView.x = display.contentWidth / 2
    group:insert(mngTableView)   
        
    for i = 1, 4 do
        mngTableView:insertRow{
            rowHeight = 40,
            rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
            lineColor = { 0.5, 0.5, 0.5, 0 },
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







