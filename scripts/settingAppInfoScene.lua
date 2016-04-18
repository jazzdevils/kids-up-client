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
local api = require("scripts.api")
local json = require("json")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local navBar
local nameRect
local activityIndicator
local settingTableView

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    if index == 1 then
        row.logo = display.newImageRect("images/logo/logo_full.png", 200, 130)
        row.logo.anchorY = 0
        row.logo.x = display.contentCenterX
        row.logo.y = 20
        row:insert(row.logo)
            
        local current_version = utils.getAppLocalVersion(__deviceType__)
        local current_info = language["settingAppInfoScene"]["current_ver"]..current_version
        row.current_vertxt = display.newText(current_info,0, 0, native.systemFontBold, 12)
        row.current_vertxt.anchorY = 0
        row.current_vertxt:setFillColor(0, 0, 0)
        row.current_vertxt.x = display.contentCenterX
        row.current_vertxt.y = row.logo.y + row.logo.height + 10
        row:insert(row.current_vertxt)
        
--        if(__SERVER_APP_INFO__.status == "OK") then
--            row.ver_rect = display.newRoundedRect(0, 0, 200, 50, 6)
--            row.ver_rect.anchorY = 0
--            row.ver_rect.strokeWidth = 1
--            row.ver_rect:setStrokeColor( 0.7, 0.7, 0.7 )
--            row.ver_rect:setFillColor( 0.9)
--            row.ver_rect.x = display.contentCenterX
--            row.ver_rect.y = row.current_vertxt.y + row.current_vertxt.height + 10
--            row:insert(row.ver_rect)
--
--            row.desc = display.newText(language["settingAppInfoScene"]["latest_ver"], 0, 0, native.systemFontBold, 13)
--            row.desc.anchorY = 0
--            row.desc:setFillColor(0.4, 0.5, 0.6)
--            row.desc.x = display.contentCenterX
--            row.desc.y = row.ver_rect.y + (row.ver_rect.height - row.desc.height)/2
--            row:insert(row.desc)
            
--            local desc_options = {
--                text = language["settingAppInfoScene"]["new_ver"],
--                width = 220,
--                x = display.contentCenterX,
--                font = native.systemFontBold,   
--                fontSize = __textLabelFontSize__,
--                align = "center"  --new alignment parameter
--            }
--            row.update_txt = display.newText(desc_options)
--            row.update_txt.anchorY = 0
--            row.update_txt:setFillColor(0, 0, 0)
--            row.update_txt.x = display.contentCenterX
--            row.update_txt.y = row.update_button.y + (row.update_button.height - row.update_txt.height) * 0.5
--            row:insert(row.update_txt)
--        end
        
        local options = {
            text = language["settingAppInfoScene"]["copy_right"],
            x = display.contentCenterX,
            font = native.systemFontBold,   
            fontSize = __textLabelFontSize__,
            align = "center"  --new alignment parameter
        }
        row.request_desc = display.newText(options)
        row.request_desc.anchorY = 0
        row.request_desc.y = row.current_vertxt.y + 90
        row.request_desc:setFillColor(0)
        row:insert(row.request_desc)
    end
end    

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene("scripts.settingScene")
        storyboard.gotoScene("scripts.settingScene", "slideRight", 300)
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
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["settingScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
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
    
    navBar = widget.newNavigationBar({
            title = language["settingAppInfoScene"]["title"],
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
        top = navBar.height + nameRect.height,
        height = __appContentHeight__ - navBar.height - nameRect.height, -- - __statusBarHeight__,
        width = __appContentWidth__,-- display.contentWidth,
        maxVelocity = 1, 
        rowTouchDelay = 60,
--        isLocked = true,
        hideBackground = false,
        onRowRender = onRowRender,
--        onRowTouch = onRowTouch,
--        noLine = true,
--        listener = nil,
    }
    settingTableView.x = display.contentWidth / 2
    group:insert(settingTableView)   
        
    settingTableView:insertRow{
        rowHeight = 250,
        rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0}},
        lineColor = { 0.5, 0.5, 0.5, 0 },
    }
    
    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height
    
--    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
--    api.get_app_info(
--        function(event) 
--            activityIndicator:destroy()
--            
--            if (not event.isError) then
--                if(event.status == 200) then
--                    local data = json.decode(event.response)
--                    if(data.status == "OK") then
--                        __SERVER_APP_INFO__.status = data.status
--                        
--                        for i = 1, data.platform_cnt do
--                            if(data.platform[i].os == "android") then
--                                __SERVER_APP_INFO__.android.version = data.platform[i].version
--                                __SERVER_APP_INFO__.android.app_url = data.platform[i].url
--                                __SERVER_APP_INFO__.android.androidAppPackageName = data.platform[i].package
--                            elseif(data.platform[i].os == "ios") then
--                                __SERVER_APP_INFO__.ios.version = data.platform[i].version
--                                __SERVER_APP_INFO__.ios.app_url = data.platform[i].url
--                                __SERVER_APP_INFO__.ios.iOSAppId = data.platform[i].package
--                            end
--                        end
--                        
--                        settingTableView:insertRow{
--                            rowHeight = 250,
--                            rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0}},
--                            lineColor = { 0.5, 0.5, 0.5, 0 },
--                        }
--                    end
--                else
--                    utils.showMessage(language["common"]["wrong_connection"])
--                end
--            else
--                utils.showMessage(language["common"]["wrong_connection"])
--            end
--        end    
--    )
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.settingScene"
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





