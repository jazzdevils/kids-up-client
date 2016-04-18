require("widgets.widgetext")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local email, emailField, nameField
local navBar
local issuepw_button
local activityIndicator

local function onBackButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        storyboard.removeScene("scripts.loginScene")
        storyboard.gotoScene( "scripts.loginScene", "slideRight", 300)	
    end
    
    return true
end

local function issuepwCallback(event)
    issuepw_button:setEnabled(true)
    
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        activityIndicator:destroy()
        if(event.status == 200) then
            local data = json.decode(event.response)
            if (data) then
                if (data.status == "OK") then
                    local options =
                    {
                        effect = "slideLeft",
                        time = 300,
                        params =
                        {
                            email = emailField:getText()
                        }
                    }
                    storyboard.removeScene("scripts.issuePwResultScene")
                    storyboard.gotoScene( "scripts.issuePwResultScene", options)
                elseif(data.status == "-13") then
                    utils.showMessage( language["issuePwResultScene"]["notfoundemail"] )
                else
                    utils.showMessage( language["common"]["wrong_connection"] )
                end
            end
        else
            utils.showMessage( language["common"]["wrong_connection"] )
        end
    end
    
    return true
end

local function issuepwButtonEvent (event )
    native.setKeyboardFocus(nil)
    if event.phase == "ended" then
        local emailtxt = emailField:getText()
        local nametxt = nameField:getText()
        
        if emailtxt == "" then
            issuepw_button:setEnabled(true)
            utils.showMessage( language["loginScene"]["email_empty"] )
            return false
        end
        if utils.isEmailValidFormat(emailtxt) == false then
            issuepw_button:setEnabled(true)
            utils.showMessage( language["joinScene"]["email_format_error"] )
            return false
        end
        if nametxt == "" then
            issuepw_button:setEnabled(true)
            utils.showMessage( language["issuePwFormScene"]["name_empty"] )
            return false
        end
        if utils.isEmailValidFormat(emailtxt) == true then
            issuepw_button:setEnabled(false)
            
            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
            local params = {
                email = emailtxt,
                name = nametxt
            }
            api.req_issue_pw(params, issuepwCallback)	
        else
            utils.showMessage( language["joinScene"]["email_format_error"] )
        end
        
        return true
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    
    local params = event.params
    email = params.email

    local b = display.newRect(group, 0,0, __appContentWidth__, __appContentHeight__)
    b.anchorX, b.anchorY = 0,0
    b:setFillColor(0.9,0.9,0.9,1)
    b:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )
    
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
        title = language["issuePwFormScene"]["title_bar"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
    })
    
    group:insert(navBar)

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 250)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + 20
    
    emailField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["loginScene"]["email_textfield_hint"],
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
        inputType = "email",
        buttons = {
            {
                kind = "clear",
                defaultFile = "images/widgets/clear.png"
            }
        }
    }
    emailField.x = display.contentCenterX
    emailField.anchorY = 0
    emailField.y = bg_w.y + bg_w.height / 4 - (bg_w.height / 4) / 2
    group:insert(emailField)
    if email ~= nil then
        emailField:setText(email)
    end
    
    local emailLabelOptioins = {
        parent = group,
        text = language["loginScene"]["email_editbox"],
        fontSize = __textLabelFontSize__
    }
    local emailLabel = display.newText( emailLabelOptioins )
    emailLabel:setFillColor( 0,0,0 )
    emailLabel.anchorX = 0
    emailLabel.anchorY = 0
    emailLabel.x = emailField.x - emailField.width / 2
    emailLabel.y = emailField.y - emailLabel.height
    
    nameField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["issuePwFormScene"]["name_textfield_hint"],
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
    nameField.x = display.contentCenterX
    nameField.anchorY = 0
    nameField.y = bg_w.y + bg_w.height * 2 / 4 - (bg_w.height / 4) / 2
    group:insert(nameField)
    
    local nameLabelOptioins = {
        parent = group,
        text = language["issuePwFormScene"]["name_editbox"],
        fontSize = __textLabelFontSize__
    }
    local nameLabel = display.newText( nameLabelOptioins )
    nameLabel:setFillColor( 0,0,0 )
    nameLabel.anchorX = 0
    nameLabel.anchorY = 0
    nameLabel.x = nameField.x - nameField.width / 2
    nameLabel.y = nameField.y - nameLabel.height

    issuepw_button = widget.newButton
    {
        width = 200,
        height = 40,
        defaultFile = "images/button_inframe/btn_inframe_blue_2_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __textSubMenuFontSize__,
        label = language["issuePwFormScene"]["issuepw_button"],
        onRelease = issuepwButtonEvent
    }
    issuepw_button.x = display.contentCenterX
    issuepw_button.anchorY = 0
    issuepw_button.y = nameField.y + nameField.height + 30
    group:insert(issuepw_button)

    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height
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
    emailField:removeSelf()
    emailField = nil
    nameField:removeSelf()
    nameField = nil
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