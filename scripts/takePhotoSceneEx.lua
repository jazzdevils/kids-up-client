---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------

--require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local scene = storyboard.newScene()
local media = require("media")
local guid = require ("scripts.guid")
local sceneData = require("scripts.sceneData")
local language = getLanguage()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

local fromScene
local imagePath
local imageMaxCount

local display_group 

local photo		-- holds the photo object
local navBar
local circleButton

local photolist
local photolist_add

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:

local function circleImage()
    if(photo) then
        photo:rotate(90)
    end
end

local sessionComplete = function(event)
    if ( event.completed ) then
        photo = event.target
            
        if (photo) then
            local scaleFactor = __appContentWidth__/photo.width 
            local newHeight = math.floor(photo.height * scaleFactor)
            local newWidth = math.floor(photo.width * scaleFactor)
            
            photo.height = newHeight
            photo.width = newWidth
            photo.x = centerX
            photo.y = centerY
            
            display_group:insert(photo)
            
            navBar.isVisible = true
            navBar:toFront()
            
            circleButton.isVisible = true
            circleButton:toFront()
            print( "photo w,h = " .. photo.width .. "," .. photo.height)
        else
            print( "not photo object")
            storyboard.purgeScene(fromScene)
            storyboard.gotoScene(fromScene)
        end
    else
        print("not event.completed")
        storyboard.purgeScene(fromScene)
        storyboard.gotoScene(fromScene)
    end
end

local function savePhoto()
    if (photo) then
        local sGuid = guid.generate()
        local photoFileName = sGuid..".jpg"
        -- Capture the bounds of the screen.
        if(imageMaxCount == 1) then
            photolist[1] = photoFileName
        else
            table.insert(photolist, photoFileName)
            
            if(photolist_add) then
                table.insert(photolist_add, photoFileName) 
            end
        end
        
        display.save(photo, { filename=photoFileName, baseDir = system.TemporaryDirectory, isFullResolution=false } )
        
        photo:removeSelf()
        photo = nil
        
        if(imageMaxCount > #photolist ) then
            native.showAlert(language["appTitle"], language["takePhotoSceneEx"]["retry_question"], 
                { language["takePhotoSceneEx"]["yes"],language["takePhotoSceneEx"]["no"] },  
                function(event) 
                    if "clicked" == event.action then
                        local i = event.index
                        if 1 == i then
                            navBar.isVisible = false
                            circleButton.isVisible = false

                            media.capturePhoto( { listener = sessionComplete } )
                        else
                            storyboard.purgeScene(fromScene)
                            storyboard.gotoScene(fromScene)
                        end
                    end    
                end
            )
        else
            storyboard.purgeScene(fromScene)
            storyboard.gotoScene(fromScene)    
        end
                
    end
end

function scene:createScene( event )
    local group = self.view
    display_group = group
    
    photolist_add = sceneData.getSceneDataWithUID("photolist_add")
    photolist = sceneData.getSceneDataWithUID("photolist")
    fromScene = event.params.fromScene
    imagePath = event.params.imagePath
    imageMaxCount = event.params.imageMaxCount
    
    local bkgd = display.newRect( centerX, centerY, _W, _H )
    bkgd:setFillColor( 0, 0, 0 , 0.5)
    group:insert(bkgd)
    
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["takePhotoSceneEx"]["cancel"],
        onRelease = function() 
                        navBar.isVisible = false
                        circleButton.isVisible = false
                        
                        if(photo) then
                            photo:removeSelf()
                            photo = nil
                            print("photo:removeSelf()")
                        end
                        media.capturePhoto( { listener = sessionComplete } )
                    end ,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",
    }

    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["takePhotoSceneEx"]["select"],
        onRelease = savePhoto,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_ok_normal.png",
        overFile = "images/top_with_texts/btn_top_text_ok_touched.png",
    }
    
    navBar = widget.newNavigationBar({
        title = language["takePhotoSceneEx"]["take_photo"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
--        includeStatusBar = true
    })
    group:insert(navBar)
    navBar.isVisible = false
    
    circleButton = widget.newButton {
        left = 0,
        top = 0,
        width = 30,
        height = 30,
        defaultFile = "images/assets1/icon_rotate_photo.png",
--        overFile = "images/etc/circle.png",
        fontSize = __buttonFontSize__,
--        labelColor = { default =  {1, 1, 1}, over = { 0, 0, 0} },
        onRelease = circleImage,
    }
    circleButton.anchorX = 0
    circleButton.anchorY = 0
    circleButton.x = circleButton.width 
    circleButton.y = display.contentHeight - 40
    group:insert( circleButton )
    circleButton.isVisible = false
        
    print("getPhoto createScene")
    
    if media.hasSource( media.Camera ) then
        media.capturePhoto( { listener = sessionComplete } )
    end
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.returnTo = fromScene
    print("getPhoto enterScene")
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    print("getPhotoExitScene")
    if(photo) then
        display.remove(photo)
    end 
    
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    print("getPhotodidExitScene")
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    print("getPhotodestoryScene")
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



