require("widgets.widgetext")
require("widgets.widget_newNavBar")
require("widgets.widget_sharePanel")
require("widgets.activityIndicator")
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
local profileImg, sharePanel 
local kidName, kidBirth, kidSex, kidNameField, kidBirthField
local CURRENT_SCENE = storyboard.getCurrentSceneName()
local PROFILENAME = CURRENT_SCENE .. "_profileImage.JPG"
local PROFILE_IMG_EXIST = false
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90
local sexSegmentedControl
local activityIndicator
local pickerList

local function onMemberProfileImageTap(event)
    native.setKeyboardFocus( nil )
    if(event.phase == "began") then
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
                memberName = memberName,
                email = email,
                pw = pw,
                pwConfirm = pwConfirm,
                phonenum = phonenum,
                kidName = kidNameField:getText(),
                kidBirth = kidBirthField:getText(),
                kidSex = tostring(sexSegmentedControl.segmentNumber),
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
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
                
            if (data) then
                if(data.status == "OK") then
                    local options = {
                        effect = "slideLeft",
                        time = 300,
                        params = {
                            email = email,
                            pw = pw,
                            memberType = __PARENT__,
                            invitationCodeInputResult = invitationCodeInputResult,
                        }
                    }
                    storyboard.gotoScene( "scripts.joinCompleteScene", options )
                    activityIndicator:destroy()
                else
                    activityIndicator:destroy()
                    utils.showMessage( data.message )
                    return true
                end
            end
        end
    end
end

local function regist()
    local year, month, day = kidBirthField:getText():match("(%d+)%/(%d+)%/(%d+)");
    if tonumber(month) < 10 then
        month = "0"..month
    end
    if tonumber(day) < 10 then
        day  = "0"..day
    end
    local params = {
        member_type = memberType,
        center_type = centerType,
        country_id = countryId,
        state_id = stateId,
        city_id = cityId,
        member_name = memberName,
        email = email,
        pw = pw,
        phonenum = phonenum,
        center_id = centerId,
        filename = PROFILE_IMG_EXIST and storyboard.state.MEMBER_PROFILENAME or "",
        dir = PROFILE_IMG_EXIST and system.DocumentsDirectory or "",
        kid_name = kidNameField:getText(),
        kid_birth = year..month..day,
        kid_sex = tostring(sexSegmentedControl.segmentNumber),
        class_id = classId == nil and 0 or classId,
        invitationCodeInputResult = invitationCodeInputResult
    }
    api.post_membertype3_info(params, memberTypeInfoCallback)
end

local function onNextButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus( nil )
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
            
            return true
        end
         if kidNameField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_kidName"])
            return true
        end
        if kidBirthField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_kidBirthday"])
            return true
        end
        if classId == nil then
            utils.showMessage(language["joinScene"]["notselected_class"])
            return true
        end

        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
        regist()
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
                memberName = memberName,
                email = email,
                pw = pw,
                pwConfirm = pwConfirm,
                phonenum = phonenum,
                kidName = kidNameField:getText(),
                kidBirth = kidBirthField:getText(),
                kidSex = tostring(sexSegmentedControl.segmentNumber),
                classId = classId,
                className = className,
                invitationCode = invitationCode,
                invitationCodeInputResult = invitationCodeInputResult
            }
        }
        storyboard.purgeScene("scripts.member31InfoScene")
        storyboard.gotoScene( "scripts.member31InfoScene", options )
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
        storyboard.showOverlay( "scripts.classListScene", options ) 
        return true
    end
    
    return true
end

