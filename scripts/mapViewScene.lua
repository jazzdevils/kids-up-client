---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("widgets.widget_newNavBar")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local sceneData = require("scripts.sceneData")
local user = require("scripts.user_data")
local language = getLanguage()
local utils = require("scripts.commonUtils")

local NAME_BAR_HEIGHT = 30
local myMap
local mapWidth
local mapHeight
local navBar
local nameRect
local views = {}
local previous_scene

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end
    
    return true
end

local function setMode( event )
    if event.phase == "ended" then
        for i = 1, #views do
            views[i]:setFillColor(1, 1, 0.75)
            views[i].label:setFillColor( 0.375, 0.375, 0.375 )
	end
        
        views[event.target.index]:setFillColor( 1, 1, 0.875 )
	views[event.target.index].label:setFillColor( 0.25, 0.25, 0.25 )
	myMap.mapType = event.target.mode
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    previous_scene = storyboard.getPrevious()
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mapViewScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }

    nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    local tag_Opt = {
        parent = group,
        text = user.getNameTagByAuthority(),
        x = display.contentCenterX,
        width = __appContentWidth__,
        y = __statusBarHeight__ + 68,
        font = native.systemFontBold,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    
    navBar = widget.newNavigationBar({
        title = language["mapViewScene"]["title"],
        --        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
--    native.setActivityIndicator( true )
    
--    mapWidth = display.contentWidth - 10
    mapWidth = __appContentWidth__
    mapHeight = __appContentHeight__ - 30 - navBar.height - nameRect.height
--    mapHeight = display.contentHeight - __statusBarHeight__ - 30 - navBar.height - nameRect.height

    local mapbox = display.newRect(0, 0, mapWidth, mapHeight)
    mapbox.x = display.contentCenterX
    mapbox.y = mapHeight / 2 + navBar.height + nameRect.height -- (address field height)
    mapbox:setFillColor( 0.5, 0.5, 0.5 )
    group:insert(mapbox)

    local tabWidth = mapWidth / 3
    views[1] = display.newRect(0,0,tabWidth,30)
    views[1].x = display.contentCenterX - tabWidth
    views[1].y = mapbox.y + (mapbox.height / 2) + 14
    views[1]:setFillColor( 1, 1, 0.875)
    views[1]:setStrokeColor( 0.875, 0.875, 0.75)
    views[1].strokeWidth = 1
    views[1].label = display.newText(language["mapViewScene"]["standard"],0,0, native.systemFont, 12 )
    views[1].label.x = views[1].x
    views[1].label.y = views[1].y - 3
    views[1].label:setFillColor( 0.25, 0.25, 0.25 )
    views[1].index = 1
    views[1].mode = "standard"
    group:insert(views[1])
    group:insert(views[1].label)
	
    views[2] = display.newRect(0,0,tabWidth,30)
    views[2].x = display.contentCenterX 
    views[2].y = mapbox.y + (mapbox.height / 2) + 14
    views[2]:setFillColor( 1, 1, 0.75 )
    views[2]:setStrokeColor(0.875, 0.875, 0.75 )
    views[2].strokeWidth = 1
    views[2].label = display.newText(language["mapViewScene"]["satellite"],0,0,native.systemFont, 12 )
    views[2].label.x = views[2].x
    views[2].label.y = views[2].y - 3
    views[2].label:setFillColor( 0.375, 0.375, 0.375 )
    views[2].index = 2
    views[2].mode = "satellite"
    group:insert(views[2])
    group:insert(views[2].label)

    views[3] = display.newRect(0,0,tabWidth,30)
    views[3].x = display.contentCenterX + tabWidth
    views[3].y = mapbox.y + (mapbox.height / 2) + 14
    views[3]:setFillColor( 1, 1, 0.75)
    views[3]:setStrokeColor( 0.875, 0.875, 0.75 )
    views[3].strokeWidth = 1
    views[3].label = display.newText(language["mapViewScene"]["hybrid"],0,0,native.systemFont, 12 )
    views[3].label.x = views[3].x
    views[3].label.y = views[3].y - 3
    views[3].label:setFillColor( 0.375, 0.375, 0.375)
    views[3].index = 3
    views[3].mode = "hybrid"
    group:insert(views[3])
    group:insert(views[3].label)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

local function markerListener( event )
    print("type: ", event.type) -- event type
    print("markerId: ", event.markerId) -- id of the marker that was touched
    print("lat: ", event.latitude) -- latitude of the marker
    print("long: ", event.longitude) -- longitude of the marker
end

local function mapLocationHandler(event)
    print("map tapped latitude: ", event.latitude)
    print("map tapped longitude: ", event.longitude)
    if(event.latitude and event.longitude) then
        myMap:setCenter( event.latitude, event.longitude, false )
        myMap:setRegion( event.latitude, event.longitude, 0.01, 0.01, false)

        local options = { 
            title = sceneData.getSceneDataWithUID("mapAddress"), 
--            subtitle = sceneData.getSceneDataWithUID("mapAddress"), 
            listener=markerListener 
        }

        local result, errorMessage = myMap:addMarker( event.latitude, event.longitude, options )
        if result then
            print("everything went well")
        else
            print(errorMessage)
        end
    else
        utils.showMessage(language["mapViewScene"]["notfind_address"])
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.returnTo = previous_scene
    storyboard.isAction = false
    
    local address = sceneData.getSceneDataWithUID("mapAddress")
    
    myMap = native.newMapView( 0, 0, mapWidth , mapHeight ) 
    myMap.mapType = "standard" -- other mapType options are "satellite" or "hybrid"
    myMap.x = display.contentCenterX
    myMap.y = mapHeight / 2 + navBar.height + nameRect.height -- (address field height)
--    		for i = 1, #starbucksLocations do
--			myMap:requestLocation(starbucksLocations[i], function(event) addStarbucks(event, i); end)
--		end

    myMap:requestLocation( address, mapLocationHandler )
    views[1]:addEventListener("touch", setMode)
    views[2]:addEventListener("touch", setMode)
    views[3]:addEventListener("touch", setMode)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if myMap and myMap.removeSelf then
        myMap:removeSelf()
	myMap = nil
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





