---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.widget_sharePanel")
require("widgets.widgetext")
require("widgets.activityIndicator")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
local access = require("scripts.accessScene")

local ROW_HEIGHT = 170
local CATEGORY_ROW_HEIGHT = 40
local NAVI_BAR_HEIGHT = 50
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90
local kidInfoTable
local sharePanel
local centerTypeButton, countryButton, stateButton, cityButton, centerButton, classButton
local centerAddressRefData = {}
local centerAddressTitle
local kidName, kidBirth, kidSexValue, kidSexSegmentControl
local kidNameField, kidBirthField
local PROFILE_IMG_EXIST = false
local centerType, countryId, stateId, cityId, centerId, classId
local centerTypeName, countryName, stateName, cityName, centerName, className
local centerType2, countryId2, stateId2, cityId2, centerId2, classId2
local CURRENT_SCENE = storyboard.getCurrentSceneName()
local PROFILENAME = CURRENT_SCENE .."_"..tostring(#user.kidsList).."_profileImage.JPG"
local activityIndicator
local pickerList

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onKidProfileImageTap(event)
    native.setKeyboardFocus(nil)
    
    local object = event.target
    if(event.phase == "began") then
        --print("onKidProfileImageTap began")
    elseif(event.phase == "ended") then
        --print("onKidProfileImageTap(event)")
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
        else
            storyboard.state.PARAMS_NAME = {
                centerType = centerType,
                centerTypeName = centerTypeName,
                countryId = countryId,
                countryName = countryName,
                stateId = stateId,
                stateName = stateName,
                cityId = cityId,
                cityName = cityName,
                centerId = centerId,
                centerName = centerName,
                classId = classId,
                className = className,
                kidName = kidNameField:getText(),
                kidBirth = kidBirthField:getText(),
                kidSexValue = tostring(kidSexSegmentControl.segmentNumber)
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
                sharePanel.isShowing = true
            end
        end
    end
    return true
end

local function onRowTouch( event )
    if event.phase == "release" then
        native.setKeyboardFocus(nil)
    end
        
    return true
end 

local function centerTypeButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        local options = {
            effect = "fade",
            time = 300,
            params = {
                centerAddressRefData = centerAddressRefData
            },
            isModal = true
        }
        storyboard.showOverlay( "scripts.centerTypeListScene" ,options )
        return true
    end

    return true
end

local function countryButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if (centerType ~= nil) then
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.countryListScene" ,options )
        else
            utils.showMessage(language["joinScene"]["notselected_centertype"]) 
        end
    end

    return true
end

local function stateButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if countryId ~= nil then
            centerAddressRefData.centerType = centerType
            centerAddressRefData.cntFlag = 1
            centerAddressRefData.countryId = countryId
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.stateListScene", options ) 
        else
            utils.showMessage(language["joinScene"]["notselected_country"])
        end
        return true
    end
    
    return true
end

local function cityButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if stateId ~= nil then
            centerAddressRefData.centerType = centerType
            centerAddressRefData.cntFlag = 1
            centerAddressRefData.stateId = stateId
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.cityListScene", options ) 
        else
            utils.showMessage(language["joinScene"]["notselected_state"])
        end
        return true
    end
    
    return true
end

local function centerButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if cityId ~= nil then
            centerAddressRefData.centerType = centerType
            centerAddressRefData.countryId = countryId
            centerAddressRefData.stateId = stateId
            centerAddressRefData.cityId = cityId
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.centerListScene", options ) 
        else
            utils.showMessage(language["joinScene"]["notselected_city"])
        end
        return true
    end
    
    return true
end

local function classButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if centerId ~= nil then
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
        else
            utils.showMessage(language["joinScene"]["notselected_center"])
        end
        return true
    end
    
    return true
end

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    
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
            local timestamp = os.time({year=year, month=month, day=day})
            if timestamp then
                row.pickerField:setText(string.format("%d/%d/%d", year, month, day));
            end;    
        end  
        
        local function onClosePicker(event)
            row.pickerField:slideBackKeyboard()
        end
        
        local year, month, day = row.pickerField:getValue():match("(%d+)%/(%d+)%/(%d+)");
        if (month == nil) or (day == nil) or (year == nil) then
            local date = os.date( "*t" );
            year = date.year;
            month = date.month;
            day = date.day;
        end
        columnData[1].startIndex =  100 - (os.date( "%Y" ) - tonumber(year));
        columnData[2].startIndex = tonumber(month);
        columnData[3].startIndex = tonumber(day);
        
        row.pickerField:slideForKeyboard(250)
        
        pickerList = widget.newPickerList(
            {   
                left = 0,
                top = __statusBarHeight__,
                width = __appContentWidth__ ,
                height = __appContentHeight__ -__statusBarHeight__,
                --editField = row.pickerField,
                titleText = language["kidInfoScene"]["input_date"],
                pickerData = columnData,
                onScroll = onScroll,
                onClose = onClosePicker,
                okButtonText = language["kidInfoScene"]["confirm"],
                onOKClick = function(event)
                    row.pickerField:slideBackKeyboard()
                end
            }
        ) 
        row.pickerField:setText(string.format("%d/%d/%d", year,month,day))
       
       return true
    end
    
    if(index == 1) then
--        카테고리
        row.category_Kid_info = display.newText(language["kidInfoScene"]["category1"], 0, 0, native.systemFontBold, 12)
        row.category_Kid_info.anchorX = 0
        row.category_Kid_info.anchorY = 0
        row.category_Kid_info.x = 10
        row.category_Kid_info.y = (rowHeight - row.category_Kid_info.height) /2
        row.category_Kid_info:setFillColor(0, 0, 0)
        row:insert(row.category_Kid_info)
    elseif(index == 2) then
--        아이 정보
        if(utils.fileExist(storyboard.state.MEMBER_PROFILENAME, system.DocumentsDirectory) == true) then
            PROFILE_IMG_EXIST = true
            row.profileImage = display.newImageRect(storyboard.state.MEMBER_PROFILENAME, system.DocumentsDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
        else
            row.profileImage = display.newImageRect("images/main_menu_icons/pic_photo_80x80.png", PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
        end
        row.profileImage.anchorX = 0
        row.profileImage.anchorY = 0
        row.profileImage.x = 20
        row.profileImage.y = 20
        row.profileImage:addEventListener("touch", onKidProfileImageTap)
        row:insert(row.profileImage)
        
        row.profileImageFrame = display.newImageRect(row, "images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 4, PROFILE_IMAGE_SIZE_HEIGHT + 4)
        row.profileImageFrame.anchorX = 0
        row.profileImageFrame.anchorY = 0
        row.profileImageFrame.x = row.profileImage.x - 2
        row.profileImageFrame.y = row.profileImage.y - 2
        row:insert(row.profileImageFrame)
        
        row.profileImageCamera = display.newImageRect(row, "images/assets1/icon_change_profile.png", 30, 30)
        row.profileImageCamera.anchorX = 0
        row.profileImageCamera.anchorY = 0
        row.profileImageCamera.x = row.profileImageFrame.x + row.profileImageFrame.width -(row.profileImageCamera.width/2)
        row.profileImageCamera.y = row.profileImage.y -(row.profileImageCamera.height/2)
        row.profileImageCamera:addEventListener("touch", onKidProfileImageTap)
        row:insert(row.profileImageCamera)
        
        row.kidNameLabel = display.newText(language["kidInfoScene"]["kid_name"], 0, 0, native.systemFont, 12)
        row.kidNameLabel.anchorX = 0
        row.kidNameLabel.anchorY = 0
        row.kidNameLabel.x = row.profileImage.x + row.profileImage.width + 20
        row.kidNameLabel.y = row.profileImage.y + 5
        row.kidNameLabel:setFillColor(0, 0, 0)
        row:insert(row.kidNameLabel)
        
        local function onSubmit(event)
            local text = event.target:getText();
            if event.phase == "submitted" then
                if(text == "") then
                    utils.showMessage(language["joinScene"]["notinput_kidName"])
                    return 
                else
--                    goto server
                end
            end
        end
        
        row.kidNameField = widget.newEditField
        {
            width = rowWidth - row.kidNameLabel.x - row.kidNameLabel.width - 30,
            labelColor = {0,0,0,1},
            editHintColor = {1,1,1,1},
            hint = language["joinScene"]["kidsName_simple_input"],
            editFont = native.systemFontBold,
            editFontSize = __textFieldFontSize__,
            editFontColor = {1,1,1,1},
            onSubmit = onSubmit,
            align = "center",
            frame = 
              { 
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
        kidNameField = row.kidNameField
        row.kidNameField.anchorX = 0
        row.kidNameField.anchorY = 0
        row.kidNameField.width = rowWidth - row.kidNameLabel.x - row.kidNameLabel.width - 30 
        row.kidNameField.x = row.kidNameLabel.x + row.kidNameLabel.width + 20
        row.kidNameField.y = row.kidNameLabel.y - ((row.kidNameField.height - row.kidNameLabel.height)/2) --row.kidNameLabel.y
        row:insert(row.kidNameField)
        
        row.kidBirthdayLabel = display.newText(language["kidInfoScene"]["kid_birth"], 0, 0, native.systemFont, 12)
        row.kidBirthdayLabel.anchorX = 0
        row.kidBirthdayLabel.anchorY = 0
        row.kidBirthdayLabel.x = row.kidNameLabel.x
        row.kidBirthdayLabel.y = row.kidNameLabel.y + row.kidNameLabel.height + __text_padding__
        row.kidBirthdayLabel:setFillColor(0, 0, 0)
        row:insert(row.kidBirthdayLabel)
        
        row.kidBirthdayField = widget.newEditField
        {
            width = rowWidth - row.kidNameLabel.x - row.kidNameLabel.width - 30,
--            label = language["joinScene"]["select_birthday"],
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
        kidBirthField = row.kidBirthdayField
        row.kidBirthdayField.anchorX = 0
        row.kidBirthdayField.anchorY = 0
        row.kidBirthdayField.width = rowWidth - row.kidNameLabel.x - row.kidNameLabel.width - 30 
        row.kidBirthdayField.x = row.kidNameField.x
        row.kidBirthdayField.y = row.kidBirthdayLabel.y - ((row.kidBirthdayField.height - row.kidBirthdayLabel.height)/2) --row.kidNameLabel.y
        row.pickerField = row.kidBirthdayField
        row:insert(row.kidBirthdayField)
        
        row.kidSexLabel = display.newText(language["kidInfoScene"]["kid_sex"], 0, 0, native.systemFont, 12)
        row.kidSexLabel.anchorX = 0
        row.kidSexLabel.anchorY = 0
        row.kidSexLabel.x = row.kidNameLabel.x
        row.kidSexLabel.y = row.kidBirthdayLabel.y + row.kidBirthdayLabel.height + __text_padding__
        row.kidSexLabel:setFillColor(0, 0, 0)
        row:insert(row.kidSexLabel)
        
        local function segmentedControlListener( event )
            local target = event.target
	end
        
        local defaultSegment  = 1 --남자
        local segmentWidth = (rowWidth - row.kidNameLabel.x - row.kidNameLabel.width - 34) * 0.5
        row.sexSegmentedControl = widget.newSegmentedControl
	{
	    segmentWidth = segmentWidth,
	    segments = { language["joinScene"]["kid_sex1_label"], language["joinScene"]["kid_sex2_label"]},
	    defaultSegment = defaultSegment,
	    onPress = segmentedControlListener,
	}
        kidSexSegmentControl = row.sexSegmentedControl
        row.sexSegmentedControl.anchorX = 0
        row.sexSegmentedControl.anchorY = 0
        row.sexSegmentedControl.y = row.kidSexLabel.y - ((row.sexSegmentedControl.height - row.kidSexLabel.height)/2)
        row.sexSegmentedControl.x = row.kidNameField.x + 2
	row:insert( row.sexSegmentedControl )
        
        row.infoTxt = display.newText(language["kidInfoScene"]["info_txt"], 0, 0, rowWidth - 20, 60, native.systemFont, 10)
        row.infoTxt.anchorX = 0
        row.infoTxt.anchorY = 0
        row.infoTxt.x = 10
        row.infoTxt.y = row.kidSexLabel.y + row.kidSexLabel.height + 14
        row.infoTxt:setFillColor(0, 0, 0)
        row:insert(row.infoTxt)
    elseif(index == 3) then    
--        카테고리        
        row.categorySchooInfo = display.newText(language["kidInfoScene"]["category3"], 0, 0, native.systemFont, 12)
        row.categorySchooInfo.anchorX = 0
        row.categorySchooInfo.anchorY = 0
        row.categorySchooInfo.x = 10
        row.categorySchooInfo.y = (rowHeight - row.categorySchooInfo.height) /2
        row.categorySchooInfo:setFillColor(0, 0, 0)
        row:insert(row.categorySchooInfo)
    elseif(index == 4) then    
--    원정보 수정        
        row.centerTypeLabel = display.newText(language["kidInfoScene"]["center_type_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
        row.centerTypeLabel.anchorX = 0
        row.centerTypeLabel.anchorY = 0
        row.centerTypeLabel.x = (rowWidth - rowWidth * 0.25 - rowWidth * 0.65 - 10) * 0.5
        row.centerTypeLabel.y = 15
        row.centerTypeLabel:setFillColor(0, 0, 0)
        row:insert(row.centerTypeLabel)
        
        row.centerTypeButton = widget.newButton
        {
            width = rowWidth * 0.65,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            label = language["joinScene"]["facility_select_txt"],
            emboss = true,
            fontSize = __buttonFontSize__,
            onRelease = centerTypeButtonEvent
        }
        centerTypeButton = row.centerTypeButton
        row.centerTypeButton.anchorX = 0
        row.centerTypeButton.x = row.centerTypeLabel.x + row.centerTypeLabel.width + 10
        row.centerTypeButton.y = row.centerTypeLabel.y + row.centerTypeLabel.height * 0.5
        row:insert(row.centerTypeButton)
        
        row.countryLabel = display.newText(language["kidInfoScene"]["country_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
        row.countryLabel.anchorX = 0
        row.countryLabel.anchorY = 0
        row.countryLabel.x = row.centerTypeLabel.x
        row.countryLabel.y = row.centerTypeButton.y + row.centerTypeButton.height * 0.5 + 10
        row.countryLabel:setFillColor(0, 0, 0)
        row:insert(row.countryLabel)
        
        row.countryButton = widget.newButton
        {
            width = rowWidth * 0.65,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            label = language["joinScene"]["country_select_txt"],
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            onRelease = countryButtonEvent
        }
        countryButton = row.countryButton
        countryButton.label_org = language["joinScene"]["country_select_txt"]
        row.countryButton.anchorX = 0
        row.countryButton.x = row.countryLabel.x + row.countryLabel.width + 10
        row.countryButton.y = row.countryLabel.y + row.countryLabel.height * 0.5
        row:insert(row.countryButton)
        
        row.stateLabel = display.newText(language["kidInfoScene"]["state_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
        row.stateLabel.anchorX = 0
        row.stateLabel.anchorY = 0
        row.stateLabel.x = row.countryLabel.x
        row.stateLabel.y = row.countryButton.y + row.countryButton.height * 0.5 + 10
        row.stateLabel:setFillColor(0, 0, 0)
        row:insert(row.stateLabel)
        
        row.stateButton = widget.newButton
        {
            width = row.countryButton.width,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            label = language["joinScene"]["state_select_txt"],
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            onRelease = stateButtonEvent
        }
        stateButton = row.stateButton
        stateButton.label_org = language["joinScene"]["state_select_txt"]
        row.stateButton.anchorX = 0
        row.stateButton.x = row.stateLabel.x + row.stateLabel.width + 10
        row.stateButton.y = row.stateLabel.y + row.stateLabel.height * 0.5
        row:insert(row.stateButton)
        
        row.cityLabel = display.newText(language["kidInfoScene"]["city_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
        row.cityLabel.anchorX = 0
        row.cityLabel.anchorY = 0
        row.cityLabel.x = row.stateLabel.x
        row.cityLabel.y = row.stateButton.y + row.stateButton.height * 0.5 + 10
        row.cityLabel:setFillColor(0, 0, 0)
        row:insert(row.cityLabel)
        
        row.cityButton = widget.newButton
        {
            width = row.stateButton.width,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            label = language["joinScene"]["city_select_txt"],
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            onRelease = cityButtonEvent
        }
        cityButton = row.cityButton
        cityButton.label_org = language["joinScene"]["city_select_txt"]
        row.cityButton.anchorX = 0
        row.cityButton.x = row.cityLabel.x + row.cityLabel.width + 10
        row.cityButton.y = row.cityLabel.y + row.cityLabel.height * 0.5
        row:insert(row.cityButton)
        
        row.centerLabel = display.newText(language["kidInfoScene"]["center_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
        row.centerLabel.anchorX = 0
        row.centerLabel.anchorY = 0
        row.centerLabel.x = row.cityLabel.x
        row.centerLabel.y = row.cityButton.y + row.cityButton.height * 0.5 + 10
        row.centerLabel:setFillColor(0, 0, 0)
        row:insert(row.centerLabel)
        
        row.centerButton = widget.newButton 
        {
            width = row.cityButton.width,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            label = centerAddressTitle,
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            onRelease = centerButtonEvent
        }
        centerButton = row.centerButton
        centerButton.label_org = centerAddressTitle
        row.centerButton.anchorX = 0
        row.centerButton.x = row.centerLabel.x + row.centerLabel.width + 10
        row.centerButton.y = row.centerLabel.y + row.centerLabel.height * 0.5
        row:insert(row.centerButton)
        
        row.classLabel = display.newText(language["kidInfoScene"]["class_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
        row.classLabel.anchorX = 0
        row.classLabel.anchorY = 0
        row.classLabel.x = row.centerLabel.x
        row.classLabel.y = row.centerButton.y + row.centerButton.height * 0.5 + 10
        row.classLabel:setFillColor(0, 0, 0)
        row:insert(row.classLabel)
        
        row.classButton = widget.newButton {
            width = centerButton.width,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            label = language["joinScene"]["class_select_txt"],
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            onRelease = classButtonEvent
        }
        classButton = row.classButton
        row.classButton.anchorX = 0
        row.classButton.x = row.classLabel.x + row.classLabel.width + 10
        row.classButton.y = row.classLabel.y + row.classLabel.height * 0.5
        row.classButton.label_org = language["joinScene"]["class_select_txt"]
        row:insert(row.classButton)
        
        row.infoTxt3 = display.newText(language["kidInfoScene"]["info_txt3"], 0, 0, rowWidth - 20, 40, native.systemFont, 10)
        row.infoTxt3.anchorX = 0
        row.infoTxt3.anchorY = 0
        row.infoTxt3.x = 10
        row.infoTxt3.y = row.classButton.y + row.classButton.height * 0.5 + 5
        row.infoTxt3:setFillColor(0, 0, 0)
        row:insert(row.infoTxt3)
    end
end

local function onLeftButton(event)
    native.setKeyboardFocus(nil)
    
    if event.phase == "ended" then
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
            
            return true
        end
        
        storyboard.purgeScene("scripts.kidslistScene")
        storyboard.gotoScene("scripts.kidslistScene", "slideRight", 300)
    end
    
    return true
end

local function addKidsInfoCallback( event )
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            if (data) then
                if(data.status == "OK") then
                    access:gotoKidsList(user.userData.id)
                    activityIndicator:destroy()
                else
                    activityIndicator:destroy()
                    utils.showMessage(data.message)
                    return true
                end
            end
        end
    end
end

local function onRightButton(event)
    native.setKeyboardFocus(nil)
    
    if event.phase == "ended" then
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
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
        if countryId == nil then
            utils.showMessage(language["joinScene"]["notselected_country"])
            return true
        end
        if stateId == nil then
            utils.showMessage(language["joinScene"]["notselected_state"])
            return true
        end
        if cityId == nil then
            utils.showMessage(language["joinScene"]["notselected_city"])
            return true
        end
        if centerId == nil then
            utils.showMessage(language["joinScene"]["notselected_center"])
            return true
        end
        if classId == nil then
            utils.showMessage(language["joinScene"]["notselected_class"])
            return true
        end

        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
        local year, month, day = kidBirthField:getValue():match("(%d+)%/(%d+)%/(%d+)");
        if tonumber(month) < 10 then
            month = "0"..month
        end
        if tonumber(day) < 10 then
            day  = "0"..day
        end
        
        local params = {
            member_id = user.userData.id,
            filename = PROFILE_IMG_EXIST and storyboard.state.MEMBER_PROFILENAME or "",
            dir = PROFILE_IMG_EXIST and system.DocumentsDirectory or "",
            kids_name = kidNameField:getText(),
            kids_birthday = year..month..day,
            kids_sex = kidSexSegmentControl.segmentNumber,
            center_id = centerId,
            class_id = classId,
            kids_active = '0'
        }
        api.add_kids_info(params, addKidsInfoCallback)
    end
    
    return true
end

local function scrollListener( event )
    if ( event.phase == "began" ) then
        print("scroll began")
    elseif ( event.phase == "moved" ) then -- and (event.target.parent.parent:getContentPosition( ) > springStart + REFRESH_ROW_HEIGHT) then
        print("scroll moved")
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
        centerType = params.centerType
        centerTypeName = params.centerTypeName
        countryId = params.countryId
        countryName = params.countryName
        stateId = params.stateId
        stateName = params.stateName
        cityId = params.cityId
        cityName = params.cityName
        centerId = params.centerId
        centerName = params.centerName
        classId = params.classId
        className = params.className
        kidName = params.kidName
        kidBirth = params.kidBirth
        kidSexValue = params.kidSexValue
    end    
    
    centerType2 = nil 
    countryId2 = nil
    stateId2 = nil
    cityId2 = nil
    centerId2 = nil
    classId2 = nil    
    
    centerAddressTitle = string.gsub(language["joinScene"]["select_centername"], "_CENTER_", language["joinScene"]["facilityname"])
    
    local bg = display.newImageRect(group, "images/bg_set/background.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["kidInfoScene"]["button_return"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }

    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["kidInfoScene"]["button_save"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
    }

    kidInfoTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT,
	height = __appContentHeight__ - NAVI_BAR_HEIGHT - __statusBarHeight__ ,
        width = __appContentWidth__,
	maxVelocity = 1,
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
	listener = nil
    }
    kidInfoTable.x = display.contentWidth / 2
    group:insert(kidInfoTable)
    
    kidInfoTable:insertRow{
        rowHeight = CATEGORY_ROW_HEIGHT,
        isCategory = true,
        rowColor = { default = __activeKidListColor__},
        lineColor = { 1, 0, 0, 0 }
    }
    kidInfoTable:insertRow{
        rowHeight = ROW_HEIGHT,
        rowColor = {  default = { 1, 1, 1 }, over = { 1, 1, 1 }},
        lineColor = { 0.5, 0.5, 0.5, 0 }
    }
    kidInfoTable:insertRow{
        rowHeight = CATEGORY_ROW_HEIGHT,
        isCategory = true,
        rowColor = { default= __activeKidListColor__},
        lineColor = { 1, 0, 0, 0 }
    }
    kidInfoTable:insertRow{
        rowHeight = ROW_HEIGHT + 80,
        rowColor = {  default = { 1, 1, 1 }, over = { 1, 1, 1 }},
        lineColor = { 0.5, 0.5, 0.5, 0 }
    }
    
    local navBar = widget.newNavigationBar({
        title = language["kidInfoScene"]["add_title_bar"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
--        includeStatusBar = true
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    storyboard.returnTo = "scripts.kidslistScene"
    
    if kidName then
        kidNameField:setText(kidName)
    end
    if kidBirth then
        kidBirthField:setText(kidBirth)
    end
    if kidSexValue then
        kidSexSegmentControl:setActiveSegment(tonumber(kidSexValue))
    end
    if centerTypeName then
        centerTypeButton:setLabel(centerTypeName)
    end
    if countryName then
        countryButton:setLabel(countryName)
    end
    if stateName then
        stateButton:setLabel(stateName)
    end
    if cityName then
        cityButton:setLabel(cityName)
    end
    if centerName then
        centerButton:setLabel(centerName)
    end
    if className then
        classButton:setLabel(className)
    end
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
    
    print("kidAddScene Exit")
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
    if (centerAddressRefData.centerType ~= nil) then
        if (event.sceneName == "scripts.centerTypeListScene") then
            centerType = centerAddressRefData.centerType
            centerTypeName = centerAddressRefData.centerTypeName
            centerTypeButton:setLabel(centerTypeName)
            if centerType2 == nil then
                centerType2 = centerType
            end
            if centerType ~= centerType2 then
                centerAddressRefData.countryId = nil
                centerAddressRefData.countryName = nil
                centerAddressRefData.stateId = nil
                centerAddressRefData.stateName = nil
                centerAddressRefData.cityId = nil
                centerAddressRefData.cityName = nil
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerAddressRefData.classId = nil
                centerAddressRefData.className = nil
                countryId = nil
                stateId = nil
                cityId = nil
                centerId = nil
                classId = nil
                countryButton:setLabel(countryButton.label_org)
                stateButton:setLabel(stateButton.label_org)
                cityButton:setLabel(cityButton.label_org)
                centerButton:setLabel(centerButton.label_org)
                classButton:setLabel(classButton.label_org)
            end
            centerType2 = centerType
        end
        centerAddressRefData.centerType = nil
        centerAddressRefData.centerTypeName = nil
    end
    
    if (centerAddressRefData.countryId ~= nil) then
        if (event.sceneName == "scripts.countryListScene") then
            countryId = centerAddressRefData.countryId
            countryName = centerAddressRefData.countryName
            countryButton:setLabel(countryName)
            if countryId2 == nil then
                countryId2 = countryId
            end
            if countryId ~= countryId2 then
                centerAddressRefData.stateId = nil
                centerAddressRefData.stateName = nil
                centerAddressRefData.cityId = nil
                centerAddressRefData.cityName = nil
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerAddressRefData.classId = nil
                centerAddressRefData.className = nil
                stateId = nil
                cityId = nil
                centerId = nil
                centerId = nil
                classId = nil
                stateButton:setLabel(stateButton.label_org)
                cityButton:setLabel(cityButton.label_org)
                centerButton:setLabel(centerButton.label_org)
                classButton:setLabel(classButton.label_org)
            end
            countryId2 = countryId
        end
        centerAddressRefData.countryId = nil
        centerAddressRefData.countryName = nil
    end
    
    if (centerAddressRefData.stateId ~= nil) then
        if (event.sceneName == "scripts.stateListScene") then
            stateId = centerAddressRefData.stateId
            stateName = centerAddressRefData.stateName
            stateButton:setLabel(stateName)
            if stateId2 == nil then
                stateId2 = stateId
            end
            if stateId ~= stateId2 then
                centerAddressRefData.cityId = nil
                centerAddressRefData.cityName = nil
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerAddressRefData.classId = nil
                centerAddressRefData.className = nil
                cityId = nil
                centerId = nil
                centerId = nil
                classId = nil
                cityButton:setLabel(cityButton.label_org)
                centerButton:setLabel(centerButton.label_org)
                classButton:setLabel(classButton.label_org)
            end
            stateId2 = stateId
        end
        centerAddressRefData.stateId = nil
        centerAddressRefData.stateName = nil
    end
    
    if (centerAddressRefData.cityId ~= nil) then
        if (event.sceneName == "scripts.cityListScene") then
            cityId = centerAddressRefData.cityId
            cityName = centerAddressRefData.cityName
            cityButton:setLabel(cityName)
            if cityId2 == nil then
                cityId2 = cityId
            end
            if cityId ~= cityId2 then
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerAddressRefData.classId = nil
                centerAddressRefData.className = nil
                centerId = nil
                classId = nil
                centerButton:setLabel(centerButton.label_org)
                classButton:setLabel(classButton.label_org)
            end
            cityId2 = cityId
        end
        centerAddressRefData.cityId = nil
        centerAddressRefData.cityName = nil
    end
    if (centerAddressRefData.centerId ~= nil) then
        if (event.sceneName == "scripts.centerListScene") then
            centerId = centerAddressRefData.centerId
            centerName = centerAddressRefData.centerName
            centerButton:setLabel(centerName)
            if centerId2 == nil then
                centerId2 = centerId
            end
            if centerId ~= centerId2 then
                centerAddressRefData.classId = nil
                centerAddressRefData.className = nil
                classId = nil
                classButton:setLabel(classButton.label_org)
            end
            centerId2 = centerId
        end
        centerAddressRefData.centerId = nil
        centerAddressRefData.centerName = nil
    end
    if (centerAddressRefData.classId ~= nil) then
        if (event.sceneName == "scripts.classListScene") then
            classId = centerAddressRefData.classId
            className = centerAddressRefData.className
            classButton:setLabel(className)
        end
        centerAddressRefData.classId = nil
        centerAddressRefData.className = nil
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