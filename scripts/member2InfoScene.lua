require("widgets.widgetext")
require("widgets.widget_sharePanel")
require("widgets.activityIndicator")
require("widgets.widget_newNavBar")
require("scripts.user_dataDefine")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local api = require("scripts.api")
local utils = require("scripts.commonUtils")

local navBar
local memberType, memberTypeLabel, centerType, centerTypeLabel
local countryId, countryName, stateId, stateName, cityId, cityName, centerName, centerId, classId, className, invitationCode, invitationCodeInputResult
local classButton
local centerAddressRefData = {}
local memberName, email, pw, pwConfirm, phonenum
local memberNameField, emailField, pwField, pwConfirmField, phonenumField
local emailCheckFlag = false
local profileImg, sharePanel
local CURRENT_SCENE = storyboard.getCurrentSceneName()
local PROFILENAME = CURRENT_SCENE .. "_profileImage.JPG"
local PROFILE_IMG_EXIST = false
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90
local activityIndicator

local function onMemberProfileImageTap(event)
    native.setKeyboardFocus( nil )
    if(event.phase == "began") then
--        display.getCurrentStage():setFocus(object)
--        object.isFocus = true
    elseif(event.phase == "ended") then
        print("onMemberProfileImageTap(event)")
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
        else
            storyboard.state.PARAMS_NAME = {
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
                centerName = centerName,
                centerId = centerId,
                memberName = memberNameField:getText(),
                email = emailField:getText(),
                pw = pwField:getText(),
                pwConfirm = pwConfirmField:getText(),
                phonenum = phonenumField:getText(),
                classId = classId,
                className = className,
                invitationCode = invitationCode,
                invitationCodeInputResult = invitationCodeInputResult
            }
            if(sharePanel) then
                sharePanel:show()
                sharePanel.kidData = { profileImage = PROFILENAME }
                sharePanel.fromScene = CURRENT_SCENE
                sharePanel.imagePath = system.DocumentsDirectory
            else
                sharePanel = widget.newSharingPanel()
                sharePanel:show()
                sharePanel.kidData = { profileImage = PROFILENAME }
                sharePanel.fromScene = CURRENT_SCENE
                sharePanel.imagePath = system.DocumentsDirectory
            end
            sharePanel.isShowing = true
        end
    end
    
    return true
end

local function memberTypeInfoCallback( event )
    if ( event.isError ) then
        if (activityIndicator) then
            activityIndicator:destroy()
        end
        
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(activityIndicator) then
            activityIndicator:destroy()
        end
        
        if(event.status == 200) then
            local data = json.decode(event.response)
                
            if (data) then
                if(data.status == "OK") then
                    local options = {
                        effect = "slideLeft",
                        time = 300,
                        params = {
                            email = emailField:getText(),
                            pw = pwField:getText(),
                            memberType = __TEACHER__,
                            invitationCodeInputResult = invitationCodeInputResult,
                        }
                    }
                    storyboard.gotoScene( "scripts.joinCompleteScene", options )
                else
                    utils.showMessage( "NG" )
                    return true
                end
            end
        end
    end
end

local function regist()
    local function getClassIDs()
        local ids = ""
        local classes = centerAddressRefData.selectedTeacherClasses
        for i = 1, #classes do
            if i == #classes then
                ids = ids .. classes[i].id
            else
                ids = ids .. classes[i].id .. ","
            end
        end

        print(ids)
        return ids
    end
    
    local params = {
        member_type = memberType,
        center_type = centerType,
        country_id = countryId,
        state_id = stateId,
        city_id = cityId,
        member_name = memberNameField:getText(),
        email = emailField:getText(),
        pw = pwField:getText(),
        phonenum = phonenumField:getText(),
        filename = PROFILE_IMG_EXIST and storyboard.state.MEMBER_PROFILENAME or "",
        dir = PROFILE_IMG_EXIST and system.DocumentsDirectory or "",
        center_id = centerId,
        class_id = getClassIDs(),--classId == nil and 0 or classId,
        invitationCodeInputResult = invitationCodeInputResult
    }
    api.post_membertype2_info(params, memberTypeInfoCallback)
end

