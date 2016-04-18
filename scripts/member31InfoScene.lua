require("widgets.widgetext")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
require("widgets.widget_newNavBar")
local api = require("scripts.api")
local utils = require("scripts.commonUtils")
require("widgets.activityIndicator")

local navBar
local memberType, memberTypeLabel, centerType, centerTypeLabel
local countryId, countryName, stateId, stateName, cityId, cityName, centerName, centerId, classId, className, invitationCode, invitationCodeInputResult
local centerAddressRefData = {}
local memberName, email, pw, pwConfirm, phonenum
local memberNameField, emailField, pwField, pwConfirmField, phonenumField
local kidName, kidBirth, kidSex
local activityIndicator

local function emailCheckCallback( event )
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            if(activityIndicator) then
                activityIndicator:destroy()
            end
                
            if (data) then
                if(data.status == "OK") then
                    local options = {
                        effect = "slideLeft",
                        time = 300,
                        params = {
                            memberType = memberType,
                            memberTypeLabel = memberTypeLabel,
                            centerType = centerType,
                            centerTypeLabel = centerTypeLabel,
                            countryId = countryId,
                            countryName = countryName,
                            stateId = stateId,
                            stateName = stateName,
                            cityId = cityId,
                            cityName = cityName,
                            memberName = memberNameField:getText(),
                            email = emailField:getText(),
                            pw = pwField:getText(),
                            pwConfirm = pwConfirmField:getText(),
                            phonenum = phonenumField:getText(),
                            centerId = centerId,
                            centerName = centerName,
                            classId = classId,
                            className = className,
                            kidName = kidName,
                            kidBirth = kidBirth,
                            kidSex = kidSex,
                            invitationCode = invitationCode,
                            invitationCodeInputResult = invitationCodeInputResult
                        }
                    }
                    storyboard.purgeScene("scripts.member32InfoScene")
                    storyboard.gotoScene( "scripts.member32InfoScene", options )
                elseif (data.status == "-11") then
                    utils.showMessage( language["joinScene"]["email_format_error"] )
                    return true
                elseif (data.status == "-7") then
                    utils.showMessage( language["joinScene"]["email_dup"] )
                    return true
                else
                    utils.showMessage( data.message )
                    return true
                end
            end
        end
    end
end

local function onNextButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        if memberNameField:getText() == "" then
            utils.showMessage( language["joinScene"]["notinput_memberName"] )
            return true
        end
        if emailField:getText() == "" then
            utils.showMessage( language["joinScene"]["notinput_email"] )
            return true
        end
        if utils.isEmailValidFormat(emailField:getText()) == false then
            utils.showMessage( language["joinScene"]["email_format_error"] )
            return true
        end
        if pwField:getText() == "" then
            utils.showMessage( language["joinScene"]["notinput_pw"] )
            return true
        end
        if string.len(pwField:getText()) < 4 then
            utils.showMessage( language["joinScene"]["input_pw_morethan4"] )
            return true
        end
        if pwConfirmField:getText() == "" then
            utils.showMessage( language["joinScene"]["notinput_pw_confirm"] )
            return true
        end
        if string.len(pwConfirmField:getText()) < 4 then
            utils.showMessage( language["joinScene"]["input_pw_confirm_morethan4"] )
            return true
        end
        if pwField:getText() ~= pwConfirmField:getText() then
            utils.showMessage( language["joinScene"]["pw_confirm_not_equal"] )
            return true
        end
        if phonenumField:getText() == "" then
            utils.showMessage( language["joinScene"]["notinput_phonenum"] )
            return true
        end
        if tonumber(utils.trim(phonenumField:getText())) == nil then
            utils.showMessage( language["joinScene"]["phonenum_notnumber"] )
            return true
        end
        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
        api.email_check(emailField:getText(), emailCheckCallback)
    end
    
    return true
end

local function onBackButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        local options =
        {
            effect = "slideRight",
            time = 300,
            params =
            {
                memberType = memberType,
                memberTypeLabel = memberTypeLabel,
                centerType = centerType,
                centerTypeLabel = centerTypeLabel,
                countryId = countryId,
                countryName = countryName,
                stateId = stateId,
                stateName = stateName,
                cityId = cityId,
                cityName = cityName,
                centerId = centerId,
                centerName = centerName,
                memberName = memberNameField:getText(),
                email = emailField:getText(),
                pw = pwField:getText(),
                pwConfirm = pwConfirmField:getText(),
                phonenum = phonenumField:getText(),
                classId = classId,
                className = className,
                kidName = kidName,
                kidBirth = kidBirth,
                kidSex = kidSex,
                invitationCode = invitationCode
            }
        }
        storyboard.purgeScene("scripts.centerAddressScene")
        storyboard.gotoScene( "scripts.centerAddressScene", options )
    end
    
    return true
end

local function categoryFalseEvent( event )
    native.setKeyboardFocus( nil )
end

