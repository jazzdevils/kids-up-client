---------------------------------------------------------------------------------
-- splashScene
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.translationControl")
require("widgets.widget_tourSharePanel")

--local ga = require( "scripts.googleAnalytics" )

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
--local json = require("json")
local language = getLanguage()
local widget = require("widget")
local user = require("scripts.user_data")
local sceneData = require("scripts.sceneData")
local access = require("scripts.accessScene")

local MOVE_PENDING = 20
local tourSharePanel

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local imageGroup
local visualimg = {}
local visualtxt = {}

local imageTimer
local particleTimer
local visual_images = {"images/bg_set/bg_home1.png", "images/bg_set/bg_home2.png", "images/bg_set/bg_home3.png" }

local visual_text = {
    language["top"]["message1"], 
    language["top"]["message2"],
    language["top"]["message3"],
}

local function onPageSwipeOnTimer( event )
    local idx = imageGroup.currentImg
    
    transition.to(visualtxt[idx], {time=500, alpha = 0})
    transition.to(visualimg[idx], {time=1000, alpha = 0})
    
    idx = idx + 1
    if ( idx > #visual_images ) then
        idx = 1
    end
    
--    visualimg[idx].isVisible = true
--    visualtxt[idx].isVisible = true
    
--    transition.to(visualimg[idx], { time=3500, x=(visualimg[idx].x - 5), y=(visualimg[idx].y - 5)} )
    
    transition.to(visualimg[idx], {time=1000, alpha = 1, onComplete = 
        function()
            transition.to(visualtxt[idx], {time=500, alpha = 1})
        end
        }  
    )
    
    imageGroup.currentImg = idx
end

local function testButtonEvent( event )
    if event.phase == "ended" then --or event.phase == "cancelled" then
        storyboard.gotoScene("test.mainScene", "slideLeft", 300)
    end 
    return true
end

local function joinButtonEvent( event )
    if event.phase == "ended" then --or event.phase == "cancelled" then
--        ga.track("joinButton")
--        storyboard.purgeScene("scripts.memberTypeScene")
        storyboard.gotoScene("scripts.memberTypeScene", "slideLeft", 300)
    end
--    sound.audioPlay(sound.buttonPress, {})
    
    return true
end

local function tourButtonEvent( event )
    if event.phase == "ended" then --or event.phase == "cancelled" then
        if (tourSharePanel) then
            tourSharePanel:show()
            tourSharePanel.isShowing = true
        else
            tourSharePanel = widget.newTourSharingPanel()
            tourSharePanel:show()
            tourSharePanel.isShowing = true
        end
    end
    return true
end

local function loginButtonEvent( event )
--      sound.audioPlay(sound.buttonPress, {})
      
    if event.phase == "ended" then --or event.phase == "cancelled" then
--        ga.track("logininButton")
--        storyboard.purgeScene("scripts.loginScene")
        storyboard.gotoScene("scripts.loginScene", "slideLeft", 300 )
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    
    storyboard.state.DEMO_MODE = false --체험 모드인가??
    
    storyboard.removeAll()
    print("Top scene : storyboard.removeAll()")
    
--  혹시 모를 사용자 데이타 free
    user.freeClassList()
    user.freeKidsList()
    user.freeUserData()
        
--  혹시 모를 씬 데이타 free
    sceneData.freeAllSceneData()
    __INVITATION_CODE__ = "" --초대코드 삭제

    imageGroup = display.newGroup()
    
    for i = 1, #visual_images do
        visualimg[i] = display.newImageRect( imageGroup, visual_images[i], __backgroundWidth__, __backgroundHeight__ )
        visualimg[i].x = display.contentCenterX
        visualimg[i].startX = display.contentCenterX
        visualimg[i].y = display.contentCenterY
        visualimg[i].startY = display.contentCenterY
        visualimg[i].alpha = 0
--        visualimg[i].isVisible = false
        
        visualimg[i].fill.effect = "filter.vignette"
        visualimg[i].fill.effect.radius  = 0.1
        
    end
    imageGroup.currentImg = 1
--    visualimg[imageGroup.currentImg].alpha = 1
--    visualimg[imageGroup.currentImg].isVisible = true
    group:insert(imageGroup)
    
    for i = 1, #visual_text do
        local options = {
            parent = imageGroup,
            text = visual_text[i],     
            x = display.contentCenterX,
            y = display.contentCenterY - 40,
            width = 250,     --required for multi-line and alignment
            font = native.systemFontBold,   
            fontSize = 18,
            align = "center"  --new alignment parameter
        }
        visualtxt[i] = display.newText(options)
        visualtxt[i].alpha = 0
    end
    transition.to(visualimg[imageGroup.currentImg], {time=1000, alpha = 1, onComplete = 
        function()
            transition.to(visualtxt[imageGroup.currentImg], {time=500, alpha = 1})
        end
    })
--    transition.to(visualtxt[imageGroup.currentImg], {time=1000, alpha = 1})
    
    local logo = display.newImageRect(group, "images/logo/logo_full_home.png", 157, 113)
    logo.anchorX = 0
    logo.anchorY = 0
    logo.x = 10
    logo.y = __statusBarHeight__ + 10
    group:insert(logo)
    
    local tmp_options = {
        parent = imageGroup,
        text = language["top"]["request_desc"],
        fontSize = __textLabelFont14Size__,
        align = "center"  --new alignment parameter
    }
    local tmp_desc = display.newText(tmp_options)
    
    local request_rect = display.newRect( 0, 0, tmp_desc.width + 2, tmp_desc.height + 10 )
    request_rect.x = display.contentCenterX
--    request_rect.anchorY = 0
--    request_rect.y = tour_button.y + (tour_button.height * 0.5) + 20
    request_rect.y = __appContentHeight__ - request_rect.height - 20
    request_rect.alpha = 0.01
    group:insert(request_rect)
    display.remove(tmp_desc)
    
    local options = {
        parent = imageGroup,
        text = language["top"]["request_desc"],     
        x = display.contentCenterX,
        font = native.systemFontBold,   
        fontSize = __textLabelFont14Size__,
        align = "center"  --new alignment parameter
    }
    local request_desc = display.newText(options)
    request_desc.anchorY = 0
    request_desc.y = request_rect.y - 6
    group:insert(request_desc)
    
    local x1 = request_desc.x - request_desc.width / 2
    local y1 = request_desc.y + request_desc.height
    local x2 = request_desc.x + request_desc.width / 2
    local y2 = request_desc.y + request_desc.height
    local underline = display.newLine(x1, y1, x2, y2)
    underline:setStrokeColor( 1 )
    group:insert(underline)
    
    request_rect:addEventListener("touch", 
        function(event)
            if event.phase == "ended" then
                local options =
                {
                   to = __SUPPORT_EMAIL__,
                   subject = language["top"]["request_title"],
                   body = language["top"]["request_text"],
                }
                native.showPopup( "mail", options )
            end
        end
    )
--    request_rect:addEventListener("touch", 
--        function(event)
--            if event.phase == "ended" then
--                local options =
--                {   effect = "slideLeft",
--                    time = 300,
--                    params = {
----                        email = "encho10@test.com",
----                        pw = "1234",
----                        memberType = __DIRECTOR__, 
----                        invitationCodeInputResult = "0",
--                        
----                        email = "arilang123@naver.com",
----                        pw = "1234",
----                        memberType = __TEACHER__, 
----                        invitationCodeInputResult = "1",
--                        
--                        email = "jazzdevils@gmail.com",
--                        pw = "1234",
--                        memberType = __PARENT__, 
--                        invitationCodeInputResult = "0",
--                    }    
--                }
--                storyboard.purgeScene("scripts.joinCompleteScene")
--                storyboard.gotoScene("scripts.joinCompleteScene", options)
--            end
--        end
--    )
    
    local tour_button = widget.newButton
    {
        width = 240,
        height = 40,
        left = display.contentCenterX - (155/2), 
        top = display.contentCenterY + 150 , 
        defaultFile = "images/button/btn_purple_1_normal.png",
        overFile = "images/button/btn_purple_1_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __textSubMenuFontSize__,
        label = language["tourScene"]["tour_button"],
        onRelease = tourButtonEvent
    }
    tour_button.x = display.contentCenterX
    tour_button.y = request_rect.y - request_rect.height - 20
    group:insert(tour_button)
    
    local join_button = widget.newButton
    {
        width = 240,
        height = 40,
        left = display.contentCenterX - (155/2), 
        top = display.contentCenterY + 150 , 
        defaultFile = "images/button/btn_blue_1_normal.png",
        overFile = "images/button/btn_blue_1_touched.png",
        labelColor = { default={1,1,1}, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __textSubMenuFontSize__,
        label = language["main"]["join_button"],
        onRelease = joinButtonEvent
    }
    join_button.x = display.contentCenterX
    join_button.y = tour_button.y - tour_button.height - 10
    group:insert(join_button)
    
    local login_button = widget.newButton
    {
        width = 240 ,
        height = 40 ,
        left = 0,--display.contentCenterX - (155/2)  , 
        top = display.contentCenterY + 105, 
        defaultFile = "images/button/btn_red_1_normal.png",
        overFile = "images/button/btn_red_1_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __textSubMenuFontSize__,
        label = language["main"]["login_button"],
        onRelease = loginButtonEvent
    }
    login_button.x = display.contentCenterX
    login_button.y = join_button.y - join_button.height - 10
    group:insert(login_button)
    
--    local function onParticleTimer(event)
--        local filePath = system.pathForFile( "data/particle_texture.json")
--        local f = io.open( filePath, "r" )
--        local fileData = f:read( "*a" )
--        f:close()
--
--        local emitterParams = json.decode( fileData )
--
--        local emitter1 = display.newEmitter( emitterParams )
--
--        emitter1.anchorX = 0
--        emitter1.anchorY = 0
--        emitter1.x = logo.x + logo.width/2
--        emitter1.y = logo.y + logo.height + 10
--    end
    
--    particleTimer = timer.performWithDelay(5000, onParticleTimer, 0)
    
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    imageTimer = timer.performWithDelay(5000, onPageSwipeOnTimer, 0)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    transition.cancel()
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
    if(imageTimer) then
        timer.cancel(imageTimer) 
        imageTimer = nil
    end
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
    if(particleTimer) then
        timer.cancel(particleTimer)
        particleTimer = nil
    end
    
    if(imageGroup) then
        imageGroup:removeSelf()
        imageGroup = nil
    end
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

