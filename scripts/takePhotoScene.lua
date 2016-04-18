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
local language = getLanguage()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

local kidData
local fromScene
local imagePath

local display_group 

local photo		-- holds the photo object
local navBar
local viewFinder
local circleButton

-- turn on multitouch
system.activate("multitouch")

-- which environment are we running on?
local isDevice = (system.getInfo("environment") == "device")

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

local function savePhoto()
    local function networkListener( event )
        native.setActivityIndicator(false)
        
        if ( event.isError ) then
            print( "Network error!")
        elseif ( event.phase == "ended" ) then
            print ( "Upload complete!" )
        end
    end
    
    if (photo and kidData) then
        print(kidData)
        local sGuid = guid.generate()
        local photoFileName = sGuid..".jpg"
        kidData.profileImage = photoFileName
        storyboard.state.MEMBER_PROFILENAME = photoFileName
        
        local xMin = 4
        local xMax = viewFinder.width - 2
        local yMin = (__appContentHeight__ - viewFinder.height) /2 + 1
        local yMax = yMin + viewFinder.height - 2
        local screenBounds =
        {
            xMin = xMin,
            xMax = xMax,
            yMin = yMin,
            yMax = yMax,
        }
        
        print("xMin, xMax, yMin, yMax = "..xMin..","..xMax..","..yMin..","..yMax)
        -- Capture the bounds of the screen.
        local captureImage = display.captureBounds( screenBounds )
        captureImage.x = display.contentCenterX
        captureImage.y = display.contentCenterY
        display.save(captureImage, { filename=photoFileName, baseDir = imagePath, isFullResolution=false } )
--        display.save(photo, { filename=photoFileName, baseDir = imagePath, isFullResolution=false } )
        
--        print( "saved photo name, w,h ,size = "..photoFileName.."," .. photo.width .. "," .. photo.height)
        print( "saved photo name, w,h ,size = "..photoFileName.."," .. captureImage.width .. "," .. captureImage.height)
        
        captureImage:removeSelf()
        captureImage = nil
        
        photo:removeSelf()
        photo = nil
        
        viewFinder:removeSelf()
        viewFinder = nil
        
        storyboard.purgeScene(fromScene)
        storyboard.gotoScene(fromScene)
    end
end