local function emailCheckCallback( event )    
    if ( event.isError ) then
        if (activityIndicator) then
            activityIndicator:destroy()
        end
        
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        if (activityIndicator) then
            activityIndicator:destroy()
        end
        
        if(event.status == 200) then
            local data = json.decode(event.response)
                
            if (data) then
                if(data.status == "OK") then
                    emailCheckFlag = true
                    regist()
                elseif (data.status == "-11") then
                    utils.showMessage(language["joinScene"]["email_format_error"])
                    return true
                elseif (data.status == "-7") then
                    utils.showMessage(language["joinScene"]["email_dup"])
                    return true
                else
                    utils.showMessage(data.message)
                    return true
                end
            end
        end
    end
end

local function onNextButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
            
            return true
        end
        if memberNameField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_memberName"])
            return true
        end
        if phonenumField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_phonenum"])
            return true
        end
        if tonumber(utils.trim(phonenumField:getText())) == nil then
            utils.showMessage(language["joinScene"]["phonenum_notnumber"])
            return true
        end
        if emailField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_email"])
            return true
        end
        if utils.isEmailValidFormat(emailField:getText()) == false then
            utils.showMessage( language["joinScene"]["email_format_error"] )
            return true
        end
        if pwField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_pw"])
            return true
        end
        if string.len(pwField:getText()) < 4 then
            utils.showMessage(language["joinScene"]["input_pw_morethan4"])
            return true
        end
        if pwConfirmField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_pw_confirm"])
            return true
        end
        if string.len(pwConfirmField:getText()) < 4 then
            utils.showMessage(language["joinScene"]["input_pw_confirm_morethan4"])
            return true
        end
        if pwField:getText() ~= pwConfirmField:getText() then
            utils.showMessage(language["joinScene"]["pw_confirm_not_equal"])
            return true
        end
--        if classId == nil then
--            utils.showMessage(language["joinScene"]["notselected_class"])
--            return true
--        end
        if centerAddressRefData.selectedTeacherClasses == nil or #centerAddressRefData.selectedTeacherClasses == 0 then
            utils.showMessage(language["joinScene"]["notselected_class"])
            return true
        end
--        
        if emailCheckFlag == false then
            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
            api.email_check(emailField:getText(), emailCheckCallback)
--            api.email_check("teafd111@gmail.com", emailCheckCallback) --테스트 코드
        end
    end
    
    return true
end

local function onBackButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
            
            return true
        end
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
                invitationCode = invitationCode
            }
        }
        storyboard.purgeScene("scripts.centerAddressScene")
        storyboard.gotoScene( "scripts.centerAddressScene", options ) 
    end
    
    return true
end

local function classButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        centerAddressRefData.centerId = centerId
        centerAddressRefData.showNoClassFlag = 0
        local options = {
            effect = "fade",
            time = 300,
            params = {
                centerAddressRefData = centerAddressRefData
            },
            isModal = true
        }
        storyboard.showOverlay( "scripts.classList4TeacherScene", options ) 
        return true
    end
    
    return true
end

