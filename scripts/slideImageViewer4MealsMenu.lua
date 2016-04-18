local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local language = getLanguage()

local imageGroup
local previous_scene

system.activate( "multitouch" )

local SliderFactory4MealsMenu = require 'widgets.SliderFactory4MealsMenu'
local sv

local closeButtonGroup
local deleteButtonGroup

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onCloseTouchListner(event)
    local object = event.target
    if(event.phase == "began") then
    
    elseif(event.phase == "ended") then
        storyboard.hideOverlay("fade", 300)
    end    
    
    return true
end

--local function onDeleteTouchListner(event)
--    local object = event.target
--    if(event.phase == "began") then
--    
--    elseif(event.phase == "ended") then
--        storyboard.hideOverlay("fade", 300)
--        
--        print("storyboard.reloadScene(scripts.mealMenuListScene)")
--        storyboard.loadScene("scripts.mealMenuListScene")
--    end    
--    
--    return true
--end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    imageGroup = display.newGroup()
    previous_scene = storyboard.getPrevious()
    
    local bgRect = display.newRect(display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__)
    bgRect.isHitTestable = false
    bgRect:setFillColor( 0 )
    imageGroup:insert(bgRect)
    
    local selected_menus = event.params.selected_menus
    local selected_menu_date = event.params.selected_menu_date
    local selected_menu_thumbImgName = event.params.selected_menu_thumbImgName
                    
    local imagesFileName4Slide = {}
    for i= 1, #selected_menus do
        imagesFileName4Slide[i] = selected_menus[i].preview_image:match("([^/]+)$")
    end
    
    local function getStartIndex()
        local imageCount = #selected_menus
        
        if (imageCount > 1) then
            for i=1, imageCount do
                if(selected_menu_thumbImgName == selected_menus[i].thumbnail_image:match("([^/]+)$")) then
                    return i
                end
            end
        else
            return 1
        end
    end
    
    local selectedImageIndex = getStartIndex()
    
    sv = SliderFactory4MealsMenu.newImageSlider(__appContentWidth__, __appContentHeight__) -- - __statusBarHeight__)
    sv:setDataProvider(imagesFileName4Slide, system.TemporaryDirectory, selectedImageIndex, selected_menus, selected_menu_date)
    sv.x = 0
    sv.y = __statusBarHeight__
    
    imageGroup:insert(sv)
    group:insert(imageGroup)
    
    closeButtonGroup = display.newGroup()
    local closeButton = display.newRoundedRect(0, 0, 50, 20, 3)
    closeButton.anchorX = 0
    closeButton.anchorY = 0
    closeButton.x = __appContentWidth__ - closeButton.width - 10
    closeButton.y = __statusBarHeight__ + closeButton.height
    closeButton:setFillColor(0,0 , 0, 1)
    closeButton.strokeWidth = 1
    closeButton:setStrokeColor(1, 1, 1, 1)
    closeButtonGroup:insert(closeButton)
    
    local closeButton_text = display.newText(language["slideImageViewer4MealsMenu"]["close"], 0, 0, native.systemFont, 10)
    closeButton_text.anchorX = 0
    closeButton_text.anchorY = 0
    closeButton_text.x = closeButton.x + (closeButton.width - closeButton_text.width)/2
    closeButton_text.y = closeButton.y + (closeButton.height - closeButton_text.height)/2
    closeButtonGroup:insert(closeButton_text)
    imageGroup:insert(closeButtonGroup)
    
    closeButtonGroup:addEventListener("touch", onCloseTouchListner)
    
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
    
    if(closeButtonGroup) then
        closeButtonGroup:removeSelf()
        closeButtonGroup = nil
    end
    
    if(imageGroup) then
        imageGroup:removeSelf()
        imageGroup = nil
    end
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





