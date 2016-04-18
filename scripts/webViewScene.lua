---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar4WebView")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local html = require("scripts.htmlPageController")
local activityIndicator

local navBar
local webView

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    local params = event.params
    native.setProperty("networkActivityIndicatorVisible", false)
    
    local bg = display.newRect(group, 0, 0, __appContentWidth__, __appContentHeight__)
    bg.strokeWidth = 0
    bg:setFillColor( 1, 1, 1 )
--    bg:setStrokeColor( 0, 0, 0)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_right_opt = {
        onEvent = function(event)
            if event.phase == "ended" then
                storyboard.hideOverlay("slideDown", 300)
            end
        end,
        width = 50,
        height = 50,
        defaultFile = "images/top/btn_top_cancel_normal.png",
        overFile = "images/top/btn_top_cancel_touched.png",    
--        label = ">",    
        
    }
    
    local btn_forward_opt = {
        onEvent = function(event)
            if event.phase == "ended" then
                if webView.canGoForward then
                    webView:forward()
                end
            end
        end,
        width = 50,
        height = 50,
        defaultFile = "images/top/btn_top_next_normal.png",
        overFile = "images/top/btn_top_next_touched.png",    
    }
    
    local btn_backward_opt = {
        onEvent = function(event)
            if event.phase == "ended" then
                if webView.canGoBack then
                    webView:back()
                end
            end
        end,
        width = 50,
        height = 50,
        defaultFile = "images/top/btn_top_back_normal.png",
        overFile = "images/top/btn_top_back_touched.png",    
    }
    navBar = widget.newNavigationBar4WebView({
            title = language["webViewScene"]["loading"],
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            rightButton = btn_right_opt,
            backwardButton = btn_backward_opt,
            forwardButton = btn_forward_opt,
        })
    group:insert(navBar)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    local params = event.params
    local url = params.url
    local title = params.title
    
    storyboard.isAction = false
    
    local function webListener( event )
        if (event.type == "loaded") then
--            if activityIndicator then
--                activityIndicator:destroy()
--            end
--            native.setActivityIndicator( false )
            navBar.setTitle(title)
            print( "The event.type is " .. event.type ) -- print the type of request
        end

--        if event.errorCode then
--            if activityIndicator then
--                activityIndicator:destroy()
--            end
--            navBar.setTitle(language["webViewScene"]["failed"])
--        end
    end
    
    local webView_y = navBar.height
    webView = native.newWebView( 0, webView_y, display.contentWidth, __appContentHeight__ - webView_y)
    webView.anchorX = 0
    webView.anchorY = 0
    webView:request( url )
    native.setProperty("networkActivityIndicatorVisible", false)
    
--    activityIndicator = ActivityIndicator:new_small(navBar.width - 30, (navBar.height - 26))
    native.setActivityIndicator( false )
    webView:addEventListener( "urlRequest", webListener )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
    webView:removeSelf()
    webView = nil
--    native.setProperty("networkActivityIndicatorVisible", true)
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





