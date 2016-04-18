require("widgets.widgetext")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
require("widgets.widget_newNavBar")
local access = require("scripts.accessScene")
local user = require("scripts.user_data")
require("widgets.activityIndicator")
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local emailField, passwordField
local navBar
local login_button, checkboxButton
local activityIndicator

local function onBackButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
--        storyboard.purgeScene("scripts.top")
        storyboard.removeScene("scripts.top")
        storyboard.gotoScene( "scripts.top", "slideRight", 300)	
    end
    
    return true
end

local function loginCallback(event)
    login_button:setEnabled(true)
    
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            if (data) then
                if (data.status == "OK") then
                    local loginJson = {}
                    if checkboxButton.isOn then
                        loginJson.logined = "1"
                    end
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    loginJson.member = {}
                    loginJson.member.id = data.member.id
                    loginJson.member.centerId = data.member.center_id
                    loginJson.member.centerName = data.member.center_name
                    loginJson.member.type = data.member.type
                    loginJson.member.subtype = data.member.subtype
                    loginJson.member.name = data.member.name
                    loginJson.member.phonenum = data.member.phonenum
                    loginJson.member.img = data.member.img
                    loginJson.member.profileImage = profileImage
                    loginJson.member.approvalState = data.member.approval_state
                    loginJson.member.classId = data.member.class_id
                    loginJson.member.className = data.member.class_name
                    if(data.member.img ~= "") then
                        if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                            network.download(
                                data.member.img,
                                "GET",
                                function() end,
                                profileImage,
                                system.DocumentsDirectory
                            )
                        end
                    end
                    if utils.setAppInitPropertyData(loginJson) then
                        activityIndicator:destroy()
                        if loginJson.member.type == __PARENT__ then
                            access:getKidsInfo(data.member.id)
                        else
                            access:gotoMngHomeSceneFromLogin(data)
                        end
                    else
                        activityIndicator:destroy()
                        utils.showMessage( language["loginScene"]["login_error"] )
                    end
                elseif (data.status == "-11") then
                    activityIndicator:destroy()
                    utils.showMessage( language["joinScene"]["email_format_error"] )
                    return true
                else
                    activityIndicator:destroy()
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage( language["loginScene"]["wrong_login"] )
                end
            end
        end
    end
    
    return true
end

local function loginButtonEvent( event )
    native.setKeyboardFocus(nil)
    if event.phase == "ended" then
        local emailtxt = emailField:getText()
        local pwdtxt = passwordField:getText()
        
        if emailtxt == "" then
            login_button:setEnabled(true)
            utils.showMessage( language["loginScene"]["email_empty"] )
            return false
        end
        if utils.isEmailValidFormat(emailtxt) == false then
            login_button:setEnabled(true)
            utils.showMessage( language["joinScene"]["email_format_error"] )
            return false
        end
        if pwdtxt == "" then
            login_button:setEnabled(true)
            utils.showMessage( language["loginScene"]["password_empty"] )
            return false
        end
        if utils.isEmailValidFormat(emailtxt) == true then
            login_button:setEnabled(false)
            
            activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
            api.login_api(emailtxt, pwdtxt, loginCallback)
        else
            utils.showMessage( language["joinScene"]["email_format_error"] )
        end
        
        return true
    end
    
    return true
end

local function lostPasswordListener(event)
    if event.phase == "ended" then
        local options =
        {
            effect = "slideLeft",
            time = 300,
            params =
            {
                email = emailField:getText()
            }
        }
        storyboard.purgeScene("scripts.issuePwFormScene")
        storyboard.gotoScene( "scripts.issuePwFormScene", options )
    end
end

local function onSwitchPress( event )
    local switch = event.target
end

local function autoLoginTxtListener( event )
    if event.phase == "ended" then
        if checkboxButton.isOn then
            checkboxButton:setState({isOn = false})
        else
            checkboxButton:setState({isOn = true})
        end
    end
end

function scene:createScene( event )
    local group = self.view

    local b = display.newRect(group, 0,0, __backgroundWidth__, __backgroundHeight__ )
    b.anchorX, b.anchorY = 0,0
    b:setFillColor(0.9,0.9,0.9,1)
    b:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__ )
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
        title = language["loginScene"]["title_bar"],
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
--        height = 32,
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
    print(emailField.height)
