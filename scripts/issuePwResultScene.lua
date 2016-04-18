require("widgets.widgetext")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local navBar
local confirm_button

local function confirmButtonEvent(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        storyboard.removeScene("scripts.loginScene")
        storyboard.gotoScene( "scripts.loginScene", "slideLeft", 300)	
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    
    local params = event.params
    local email = params.email

    local b = display.newRect(group, 0,0, __appContentWidth__, __appContentHeight__)
    b.anchorX, b.anchorY = 0,0
    b:setFillColor(0.9,0.9,0.9,1)
    b:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    navBar = widget.newNavigationBar({
        title = language["issuePwResultScene"]["title_bar"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__
    })
    
    group:insert(navBar)

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 250)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + 20
    
    local txtOptions = 
    {
        text = string.gsub(language["issuePwResultScene"]["result"],"__EMAIL__",email),     
        x = display.contentCenterX,
        width = bg_w.width - 10,
        font = native.systemFontBold,   
        fontSize = 16,
        align = "left"
    }
    local issue_pw_result = display.newText( txtOptions )
    issue_pw_result.anchorY = 0
    issue_pw_result.y = bg_w.y + 10
    issue_pw_result:setFillColor( 0, 0, 0 )
    group:insert(issue_pw_result)

    confirm_button = widget.newButton
    {
        width = 200,
        height = 40,
        top = bg_w.y + bg_w.height * 3 / 4,
        defaultFile = "images/button_inframe/btn_inframe_blue_2_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __textSubMenuFontSize__,
        label = language["issuePwResultScene"]["confirm_button"],
        onRelease = confirmButtonEvent
    }
    confirm_button.x = display.contentCenterX
    group:insert(confirm_button)

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
    group:removeSelf()
    group = nil
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
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