local sessionComplete = function(event)
    if ( event.completed ) then
        photo = event.target
            
        if (photo) then
            local function lengthOf( a, b )
                local width, height = b.x-a.x, b.y-a.y
                return (width*width + height*height)^0.5
            end

                        -- calculates the average centre of a list of points
            local function calcAvgCentre( points )
                local x, y = 0, 0

                for i=1, #points do
                    local pt = points[i]
                    x = x + pt.x
                    y = y + pt.y
                end

                return { x = x / #points, y = y / #points }
            end

                        -- calculate each tracking dot's distance and angle from the midpoint
            local function updateTracking( centre, points )
                for i=1, #points do
                    local point = points[i]
                    point.prevDistance = point.distance

                    point.distance = lengthOf( centre, point )
                end
            end

                        -- calculates scaling amount based on the average change in tracking point distances
            local function calcAverageScaling( points )
                local total = 0

                for i=1, #points do
                    local point = points[i]
                    total = total + point.distance / point.prevDistance
                end

                return total / #points
            end

            -- creates an object to be moved
            local function newTrackDot(e)
            -- create a user interface object
                local circle = display.newCircle( e.x, e.y, 50 )
                -- make it less imposing
                circle.alpha = 0

                -- keep reference to the rectangle
                local rect = e.target

                -- standard multi-touch event listener
                function circle:touch(e)
                    -- get the object which received the touch event
                    local target = circle

                    -- store the parent object in the event
                    e.parent = rect

                    -- handle each phase of the touch event life cycle...
                    if (e.phase == "began") then
                        -- tell corona that following touches come to this display object
                        display.getCurrentStage():setFocus(target, e.id)
                        -- remember that this object has the focus
                        target.hasFocus = true
                        -- indicate the event was handled
                        return true
                    elseif (target.hasFocus) then
                        -- this object is handling touches
                        if (e.phase == "moved") then
                            -- move the display object with the touch (or whatever)
                            target.x, target.y = e.x, e.y
                        else -- "ended" and "cancelled" phases
                            -- stop being responsible for touches
                            display.getCurrentStage():setFocus(target, nil)
                            -- remember this object no longer has the focus
                            target.hasFocus = false
                        end

                    -- send the event parameter to the rect object
                        rect:touch(e)

                        -- indicate that we handled the touch and not to propagate it
                        return true
                    end

                    -- if the target is not responsible for this touch event return false
                    return false
                end

                -- listen for touches starting on the touch layer
                circle:addEventListener("touch")

                -- listen for a tap when running in the simulator
                function circle:tap(e)
                    if (e.numTaps == 2) then
                        -- set the parent
                        e.parent = rect

                        -- call touch to remove the tracking dot
                        rect:touch(e)
                    end
                    return true
                end

                -- only attach tap listener in the simulator
                if (not isDevice) then
                    circle:addEventListener("tap")
                end

                -- pass the began phase to the tracking dot
                circle:touch(e)

                -- return the object for use
                return circle
            end
            
            function photo:touch(e)
                -- get the object which received the touch event
                local target = e.target

                -- handle began phase of the touch event life cycle...
                if (e.phase == "began") then
                    print( e.phase, e.x, e.y )

                    -- create a tracking dot
                    local dot = newTrackDot(e)

                    -- add the new dot to the list
                    photo.dots[ #photo.dots+1 ] = dot

                    -- pre-store the average centre position of all touch points
                    photo.prevCentre = calcAvgCentre( photo.dots )

                    -- pre-store the tracking dot scale and rotation values
                    updateTracking( photo.prevCentre, photo.dots )

                    -- we handled the began phase
                    return true
                elseif (e.parent == photo) then
                    if (e.phase == "moved") then
                        print( e.phase, e.x, e.y )

                        -- declare working variables
                        local centre, scale, rotate = {}, 1, 0

                        -- calculate the average centre position of all touch points
                        centre = calcAvgCentre( photo.dots )

                        -- refresh tracking dot scale and rotation values
                        updateTracking( photo.prevCentre, photo.dots )

                        -- if there is more than one tracking dot, calculate the rotation and scaling
                        if (#photo.dots > 1) then
                            -- calculate the average scaling of the tracking dots
                            scale = calcAverageScaling( photo.dots )

                            -- apply scaling to rect
                            photo.xScale, photo.yScale = photo.xScale * scale, photo.yScale * scale

                        end

                        -- update the position of rect
                        photo.x = photo.x + (centre.x - photo.prevCentre.x)
                        photo.y = photo.y + (centre.y - photo.prevCentre.y)

                        -- store the centre of all touch points
                        photo.prevCentre = centre
                    else -- "ended" and "cancelled" phases
                        print( e.phase, e.x, e.y )

                        -- remove the tracking dot from the list
                        if (isDevice or e.numTaps == 2) then
                            -- get index of dot to be removed
                            local index = table.indexOf( photo.dots, e.target )

                            -- remove dot from list
                            table.remove( photo.dots, index )

                            -- remove tracking dot from the screen
                            e.target:removeSelf()

                            -- store the new centre of all touch points
                            photo.prevCentre = calcAvgCentre( photo.dots )

                            -- refresh tracking dot scale and rotation values
                            updateTracking( photo.prevCentre, photo.dots )
                        end
                    end

                    return true
                end

                -- if the target is not responsible for this touch event return false
                return false
            end
            local scaleFactor = __appContentWidth__/photo.width 
            local newHeight = math.floor(photo.height * scaleFactor)
            local newWidth = math.floor(photo.width * scaleFactor)
            
            photo.height = newHeight
            photo.width = newWidth
--            photo = imageUtile.newImageRect(photo, __appContentWidth__, __appContentHeight__)
            photo.x = centerX
            photo.y = centerY
            
            photo.dots = {}
            display_group:insert(photo)
            
            local viewFinderWidth = display.contentWidth - 2
            local viewFinderHeight = viewFinderWidth * 1.13
            viewFinder = display.newRoundedRect( display.contentCenterX, display.contentCenterY, viewFinderWidth, viewFinderHeight, 1)
            viewFinder:setFillColor( 0, 0, 0, 0 )
            viewFinder:setStrokeColor( 255, 0, 0, 255 )
            viewFinder.strokeWidth = 2
            display_group:insert(viewFinder)
            
            navBar.isVisible = true
            navBar:toFront()
            
            circleButton.isVisible = true
            circleButton:toFront()
            
            photo:addEventListener("touch")
            
            print( "photo w,h = " .. photo.width .. "," .. photo.height)
        else
            print( "not photo object")
            storyboard.purgeScene(fromScene)
            storyboard.gotoScene(fromScene)
        end
    else
        print("not event.completed")
        storyboard.gotoScene(fromScene)
        storyboard.gotoScene(fromScene)
    end
end

function scene:createScene( event )
    local group = self.view
    display_group = group
    
    kidData = event.params.kidData
    fromScene = event.params.fromScene
    imagePath = event.params.imagePath
    
    local bkgd = display.newRect( centerX, centerY, _W, _H )
    bkgd:setFillColor( 0, 0, 0 , 0.5)
    group:insert(bkgd)
    
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["takePhotoScene"]["cancel"],
        onRelease = function() 
                        navBar.isVisible = false
                        circleButton.isVisible = false
                        
                        if(photo) then
                            photo:removeSelf()
                            photo = nil
                            print("photo:removeSelf()")
                        end
                        if(viewFinder) then
                            viewFinder:removeSelf()
                            viewFinder = nil
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
        label = language["takePhotoScene"]["select"],
        onRelease = savePhoto,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_ok_normal.png",
        overFile = "images/top_with_texts/btn_top_text_ok_touched.png",
    }
    
    navBar = widget.newNavigationBar({
        title = language["takePhotoScene"]["take_photo"],
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
    
    if(viewFinder) then
        display.remove(viewFinder)
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

