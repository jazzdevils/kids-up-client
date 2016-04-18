local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local params

-- local forward references should go here --

local function btnTap(event)
    event.target.xScale = 0.95
    event.target.yScale = 0.95
    storyboard.gotoScene (  event.target.destination, { params ={levelNum = params.levelNum}, time=800, effect = "fade"} )
    
    return true
end

local function catchBackgroundOverlay(event)
    return true 
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

    local overlay = display.newImageRect("images/services/overlayv2.png", 220 , 150)
    overlay.x = display.contentCenterX
    overlay.y = display.contentCenterY
    
    local function hideOverlay(event)
	storyboard.hideOverlay("fade", 800)
        
    end 
    overlay:addEventListener ("tap", hideOverlay)
    
    group:insert (overlay)

end



-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	-- Remove listeners attached to the Runtime, timers, transitions, audio tracks

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view


	-- INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	-- Remove listeners attached to the Runtime, timers, transitions, audio tracks

end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )


---------------------------------------------------------------------------------

return scene