function scene:createScene( event )
    local group = self.view    
    local params = event.params
    if params == nil then
        params = storyboard.state.PARAMS_NAME
    end
    if params then
        memberType = params.memberType
        memberTypeLabel = params.memberTypeLabel
        centerType = params.centerType
        centerTypeLabel = params.centerTypeLabel
        countryId = params.countryId
        countryName = params.countryName
        stateId = params.stateId
        stateName = params.stateName
        cityId = params.cityId
        cityName = params.cityName
        centerId = params.centerId
        centerName = params.centerName
        memberName = params.memberName
        email = params.email
        pw = params.pw
        pwConfirm = params.pwConfirm
        phonenum = params.phonenum
        classId = params.classId
        className = params.className
        kidName = params.kidName
        kidBirth = params.kidBirth
        kidSex = params.kidSex
        invitationCode = params.invitationCode
        invitationCodeInputResult = params.invitationCodeInputResult
    end

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
        label = language["top"]["next"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onNextButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_next_normal.png",
        overFile = "images/top_with_texts/btn_top_text_next_touched.png",
    }
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    bg:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )

    navBar = widget.newNavigationBar({
        title = language["joinScene"]["parent_info_input"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })
    group:insert(navBar)
    navBar:addEventListener( "touch", categoryFalseEvent )

    local progressFrame = display.newRect( group, display.contentCenterX, navBar.height + 3, __appContentWidth__, 6 )
    progressFrame.strokeWidth = 0
    progressFrame:setFillColor( 0, 0, 0 )
    
    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 312)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + progressFrame.height + 20

    memberNameField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = string.gsub(language["joinScene"]["memberName_input"], "_NAME_", memberTypeLabel),
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
    --memberNameField:setText("黒木　メイサ")
    memberNameField.x = display.contentCenterX
    memberNameField.anchorY = 0
    memberNameField.y = bg_w.y + bg_w.height * 0.2 - 5 - memberNameField.height
    group:insert(memberNameField)
    
    local memberNameLabel = display.newText(language["joinScene"]["name_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    memberNameLabel.anchorX = 0
    memberNameLabel.anchorY = 0
    memberNameLabel.x = bg_w.x - bg_w.width * 0.5 + 20
    memberNameLabel.y = memberNameField.y - memberNameLabel.height
    memberNameLabel:setFillColor(0, 0, 0)
    group:insert(memberNameLabel)

    emailField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["email_input"],
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
    --emailField:setText("mother1240@test.com")
    emailField.x = display.contentCenterX
    emailField.anchorY = 0
    emailField.y = bg_w.y + bg_w.height * 0.4 - 5 - emailField.height
    group:insert(emailField)
    
    local emailLabel = display.newText(language["joinScene"]["email_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    emailLabel.anchorX = 0
    emailLabel.anchorY = 0
    emailLabel.x = bg_w.x - bg_w.width * 0.5 + 20
    emailLabel.y = emailField.y - emailLabel.height
    emailLabel:setFillColor(0, 0, 0)
    group:insert(emailLabel)

    pwField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["pw_input"],
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
    pwField.isSecure = true
    group:insert(pwField)
    --pwField:setText("1111")
    pwField.anchorY = 0
    pwField.y = bg_w.y + bg_w.height * 0.6 - 5 - pwField.height
    pwField.x = display.contentCenterX
    
    local pwLabel = display.newText(language["joinScene"]["password_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    pwLabel.anchorX = 0
    pwLabel.anchorY = 0
    pwLabel.x = bg_w.x - bg_w.width * 0.5 + 20
    pwLabel.y = pwField.y - pwLabel.height
    pwLabel:setFillColor(0, 0, 0)
    group:insert(pwLabel)

    pwConfirmField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["pwConfirm_input"],
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
    pwConfirmField.isSecure = true
    group:insert(pwConfirmField)
    --pwConfirmField:setText("1111")
    pwConfirmField.x = display.contentCenterX
    pwConfirmField.anchorY = 0
    pwConfirmField.y = bg_w.y + bg_w.height * 0.8 - 5 - pwConfirmField.height
    
    local pwConfrimLabel = display.newText(language["joinScene"]["password_coneditbox"], 0, 0, bg_w.width, 20, native.systemFont, 12)
    pwConfrimLabel.anchorX = 0
    pwConfrimLabel.anchorY = 0
    pwConfrimLabel.x = bg_w.x - bg_w.width * 0.5 + 20
    pwConfrimLabel.y = pwConfirmField.y - pwConfrimLabel.height
    pwConfrimLabel:setFillColor(0, 0, 0)
    group:insert(pwConfrimLabel)

    phonenumField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["phonenum_input"],
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
        inputType = "phone",
        buttons = {
            {
                kind = "clear",
                defaultFile = "images/widgets/clear.png"
            }
        }
    }
    group:insert(phonenumField)
    --phonenumField:setText("010-1111-2222")
    phonenumField.x = display.contentCenterX
    phonenumField.anchorY = 0
    phonenumField.y = bg_w.y + bg_w.height - 5 - phonenumField.height
    
    local phonenumLabel = display.newText(language["joinScene"]["phonenum_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    phonenumLabel.anchorX = 0
    phonenumLabel.anchorY = 0
    phonenumLabel.x = bg_w.x - bg_w.width * 0.5 + 20
    phonenumLabel.y = phonenumField.y - phonenumLabel.height
    phonenumLabel:setFillColor(0, 0, 0)
    group:insert(phonenumLabel)

    if memberName then
        memberNameField:setText(memberName)
    end
    if email then
        emailField:setText(email)
    end
    if pw then
        pwField:setText(pw)
    end
    if pwConfirm then
        pwConfirmField:setText(pwConfirm)
    end
    if phonenum then
        phonenumField:setText(phonenum)
    end
end

function scene:willEnterScene( event )
    local group = self.view
end

function scene:enterScene( event )
    local group = self.view

    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 4 / 6, 6, 3 )
    progress.anchorX = 0
    progress.anchorY = 0
    progress.x = display.contentWidth - __appContentWidth__
    progress.y = navBar.height
    progress:setFillColor( unpack(__PROGRESS_BAR_COLOR) )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
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
    print( "overlayEnded: " .. event.sceneName ) 
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