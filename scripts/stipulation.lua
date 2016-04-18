---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.translationControl")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local language = getLanguage()

local widget = require("widget")
local language = getLanguage()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function scrollListener( event )
    local phase = event.phase
    local direction = event.direction
	
    if "began" == phase then
		--print( "Began" )
    elseif "moved" == phase then
		--print( "Moved" )
    elseif "ended" == phase then
		--print( "Ended" )
    end
	
	-- If the scrollView has reached it's scroll limit
    if event.limitReached then
    	if "up" == direction then
    		print( "Reached Top Limit" )
	elseif "down" == direction then
		print( "Reached Bottom Limit" )
	elseif "left" == direction then
		print( "Reached Left Limit" )
	elseif "right" == direction then
		print( "Reached Right Limit" )
	end
    end
			
    return true
end

local function back_buttonOnEvent(event)
    if event.phase == "ended" then
        local previous_scene_name = storyboard.getPrevious()
        storyboard.gotoScene( previous_scene_name, "slideRight", 300)	
    end;    
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/common/bg_sub.png", 360, 570)
--    group:insert(bg)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    
    local bg_top_sub = display.newImageRect(group, "images/common/bg_top_sub.png", 360, 74)
    bg_top_sub.x = display.contentCenterX
    bg_top_sub.y = display.topStatusBarContentHeight
    
    local agree_des_text = display.newText(group, language["joinScene"]["agree_description"], display.contentCenterX, 18, nil, 18)
    
    local back_button = widget.newButton
    {
        width = 32,
        height = 32,
        left = 5, 
        top = display.topStatusBarContentHeight + 2,
        defaultFile = "images/common/btn_back.png",
        overFile = "images/common/btn_back.png",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        onEvent = back_buttonOnEvent
    }
    group:insert(back_button)
    
    
--    local function webListener( event )
--        if event.url then
--            print( "You are visiting: " .. event.url )
--        end
--
--        if event.type then
--            print( "The event.type is " .. event.type ) -- print the type of request
--        end
--
--        if event.errorCode then
--            native.showAlert( "Error!", event.errorMessage, { "OK" } )
--        end
--    end
    
--    local webView = native.newWebView(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.contentHeight)
--    webView:request( "http://www.google.com/" )
--    webView:addEventListener("urlRequest", webListener)
    local scrollView = widget.newScrollView
    {   
        backgroundColor = { 0.3, 0.3, 0.3 },
        left = 0,
	top = bg_top_sub.height /2,
	width = display.contentWidth,
	height = display.contentHeight -  bg_top_sub.height /2,
	bottomPadding = 50,
--	id = "onBottom",
	horizontalScrollDisabled = true,
	verticalScrollDisabled = false,
	listener = scrollListener,
    }
    
    
    local function networkListener( event )
        if ( event.isError ) then
            local alert = native.showAlert( "Error", "Network Error!", { "OK"})
            print (event.bytesTransferred ..",".. event.status)
        else
            local lotsOfText
            lotsOfText = event.response
--            local lotsOfText = "Lorem ipsum dolor sit amet "
            local lotsOfTextObject = display.newText( lotsOfText, display.contentCenterX, 0, 300, 0, native.systemFont, 14)
            lotsOfTextObject:setFillColor( 1 ) 
            lotsOfTextObject.anchorY = 0.0		-- Top
            scrollView:insert( lotsOfTextObject )
--            local alert = native.showAlert( "OK", lotsOfText:sub(1, 20)  , { "OK"})
            print ( "RESPONSE: " .. event.response )
        end
    end
    
    group:insert(scrollView)
    
--    network.request( "https://raw.githubusercontent.com/funkyvisions/DDGameKitHelper/master/README", "GET", networkListener )
    network.request( "https://raw.githubusercontent.com/funkyvisions/ParentalGate/master/LICENSE", "GET", networkListener )
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
    
--    display.remove(group)
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
    
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    
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

