---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------

require("scripts.commonSettings")
require("widgets.widget_newNavBar")

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local user = require("scripts.user_data")
local api = require("scripts.api")
local utils = require("scripts.commonUtils")
local language = getLanguage()

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local comment_textBox_height = 100

local previous_scene 

local comment_textBox
local content_id
local comment_type
local contentData

local activityIndicator

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onComplete( event )
    if "clicked" == event.action then
        local i = event.index
        if i == 1 then
            native.setKeyboardFocus(nil)
            if(previous_scene) then
                storyboard.gotoScene(previous_scene, "fromTop", 300)
                
--                return true
            end
        elseif i == 2 then
                            
        end
    end
end

local function goBackScene(needRefresh)
    local params = {
        rowData = contentData
    }
    local options = {
        effect = "fromTop",
        time = 300,
        params = params
    }
    if(needRefresh and needRefresh == true) then
        contentData.needRefresh = true
        storyboard.purgeScene(previous_scene)
    end
    storyboard.gotoScene(previous_scene, options)
end

local function onLeftButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        if(previous_scene) then
--            storyboard.gotoScene(previous_scene, "fromTop", 300)
            goBackScene(false)
--            storyboard.gotoScene(previous_scene)
        end
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        if(comment_textBox) then
            if(comment_textBox.text ~= "") then
                native.setKeyboardFocus(nil)
                
                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                if (comment_type == "notice") then
                    api.post_notice_reply2(content_id, user.userData.id, user.getActiveKid_IDByAuthority(), comment_textBox.text, 
                        function(event)  
                            if(previous_scene) then
                                activityIndicator:destroy()
                                goBackScene(true)
                            end
                        end
                    )
                elseif(comment_type == "event") then
                    api.post_event_reply2(content_id, user.userData.id, user.getActiveKid_IDByAuthority(), comment_textBox.text, 
                        function(event)  
                            if(previous_scene) then
                                activityIndicator:destroy()
                                goBackScene(true)
                            end
                        end
                    )     
                elseif(comment_type == "mamatalk") then
                    api.post_mamatalk_reply2(content_id, user.userData.id, user.getActiveKid_IDByAuthority(), comment_textBox.text, 
                        function(event)  
                            if(previous_scene) then
                                activityIndicator:destroy()
                                goBackScene(true)
                            end
                        end
                    )
                elseif(comment_type == "message") then
                    api.post_contact_reply2(content_id, user.userData.id, user.getActiveKid_IDByAuthority(), comment_textBox.text, 
                        function(event)  
                            if(previous_scene) then
                                activityIndicator:destroy()
                                goBackScene(true)
                            end
                        end
                    )    
                end
                    
            end
        end
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    previous_scene = storyboard.getPrevious()
    
    comment_type = event.params.comment_type
    contentData = event.params.rowData
    content_id = event.params.rowData.id
    
    local bg = display.newImageRect(group, "images/bg_set/background.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["commentScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png", 
    }
    
    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["commentScene"]["save"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
    }
    local navBar = widget.newNavigationBar({
        title = language["commentScene"]["title"],
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
    
    local nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    local tag_Opt = {
        parent = group,
        text = user.getNameTagByAuthority(),
        x = display.contentCenterX,
        width = __appContentWidth__,
        y = __statusBarHeight__ + 68,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    
    local comment_box = display.newRect(group, display.contentCenterX, 
                __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT,
                __appContentWidth__, 
                __appContentHeight__ - __statusBarHeight__ - nameRect.height - 50)
    comment_box.anchorY = 0
    comment_box.strokeWidth = 1
    comment_box:setStrokeColor(0, 0, 0)
    comment_box.y = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT
    
    group:insert(comment_box)
 end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.returnTo = previous_scene
    
    print("comment_type : "..comment_type)
    print("content_id : "..content_id)
    
    local function inputListener( event )
        if event.phase == "began" then
            print( event.text )
            comment_textBox.text = ""
            print( event.startPosition )
        elseif event.phase == "ended" then
            native.setKeyboardFocus(nil)
        elseif event.phase == "editing" then
--            print( event.newCharacters )
--            print( event.oldText )
            print( event.startPosition )
            print( event.text )
        end
    end
    
    
    comment_textBox = native.newTextBox(display.contentCenterX, 
            comment_textBox_height/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT,
            __appContentWidth__, 
            comment_textBox_height )
    print((__appContentHeight__ -__statusBarHeight__- NAVI_BAR_HEIGHT - NAME_BAR_HEIGHT - 150)/2)        
    comment_textBox.text = ""
    comment_textBox.isEditable = true
    comment_textBox.placeholder = language["commentScene"]["input_comment"]
    comment_textBox.strokeWidth = 0
    comment_textBox.hasBackground = false
    comment_textBox:addEventListener( "userInput", inputListener )
    comment_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    native.setKeyboardFocus(comment_textBox)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if(comment_textBox) then
        comment_textBox:removeSelf()
        comment_textBox = nil
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