-- Called when the scene's view does not exist:
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
        invitationCode = params.invitationCode
        invitationCodeInputResult = params.invitationCodeInputResult
    end
    
    print("*** invitationCodeInputResult:", invitationCodeInputResult)

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
        onEvent = onNextButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_next_normal.png",
        overFile = "images/top_with_texts/btn_top_text_next_touched.png",
    }

    navBar = widget.newNavigationBar({
        title = language["joinScene"]["memberInfo_input"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })
    group:insert(navBar)

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

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 342)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + progressFrame.height + 20
    
    if(utils.fileExist(storyboard.state.MEMBER_PROFILENAME, system.DocumentsDirectory) == true) then
        PROFILE_IMG_EXIST = true
        profileImg = display.newImageRect(group, storyboard.state.MEMBER_PROFILENAME, system.DocumentsDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    else
        local defaultImage = "images/main_menu_icons/pic_photo_80x80.png"
        profileImg = display.newImageRect(group, defaultImage, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    end

    profileImg.anchorX = 0
    profileImg.x = 30
    profileImg.anchorY = 0
    profileImg.y = bg_w.y + 20
    profileImg:addEventListener("touch", onMemberProfileImageTap)

    local profileImgFrame  = display.newImageRect(group, "images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 4, PROFILE_IMAGE_SIZE_HEIGHT + 4)
    profileImgFrame.anchorX = 0
    profileImgFrame.anchorY = 0
    profileImgFrame.x = profileImg.x - 1
    profileImgFrame.y = profileImg.y - 1

    local cameraIcon  = display.newImageRect(group, "images/assets1/icon_change_profile.png", 30, 30)
    cameraIcon.anchorX = 0
    cameraIcon.anchorY = 0
    cameraIcon.x = profileImg.x + profileImg.width - 15
    cameraIcon.y = profileImg.y - cameraIcon.height / 2
    cameraIcon:addEventListener("touch", onMemberProfileImageTap)
    
    memberNameField = widget.newEditField
    {
        width = bg_w.width * 0.5 + 20,
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
    --memberNameField:setText("小川　連子")
    memberNameField.anchorX = 0
    memberNameField.anchorY = 0
    memberNameField.x = profileImg.x + profileImg.width + 15
    memberNameField.y = bg_w.y + bg_w.height * 1 / 6 - 5 - memberNameField.height
    group:insert(memberNameField)
    
    local memberNameLabel = display.newText(language["joinScene"]["kid_name"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    memberNameLabel.anchorX = 0
    memberNameLabel.anchorY = 0
    memberNameLabel.x = memberNameField.x + 3
    memberNameLabel.y = memberNameField.y - memberNameLabel.height + 5
    memberNameLabel:setFillColor(0, 0, 0)
    group:insert(memberNameLabel)

    phonenumField = widget.newEditField
    {
        width = bg_w.width * 0.5 + 20,
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
    phonenumField.anchorX = 0
    phonenumField.anchorY = 0
    phonenumField.x = memberNameField.x
    phonenumField.y = bg_w.y + bg_w.height * 2 / 6 - 5 - phonenumField.height
    
    local phonenumLabel = display.newText(language["joinScene"]["phonenum_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    phonenumLabel.anchorX = 0
    phonenumLabel.anchorY = 0
    phonenumLabel.x = phonenumField.x + 3
    phonenumLabel.y = phonenumField.y - phonenumLabel.height + 5
    phonenumLabel:setFillColor(0, 0, 0)
    group:insert(phonenumLabel)

    emailField = widget.newEditField
    {
        width = bg_w.width * 0.9,
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
    --emailField:setText("teacher19@test.com")
    emailField.anchorX = 0
    emailField.anchorY = 0
    emailField.x = profileImg.x
    emailField.y = bg_w.y + bg_w.height * 3 / 6 - 5 - emailField.height
    group:insert(emailField)
    
    local emailLabel = display.newText(language["joinScene"]["email_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    emailLabel.anchorX = 0
    emailLabel.anchorY = 0
    emailLabel.x = emailField.x + 3
    emailLabel.y = emailField.y - emailLabel.height + 5
    emailLabel:setFillColor(0, 0, 0)
    group:insert(emailLabel)

    pwField = widget.newEditField
    {
        width = bg_w.width * 0.9,
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
    --pwField:setText("1234")
    pwField.anchorX = 0
    pwField.anchorY = 0
    pwField.x = profileImg.x
    pwField.y = bg_w.y + bg_w.height * 4 / 6 - 5 - pwField.height
    
    local pwLabel = display.newText(language["joinScene"]["password_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    pwLabel.anchorX = 0
    pwLabel.anchorY = 0
    pwLabel.x = pwField.x + 3
    pwLabel.y = pwField.y - pwLabel.height + 5
    pwLabel:setFillColor(0, 0, 0)
    group:insert(pwLabel)

    pwConfirmField = widget.newEditField
    {
        width = bg_w.width * 0.9,
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
    --pwConfirmField:setText("1234")
    pwConfirmField.anchorX = 0
    pwConfirmField.anchorY = 0
    pwConfirmField.x = profileImg.x
    pwConfirmField.y = bg_w.y + bg_w.height * 5 / 6 - 5 - pwConfirmField.height
    
    local pwConfirmLabel = display.newText(language["joinScene"]["password_coneditbox"], 0, 0, bg_w.width, 20, native.systemFont, 12)
    pwConfirmLabel.anchorX = 0
    pwConfirmLabel.anchorY = 0
    pwConfirmLabel.x = pwConfirmField.x + 3
    pwConfirmLabel.y = pwConfirmField.y - pwConfirmLabel.height + 5
    pwConfirmLabel:setFillColor(0, 0, 0)
    group:insert(pwConfirmLabel)
    
    classButton = widget.newButton {
        width = bg_w.width * 0.9,
        height = 30,
        defaultFile = "images/input/selectbox_full_width.png",
        overFile = "images/input/selectbox_full_width.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["class_select_txt"],
        onRelease = classButtonEvent
    }
    classButton.label_org = language["joinScene"]["class_select_txt"]
    classButton.anchorX = 0
    classButton.anchorY = 0
    classButton.x = profileImg.x
    classButton.y = bg_w.y + bg_w.height - 5 - classButton.height
    group:insert(classButton)
    
    local classLabel = display.newText(language["joinScene"]["kid_class"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    classLabel.anchorX = 0
    classLabel.anchorY = 0
    classLabel.x = classButton.x + 3
    classLabel.y = classButton.y - classLabel.height + 3
    classLabel:setFillColor(0, 0, 0)
    group:insert(classLabel)

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
    
--    if classId ~= nil then
--        if className ~= nil then
--            classButton:setLabel(className)
--        end
--    end
    
    if centerAddressRefData.selectedTeacherClasses ~= nil then
        if #centerAddressRefData.selectedTeacherClasses > 0 then
            if #centerAddressRefData.selectedTeacherClasses == 1 then
                local sClassLabel = centerAddressRefData.selectedTeacherClasses[1].name
                classButton:setLabel(sClassLabel)
            else
                -- sort id
                local function compare( a, b )
                    return a.id < b.id
                end
                table.sort( centerAddressRefData.selectedTeacherClasses, compare )
                
                local sClassLabel = centerAddressRefData.selectedTeacherClasses[1].name
                local iClassCount = #centerAddressRefData.selectedTeacherClasses
                classButton:setLabel(sClassLabel .. " + "..iClassCount-1)
            end
        else
            classButton:setLabel(language["joinScene"]["class_select_txt"])
        end
    else
        classButton:setLabel(language["joinScene"]["class_select_txt"])
    end
end

function scene:willEnterScene( event )
    local group = self.view
end

function scene:enterScene( event )
    local group = self.view

    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 4 / 5, 6, 3 )
    progress.anchorX = 0
    progress.anchorY = 0
    progress.x = display.contentWidth - __appContentWidth__
    progress.y = navBar.height
    progress:setFillColor( unpack(__PROGRESS_BAR_COLOR) )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if (sharePanel) then
        sharePanel.isShowing = false
        sharePanel:hide()
    end
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    profileImg:removeEventListener("touch", onMemberProfileImageTap)
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
--    if (centerAddressRefData.classId ~= nil) then
--        if (event.sceneName == "scripts.classListScene") then
--            classId = centerAddressRefData.classId
--            className = centerAddressRefData.className
--            if memberType == __TEACHER__ or memberType == __PARENT__ then
--                classButton:setLabel(className)
--            end
--        end
--    end
    if event.sceneName == "scripts.classList4TeacherScene" then
        if centerAddressRefData.selectedTeacherClasses ~= nil then
            if #centerAddressRefData.selectedTeacherClasses > 0 then
                if #centerAddressRefData.selectedTeacherClasses == 1 then
                    local sClassLabel = centerAddressRefData.selectedTeacherClasses[1].name
                    classButton:setLabel(sClassLabel)
                else
                    local function compare( a, b )
                        return a.id < b.id
                    end
                    table.sort( centerAddressRefData.selectedTeacherClasses, compare )
                    
                    local sClassLabel = centerAddressRefData.selectedTeacherClasses[1].name
                    local iClassCount = #centerAddressRefData.selectedTeacherClasses
                    classButton:setLabel(sClassLabel .. " +"..iClassCount-1)
                end
            else
                classButton:setLabel(language["joinScene"]["class_select_txt"])
            end
        else
            classButton:setLabel(language["joinScene"]["class_select_txt"])
        end
    end
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