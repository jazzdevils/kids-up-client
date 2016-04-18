

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
local function back_buttonOnEvent(event)
    if event.phase == "ended" then
        local previous_scene_name = storyboard.getPrevious()
        storyboard.gotoScene( previous_scene_name, "slideRight", 300)	
    end;    
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
    
    local login_text = display.newText(group, language["loginScene"]["reset_password"], display.contentCenterX + 15, 55, 165, 100, nil, 18)
    
    local back_button = widget.newButton
    {
        width = 32,
        height = 32,
        left = 5, 
        top = display.topStatusBarContentHeight + 2,
        defaultFile = "images/common/btn_back.png",
        overFile = "images/common/btn_back_on.png",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        onEvent = back_buttonOnEvent
    }
    group:insert(back_button)
    
    local email_text = display.newText(group, language["loginScene"]["email_editbox"], 80, 295, 65, 100, nil, 16)
    
    local email_field = native.newTextField( 205, 256, 184, 25, onEmailText)
    email_field.font = native.newFont( native.systemFontBold, 24 )
    email_field.text = "aaa@aaa.com"
    email_field.inputType = "email"
    email_field:setTextColor( 0.4, 0.4, 0.8 )
    group:insert(email_field)
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