--    emailField:setText("jun@0-start.jp")
--    emailField:setText("encho11@test.com") 
--    emailField:setText("jazzdevils@gmail.com")
--    emailField:setText("arilang123@naver.com")
--    emailField:setText("sakura@test.com")
--    emailField:setText("teacher7@test.com")--teacher
--    emailField:setText("hoshinohoikuen@yahoo.co.jp")--director
    
--    emailField:setText("encho13@test.com") -- / 1234 인증없는 원장
--    emailField:setText("teacher30@test.com") -- / 1234 인증없는 교사
--    emailField:setText("mother86@test.com") --  / 1234 인증없는 학부모
    
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
    
    passwordField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["loginScene"]["password_textfield_hint"],
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
    passwordField.isSecure = true
    passwordField.x = display.contentCenterX
    passwordField.anchorY = 0
    passwordField.y = bg_w.y + bg_w.height * 2 / 4 - (bg_w.height / 4) / 2
    group:insert(passwordField)
    --
--    emailField:setText("mother55@test.com")
--    passwordField:setText("kanta1127")
--    passwordField:setText("1234")
--    passwordField:setText("1974424")
    
    local passwordLabelOptioins = {
        parent = group,
        text = language["loginScene"]["password_editbox"],
        fontSize = __textLabelFontSize__
    }
    local passwordLabel = display.newText( passwordLabelOptioins )
    passwordLabel:setFillColor( 0,0,0 )
    passwordLabel.anchorX = 0
    passwordLabel.anchorY = 0
    passwordLabel.x = passwordField.x - passwordField.width / 2
    passwordLabel.y = passwordField.y - passwordLabel.height
    
    checkboxButton = widget.newSwitch
    {
        style = "checkbox",
        initialSwitchState = false,
        onPress = onSwitchPress
    }
    checkboxButton.anchorX = 0
    checkboxButton.anchorY = 0
    checkboxButton.x = 20 + checkboxButton.width / 2
    checkboxButton.y = bg_w.y + bg_w.height * 3 / 4 - (bg_w.height / 4) / 2
    group:insert(checkboxButton)
    
    local txtOptions = {
        parent = group,
        text = language["loginScene"]["auto_login"],
        fontSize = __textLabelFontSize__
    }
    local autoLoginTxt = display.newText( txtOptions )
    autoLoginTxt:setFillColor( 0,0,0 )
    autoLoginTxt.anchorX = 0
    autoLoginTxt.anchorY = 0
    autoLoginTxt.x = checkboxButton.x + checkboxButton.width + 5
    autoLoginTxt.y = checkboxButton.y + checkboxButton.height / 5
    autoLoginTxt:addEventListener("touch", autoLoginTxtListener)

    login_button = widget.newButton
    {
        width = 100 ,
        height = 40 ,
        defaultFile = "images/button/btn_red_1_normal.png",
        overFile = "images/button/btn_red_1_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __textSubMenuFontSize__,
        label = language["main"]["login_button"],
        onRelease = loginButtonEvent
    }
    login_button.anchorX = 0
    login_button.anchorY = 0
    login_button.x = autoLoginTxt.x + autoLoginTxt.width + 20
    login_button.y = checkboxButton.y - checkboxButton.height / 5
    group:insert(login_button)
    
    txtOptions = {
        parent = group,
        text = language["loginScene"]["lost_password"],
        fontSize = __textLabelFontSize__
    }
    local lostPasswordTxt = display.newText( txtOptions )
    lostPasswordTxt:setFillColor( 0,0,1 )
    lostPasswordTxt.anchorY = 0
    lostPasswordTxt.x = display.contentCenterX
    lostPasswordTxt.y = bg_w.y + bg_w.height - (bg_w.height / 4) / 2
    lostPasswordTxt:addEventListener("touch", lostPasswordListener)
    
    local x1 = lostPasswordTxt.x - lostPasswordTxt.width / 2
    local y1 = lostPasswordTxt.y + lostPasswordTxt.height
    local x2 = lostPasswordTxt.x + lostPasswordTxt.width / 2
    local y2 = lostPasswordTxt.y + lostPasswordTxt.height
    local underline = display.newLine(x1, y1, x2, y2)
    underline:setStrokeColor( 0,0,1 )
    group:insert(underline)

    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __backgroundWidth__, 30)
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
    passwordField:removeSelf()
    passwordField = nil
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