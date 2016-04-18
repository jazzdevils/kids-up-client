
require("widgets.widget_photoSavePanel")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local sceneData = require("scripts.sceneData")
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
local language = getLanguage()

local imageGroup
local previous_scene

system.activate( "multitouch" )

local SliderFactory = require 'widgets.SliderFactory'
local sv
local savePanel
local thread_id
local closeButtonGroup, menuButtonGroup


---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onImageTapListner(event)
    if utils.IS_Demo_mode(storyboard, true) == true then
        return true
    end
    
    print(event.phase)
    if(sv) then
        local oData = sv:getCurrentImageFileName()
        table.insert(oData, previous_scene)
        table.insert(oData, thread_id)

        if(oData) then
            if (savePanel and savePanel.isShowing == true) then
                savePanel:hide()
                savePanel.isShowing = false
            else
                sceneData.addSceneDataWithUID("selectedImage", oData)
                if(savePanel) then
                    savePanel:show()
                    savePanel.isShowing = true
                else
                    savePanel = widget.newSharingPanelForSlide()
                    savePanel:show()
                    savePanel.isShowing = true
                end

                return true
            end
        end    
    end    
end

local function onCloseTapListner(event)
    storyboard.hideOverlay(true, "fade", 300)
    return false
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    imageGroup = display.newGroup()
    previous_scene = event.params.previous_scene
    
    local bgRect = display.newRect(display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__)
--    bgRect:addEventListener("touch", onCloseTouchListner)
    bgRect.isHitTestable = false
    bgRect:setFillColor( 0 )
    imageGroup:insert(bgRect)
    
    local slideImageList = event.params.slideImageList
    local selectedImageFileName = event.params.startFileName
    thread_id = event.params.thread_id
    
    local function getStartIndex()
        local imageCount = #slideImageList
        
        if (imageCount > 1) and (selectedImageFileName)  then
            for i=1, imageCount do
                if(selectedImageFileName == slideImageList[i]) then
                    return i
                end
            end
        else
            return 1
        end
    end
    local selectedImageIndex = getStartIndex()
    
    sv = SliderFactory.newImageSlider(__appContentWidth__, __appContentHeight__)-- - __statusBarHeight__)
    sv:setDataProvider(slideImageList, system.TemporaryDirectory, selectedImageIndex)
    sv.x = 0
    sv.y = __statusBarHeight__
    
    imageGroup:insert(sv)
    group:insert(imageGroup)
    
    if(user.userData.jobType == __PARENT__) then
        menuButtonGroup = display.newGroup()
        local menuButton = display.newRoundedRect(0, 0, 50, 20, 3)
        menuButton.anchorX = 0
        menuButton.anchorY = 0
        menuButton.x = 10
        menuButton.y = __statusBarHeight__ + menuButton.height
        menuButton:setFillColor(0,0 , 0, 1)
        menuButton.strokeWidth = 1
        menuButton:setStrokeColor(1, 1, 1, 1)
        menuButtonGroup:insert(menuButton)

        local menuButton_text = display.newText(language["slideImageViewer"]["menu"], 0, 0, native.systemFont, 10)
        menuButton_text.anchorX = 0
        menuButton_text.anchorY = 0
        menuButton_text.x = menuButton.x + (menuButton.width - menuButton_text.width)/2
        menuButton_text.y = menuButton.y + (menuButton.height - menuButton_text.height)/2
        menuButtonGroup:insert(menuButton_text)
        imageGroup:insert(menuButtonGroup)

        menuButtonGroup:addEventListener("tap", onImageTapListner)
    end
    
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
    
    local closeButton_text = display.newText(language["slideImageViewer"]["close"], 0, 0, native.systemFont, 10)
    closeButton_text.anchorX = 0
    closeButton_text.anchorY = 0
    closeButton_text.x = closeButton.x + (closeButton.width - closeButton_text.width)/2
    closeButton_text.y = closeButton.y + (closeButton.height - closeButton_text.height)/2
    closeButtonGroup:insert(closeButton_text)
    imageGroup:insert(closeButtonGroup)
    
    closeButtonGroup:addEventListener("tap", onCloseTapListner)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = previous_scene
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if(closeButtonGroup) then
        closeButtonGroup:removeSelf()
        closeButtonGroup = nil
    end
    
    if (savePanel) then
        savePanel:hide()
        savePanel.isShowing = false
    end
    
    if(imageGroup) then
        imageGroup:removeSelf()
        imageGroup = nil
    end
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
--    if(closeButtonGroup) then
--        closeButtonGroup:removeSelf()
--        closeButtonGroup = nil
--    end
--    
--    if (savePanel) then
--        savePanel:hide()
--        savePanel.isShowing = false
--    end
--    
--    if(imageGroup) then
--        imageGroup:removeSelf()
--        imageGroup = nil
--    end
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

