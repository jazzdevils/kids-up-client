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
local autoLogin = require("scripts.autoLoginCheck")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local navBar
local nameRect

local settingTableView

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    if index == 1 then
        local options = {
            text = language["loginErrorScene"]["desc"],
            x = display.contentCenterX,
            width = 280,
            font = native.systemFontBold,   
            fontSize = __textFieldFontSize16__,
            align = "center"  --new alignment parameter
        }
        row.request_desc = display.newText(options)
        row.request_desc.anchorY = 0
        row.request_desc.y = 30
        row.request_desc:setFillColor(0)
        row:insert(row.request_desc)
        
        row.reLogin_button = widget.newButton
        {
            width = 240 ,
            height = 50 ,
            left = 0,
            top = 0, 
            defaultFile = "images/button/btn_red_1_normal.png",
            overFile = "images/button/btn_red_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
--            emboss = true,
            labelYOffset = -2,
            fontSize = __textLabelFont14Size__,
            label = language["loginErrorScene"]["login_button"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                autoLogin:check()
                            end
                        end
        }
        row.reLogin_button.x = display.contentCenterX
        row.reLogin_button.anchorY = 0
        row.reLogin_button.y = row.request_desc.y + row.request_desc.height + 10
        row:insert(row.reLogin_button)
    end
end    

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    navBar = widget.newNavigationBar({
            title = language["loginErrorScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
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
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.loginScene"
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







