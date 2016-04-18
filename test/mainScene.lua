---------------------------------------------------------------------------------
-- splashScene
-- Scene notes go here
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local language = getLanguage()
local widget = require("widget")
local api = require("scripts.api")
local json = require("json")
require("widgets.widget_newNavBar")

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local navBar

local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "scripts.top", "slideRight", 300 ) 
    end
    return true
end

local function noticeButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.noticeTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function memberButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.memberTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function scheduleButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.scheduleTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function dailymenuButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.dailymenuTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function eventButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.eventTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function mamatalkButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.mamatalkTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function albumButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.albumTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function contactButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.contactTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function kidsMngButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.kidsMngTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function teacherMngButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.teacherMngTestScene", "slideLeft", 300 ) 
    end
    return true
end

local function newsButtonEvent(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.newsTestScene", "slideLeft", 300 ) 
    end
    return true
end

function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    local btn_left_opt = {
        label = language["top"]["back"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onBackButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",
    }

    navBar = widget.newNavigationBar({
        title = "Test Main",
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
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
    
    local notice = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "notice",
        onRelease = noticeButtonEvent
    }
    notice.anchorY = 0
    notice.y = navBar.height + 20
    notice.x = 80
    group:insert(notice)
    
    local member = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "member",
        onRelease = memberButtonEvent
    }
    member.anchorY = 0
    member.y = notice.y
    member.x = notice.x + 150
    group:insert(member)

    local schedule = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "schedule",
        onRelease = scheduleButtonEvent
    }
    schedule.anchorY = 0
    schedule.y = notice.y + 40
    schedule.x = 80
    group:insert(schedule)
    
    local dailymenu = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "dailymenu",
        onRelease = dailymenuButtonEvent
    }
    dailymenu.anchorY = 0
    dailymenu.y = schedule.y
    dailymenu.x =  schedule.x + 150
    group:insert(dailymenu)
    
    local event = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "event",
        onRelease = eventButtonEvent
    }
    event.anchorY = 0
    event.y = schedule.y + 40
    event.x = 80
    group:insert(event)
    
    local mamatalk = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "mamatalk",
        onRelease = mamatalkButtonEvent
    }
    mamatalk.anchorY = 0
    mamatalk.y = event.y
    mamatalk.x = event.x + 150
    group:insert(mamatalk)
    
    local album = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "album",
        onRelease = albumButtonEvent
    }
    album.anchorY = 0
    album.y = event.y + 40
    album.x = 80
    group:insert(album)
    
    local contact = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "contact",
        onRelease = contactButtonEvent
    }
    contact.anchorY = 0
    contact.y = album.y
    contact.x = album.x + 150
    group:insert(contact)
    
    local kidsMng = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "Kids Manage",
        onRelease = kidsMngButtonEvent
    }
    kidsMng.anchorY = 0
    kidsMng.y = album.y + 40
    kidsMng.x = 80
    group:insert(kidsMng)
    
    local teacherMng = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "teacher Manage",
        onRelease = teacherMngButtonEvent
    }
    teacherMng.anchorY = 0
    teacherMng.y = kidsMng.y
    teacherMng.x = kidsMng.x + 150
    group:insert(teacherMng)
    
    local news = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "news",
        onRelease = newsButtonEvent
    }
    news.anchorY = 0
    news.y = kidsMng.y + 40
    news.x = 80
    group:insert(news)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
--    display:remove(group)
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
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

