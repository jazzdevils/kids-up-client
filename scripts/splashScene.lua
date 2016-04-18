---------------------------------------------------------------------------------
-- splashScene
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.translationControl")

local ga = require( "scripts.googleAnalytics" )

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local sound = require("scripts.sounds")

--storyboard.removeAll()

--local language = require("scripts.translationJap")
local language = getLanguage()
local widget = require("widget")

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local imageTimer
local visual_images = {"images/top/top_visual_1.png", "images/top/top_visual_2.png", "images/top/top_visual_3.png" }

-- Called when the scene's view does not exist:
local imageGroup = display.newGroup()
local visualimg = {}


local function onPageSwipeOnTimer( event )
    local idx = imageGroup.currentImg
    
    transition.to(visualimg[idx], {time=1000, alpha = 0})
    
    idx = idx + 1
    if ( idx > #visual_images ) then
        idx = 1
    end
    
    visualimg[idx].isVisible = true
    transition.to(visualimg[idx], {time=1000, alpha = 1})
    
    imageGroup.currentImg = idx
end


local function joinButtonEvent( event )
    if event.phase == "ended" then --or event.phase == "cancelled" then
        ga.track("joinButton")
        storyboard.gotoScene("scripts.joinScene", "slideLeft", 300)
    end
--    sound.audioPlay(sound.buttonPress, {})
    
    return true
end

local function loginButtonEvent( event )
--      sound.audioPlay(sound.buttonPress, {})
      
    if event.phase == "ended" then --or event.phase == "cancelled" then
        ga.track("logininButton")
        storyboard.gotoScene("scripts.loginScene", "slideLeft", 300 )
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    
    group:insert(imageGroup)
    
    local bg = display.newImageRect(imageGroup, "images/top/bg_top.png", 360, 570)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    
    local logo = display.newImageRect(group, "images/top/pic_logo.png", 242, 120)
    logo.x = display.contentCenterX
    logo.y = display.contentCenterY - 164
    
    local visula_box = display.newImageRect(imageGroup, "images/top/bg_top_visual.png", 304, 200)
    visula_box.x = display.contentCenterX
    visula_box.y = display.contentCenterY - 5
    
    for i = 1, #visual_images do
        visualimg[i] = display.newImageRect( imageGroup, visual_images[i], 280, 174 )
        visualimg[i].x = display.contentCenterX
        visualimg[i].y = display.contentCenterY - 5
        visualimg[i].alpha = 0
        visualimg[i].isVisible = false
    end
    imageGroup.currentImg = 1
    visualimg[imageGroup.currentImg].alpha = 1
    visualimg[imageGroup.currentImg].isVisible = true
    
    local login_button = widget.newButton
    {
        width = 221 ,
        height = 58 ,
        left = display.contentCenterX - (221/2)  , 
        top = display.contentCenterY + 105, 
        defaultFile = "images/top/btn_signin.png",
        overFile = "images/top/btn_signin_off.png",
        labelColor = { default={ 0.7, 0.7, 0.7 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __buttonFontSize__,
        label = language["main"]["login_button"],
        onRelease = loginButtonEvent
    }
    group:insert(login_button)
    
    local join_button = widget.newButton
    {
        width = 221,
        height = 58,
        left = display.contentCenterX - (221/2), 
        top = display.contentCenterY + 170 , 
        defaultFile = "images/top/btn_new.png",
        overFile = "images/top/btn_new_off.png",
        labelColor = { default={ 0.7, 0.7, 0.7 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __buttonFontSize__,
        label = language["main"]["join_button"],
        onRelease = joinButtonEvent
    }
    group:insert(join_button)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    imageTimer = timer.performWithDelay(5000, onPageSwipeOnTimer, 0)
    
    local connection = require("scripts.network")
    connection.try(function (isAvaliable)
        if (isAvaliable) then
            print("Internet connection ok")
        else
            print("Internet connection not ok")
        end
    end)
    
--    local options = {
--        width = 512,
--        height = 256,
--        numFrames = 8,
--        sheetContentWidth = 1024,
--        sheetContentHeight = 1024
--    }
--    local mySheet = graphics.newImageSheet( "images/effect/runningcat-full.png", options )
--
--    local sequenceData = {
--    { 
----        name = "fastRun",
--        start = 1,
--        count = 8,
--        time = 800,
--        loopCount = 0
--    }  --if defining more sequences, place a comma here and proceed to the next sequence sub-table
--    }
-- 
--    local animation = display.newSprite(group, mySheet, sequenceData )
--    animation.width = 50
--    animation.height = 25
--    animation.x = display.contentWidth/2  --center the sprite horizontally
--    animation.y = display.contentHeight/2  --center the sprite vertically
--    
-- 
--    animation:play()
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
--    display.remove(group)
    timer.cancel(imageTimer) 
    imageTimer = nil
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
--    display:remove(group)
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
    for i = 1, #visual_images do
        display.remove(visualimg[i])
    end
    
    group:removeSelf()
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