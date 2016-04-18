require("widgets.widgetext")
require("widgets.widget_newNavBar")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local api = require("scripts.api")
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
require("widgets.activityIndicator")

local navBar
local classNameField, classDescField
local activityIndicator

local function callback( event )
    if ( event.isError ) then
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        if(event.status == 200) then
            local data = json.decode(event.response)
                
            if (data) then
                if(data.status == "OK") then
                    storyboard.purgeScene("scripts.mngClassListScene")
                    storyboard.gotoScene( "scripts.mngClassListScene", "slideRight", 300 )
                else
                    utils.showMessage( data.message )
                    return true
                end
            end
        end
    end
end

local function addClassInfo()
    local params = {
        center_id = user.userData.centerid,
        class_name = classNameField:getText(),
        class_desc = classDescField:getText()
    }
    api.post_class_info(params, callback)
end

local function onAddButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        if classNameField:getText() == "" then
            utils.showMessage( language["mngClassAddScene"]["class_name_input"] )
            return true
        end
        if classDescField:getText() == "" then
            utils.showMessage( language["mngClassAddScene"]["class_desc_input"] )
            return true
        end
        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
        addClassInfo()
    end
    
    return true
end

local function onBackButton(event)
    if event.phase == "ended" then
--        storyboard.purgeScene("scripts.mngClassListScene")
        storyboard.gotoScene( "scripts.mngClassListScene", "slideRight", 300 )
    end
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    bg:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )

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

    local btn_right_opt = {
        label = language["top"]["save"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onAddButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_ok_normal.png",
        overFile = "images/top_with_texts/btn_top_text_ok_touched.png",
    }

    navBar = widget.newNavigationBar({
        title = language["mngClassAddScene"]["title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })
    group:insert(navBar)

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x130.png", __appContentWidth__ - 40, 130)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + 20
    
    classNameField = widget.newEditField
    {
        width = bg_w.width * 0.9,
        editHintColor = {1,1,1,1},
        hint = language["mngClassAddScene"]["class_name_input"],
        editFont = native.systemFontBold,
        editFontSize = __textFieldFontSize__,
        editFontColor = {1,1,1,1},
        slideGroup = group,
        frame = {
            cornerRadius = 1,
            strokeWidth = 1,
            strokeColor = __EDITFIELD_FILL_COLOR__,
            fillColor = __EDITFIELD_FILL_COLOR__
          },
        required = true,
        errorFrame = {
           cornerRadius = 1
        },
        buttons = {
            {
                kind = "clear",
                defaultFile = "images/widgets/clear.png"
            }
        }
    }
    classNameField.anchorX = 0
    classNameField.anchorY = 0
    classNameField.x = (__appContentWidth__ - bg_w.width) * 0.5 + 10
    classNameField.y = bg_w.y + bg_w.height * 0.5 - 5 - classNameField.height
    group:insert(classNameField)
    
    local classNameLabel = display.newText(language["mngClassAddScene"]["class_name_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    classNameLabel.anchorX = 0
    classNameLabel.anchorY = 0
    classNameLabel.x = classNameField.x + 3
    classNameLabel.y = classNameField.y - classNameLabel.height + 5
    classNameLabel:setFillColor(0, 0, 0)
    group:insert(classNameLabel)
    
    classDescField = widget.newEditField
    {
        width = bg_w.width * 0.9,
        editHintColor = {1,1,1,1},
        hint = language["mngClassAddScene"]["class_desc_input"],
        editFont = native.systemFontBold,
        editFontSize = __textFieldFontSize__,
        editFontColor = {1,1,1,1},
        slideGroup = group,
        frame = {
            cornerRadius = 1,
            strokeWidth = 1,
            strokeColor = __EDITFIELD_FILL_COLOR__,
            fillColor = __EDITFIELD_FILL_COLOR__
          },
        required = true,
        errorFrame = {
           cornerRadius = 1
        },
        buttons = {
            {
                kind = "clear",
                defaultFile = "images/widgets/clear.png"
            }
        }
    }
    group:insert(classDescField)
    classDescField.anchorX = 0
    classDescField.anchorY = 0
    classDescField.x = classNameField.x
    classDescField.y = bg_w.y + bg_w.height - 5 - classDescField.height
    
    local classDescLabel = display.newText(language["mngClassAddScene"]["class_desc_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    classDescLabel.anchorX = 0
    classDescLabel.anchorY = 0
    classDescLabel.x = classDescField.x + 3
    classDescLabel.y = classDescField.y - classDescLabel.height + 5
    classDescLabel:setFillColor(0, 0, 0)
    group:insert(classDescLabel)

    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height
end

function scene:willEnterScene( event )
    local group = self.view
end

function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.mngClassListScene"
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    native.setKeyboardFocus( nil )
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    group:removeSelf()
    group = nil
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    print( "overlayBegan: " .. event.sceneName )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
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