local function onBirthdayClick()
    local days = {}
    local years = {}
    
    -- Populate the "days" table
    for d = 1, 31 do
        days[d] = d..language["calendar"]["date"]
    end
    
    -- Populate the "years" table
    local currentYear = os.date( "%Y" )
    local startYear = currentYear - 100;
    for y = 1, 100 do
        years[y] = (startYear + y) ..language["calendar"]["year"]
    end
    
    local columnData = 
    {
        -- Years
        {
            align = "center",
            width = 100,
            startIndex = 10,
            labels = years
        },
        
        -- Months
        { 
            align = "right",
            width = 80,
            startIndex = 3,
            labels = language["calendar"]["month"]
        },
        
        -- Days
        {
            align = "right",
            width = 80,
            startIndex = 9,
            labels = days
        }
    }
    
    local function onScroll(event)
        local values = event.values
        local year  = tonumber(string.sub(values[1].value, 1, 4));
        local month = values[2].index;
        
        local a, b = string.find(values[3].value, language["calendar"]["date"])
        local day
        if a > 1 then
            day = tonumber(string.sub(values[3].value, 1, a-1))
        else
            day = values[3].value
        end
        
        local timestamp = os.time(
            {
                year = year, 
                month = month, 
                day = day
            }
        )
        if timestamp then
            kidBirthField:setText(string.format("%d/%d/%d", year, month, day));
        end
    end
    
    local function onClosePicker(event)
        kidBirthField:slideBackKeyboard()
    end
    
    local year, month, day = kidBirthField:getValue():match("(%d+)%/(%d+)%/(%d+)");
    if (month == nil) or (day == nil) or (year == nil) then
        local date = os.date( "*t" );
        year = date.year;
        month = date.month;
        day = date.day;
    end
    columnData[1].startIndex =  100 - (os.date( "%Y" ) - tonumber(year));
    columnData[2].startIndex = tonumber(month);
    columnData[3].startIndex = tonumber(day);
    
    pickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
            --editField = kidBirthField,
            titleText = language["kidInfoScene"]["input_date"],
            okButtonText = language["kidInfoScene"]["confirm"],
            pickerData = columnData,
            onScroll = onScroll,
            onClose = onClosePicker,
            onOKClick = function(event)
                kidBirthField:slideBackKeyboard()
            end
        }
    ) 
    kidBirthField:setText(string.format("%d/%d/%d", year,month,day))
   
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
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    bg:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )

    navBar = widget.newNavigationBar({
        title = language["joinScene"]["kid_info_input"],
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

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 250)
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
    profileImg.y = bg_w.y + 30
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
      
    kidNameField = widget.newEditField
    {
        width = bg_w.width * 0.5 + 20,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["kidsName_input"],
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
    kidNameField.anchorX = 0
    kidNameField.anchorY = 0
    kidNameField.x = profileImg.x + profileImg.width + 15
    kidNameField.y = bg_w.y + bg_w.height * 1 / 4 - 5 - kidNameField.height
    group:insert(kidNameField)
    --kidNameField:setText("木村　太郎")
    
    local kidNameLabel = display.newText(language["joinScene"]["name_editbox"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    kidNameLabel.anchorX = 0
    kidNameLabel.anchorY = 0
    kidNameLabel.x = kidNameField.x + 3
    kidNameLabel.y = kidNameField.y - kidNameLabel.height + 5
    kidNameLabel:setFillColor(0, 0, 0)
    group:insert(kidNameLabel)
    
    kidBirthField = widget.newEditField
    {
        width = bg_w.width * 0.5 + 20,
        label = language["joinScene"]["select_birthday"],
        labelColor = {1,1,1,1},
        editFont = native.systemFontBold,
        editFontSize = __textFieldFontSize__,
        editFontColor = {1,1,1,1},
        onClick = onBirthdayClick,
        align = "center",
        frame = {
            cornerRadius = 1,
            strokeWidth = 1,
            strokeColor = __EDITFIELD_FILL_COLOR__,
            fillColor = __EDITFIELD_FILL_COLOR__
          },
        required = true,
        errorFrame = {
           cornerRadius = 1
        }
    }
    kidBirthField.anchorX = 0
    kidBirthField.anchorY = 0
    kidBirthField.x = profileImg.x + profileImg.width + 15
    kidBirthField.y = bg_w.y + bg_w.height * 2 / 4 - 5 - kidBirthField.height + 3
    group:insert(kidBirthField)
    
    local kidBirthLabel = display.newText(language["joinScene"]["kid_birth"], 0, 0, bg_w.width * 0.2, 20, native.systemFont, 12)
    kidBirthLabel.anchorX = 0
    kidBirthLabel.anchorY = 0
    kidBirthLabel.x = kidBirthField.x + 3
    kidBirthLabel.y = kidBirthField.y - kidBirthLabel.height + 3
    kidBirthLabel:setFillColor(0, 0, 0)
    group:insert(kidBirthLabel)
    
    local function segmentedControlListener( event )
        local target = event.target
    end
    
    local defaultSegment --1: boy, 2:girl
    if(kidSex == "2") then
        defaultSegment = 2 --girl
    else
        defaultSegment = 1 --boy
    end
    sexSegmentedControl = widget.newSegmentedControl
    {
        segmentWidth = (bg_w.width * 0.5 + 20) * 0.5,
        segments = { language["joinScene"]["kid_sex1_label"], language["joinScene"]["kid_sex2_label"]},
        defaultSegment = defaultSegment,
        onPress = segmentedControlListener,
    }
    group:insert(sexSegmentedControl)
    sexSegmentedControl.anchorX = 0
    sexSegmentedControl.anchorY = 0
    sexSegmentedControl.x = profileImg.x + profileImg.width + 20
    sexSegmentedControl.y = bg_w.y + bg_w.height * 3 / 4 - 5 - sexSegmentedControl.height
    
    local kidSexLabel = display.newText(language["joinScene"]["kid_sex"], 0, 0, bg_w.width * 0.2, 20, native.systemFont, 12)
    kidSexLabel.anchorX = 0
    kidSexLabel.anchorY = 0
    kidSexLabel.x = sexSegmentedControl.x + 3
    kidSexLabel.y = sexSegmentedControl.y - kidSexLabel.height + 3
    kidSexLabel:setFillColor(0, 0, 0)
    group:insert(kidSexLabel)
    
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
    classButton.anchorX = 0
    classButton.anchorY = 0
    classButton.x = profileImg.x
    classButton.y = bg_w.y + bg_w.height - 5 - classButton.height
    classButton.label_org = language["joinScene"]["class_select_txt"]
    group:insert(classButton)
    
    local classLabel = display.newText(language["joinScene"]["kid_class"], 0, 0, bg_w.width * 0.2, 20, native.systemFont, 12)
    classLabel.anchorX = 0
    classLabel.anchorY = 0
    classLabel.x = classButton.x + 3
    classLabel.y = classButton.y - classLabel.height + 3
    classLabel:setFillColor(0, 0, 0)
    group:insert(classLabel)

    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height

    if kidName then
        kidNameField:setText(kidName)
    end

    if kidBirth then
        kidBirthField:setText(kidBirth)
    end

    if classId ~= nil then
        if className ~= nil then
            classButton:setLabel(className)
        end
    end
end

function scene:willEnterScene( event )
    local group = self.view
end

function scene:enterScene( event )
    local group = self.view

    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 5 / 6, 6, 3 )
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
    
    if(pickerList) then
        pickerList:closeUp()
        pickerList.isShowing = false
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
    if (centerAddressRefData.classId ~= nil) then
        if (event.sceneName == "scripts.classListScene") then
            classId = centerAddressRefData.classId
            className = centerAddressRefData.className
            if memberType == __TEACHER__ or memberType == __PARENT__ then
                classButton:setLabel(className)
            end
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