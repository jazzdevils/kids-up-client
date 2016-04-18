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
local activityIndicator

local ROW_HEIGHT = 170
local CATEGORY_ROW_HEIGHT = 40
local NAVI_BAR_HEIGHT = 50
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90

local memberInfoTable
local sharePanel
local centerTypeButton, countryButton, stateButton, cityButton, centerButton, classButton
local centerAddressRefData = {}
local centerAddressTitle
local memberNameField, memberPhonenumField
local PROFILE_IMG_EXIST = false
local centerType, countryId, stateId, cityId, centerId, classId
local centerTypeName, countryName, stateName, cityName, centerName, className
local centerType2, countryId2, stateId2, cityId2, centerId2, classId2
local CURRENT_SCENE = storyboard.getCurrentSceneName()
local memberInfo = {}

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onMemberProfileImageTap(event)
    native.setKeyboardFocus(nil)
    
    if(event.phase == "began") then
        --print("onMemberProfileImageTap began")
    elseif(event.phase == "ended") then
        --print("onMemberProfileImageTap(event)")
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
        else
            if(sharePanel) then
                sharePanel:show()
                sharePanel.kidData = {profileImage = user.userData.profileImage}
                sharePanel.fromScene = CURRENT_SCENE
                sharePanel.imagePath = system.DocumentsDirectory
            else
                sharePanel = widget.newSharingPanel()
                sharePanel:show()
                sharePanel.kidData = {profileImage = user.userData.profileImage}
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
        local options = {
            effect = "fade",
            time = 300,
            params = {
                centerAddressRefData = centerAddressRefData
            },
            isModal = true
        }
        storyboard.showOverlay( "scripts.countryListScene" ,options )
        return true
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
            centerAddressRefData.centerId = centerId
            centerAddressRefData.showNoClassFlag = 0
            
            if centerAddressRefData.selectedTeacherClasses == nil then
                centerAddressRefData.selectedTeacherClasses = table.copy(user.userData.ClassListOfTeacher)
            end
            
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.classList4TeacherScene", options ) 
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
    
    if(index == 1) then
--        카테고리
        local categoryText = language["memberInfoUpdateScene"]["membertype1_category"]
        if user.userData.jobType == __TEACHER__ then
            categoryText = language["memberInfoUpdateScene"]["membertype2_category"]
        end
        row.categoryKidInfo = display.newText(categoryText, 0, 0, native.systemFontBold, 12)
        row.categoryKidInfo.anchorX = 0
        row.categoryKidInfo.anchorY = 0
        row.categoryKidInfo.x = 10
        row.categoryKidInfo.y = (rowHeight - row.categoryKidInfo.height) /2
        row.categoryKidInfo:setFillColor(0, 0, 0)
        row:insert(row.categoryKidInfo)
    elseif(index == 2) then
--        先生情報
        if storyboard.state.MEMBER_PROFILENAME then
            user.userData.profileImage = storyboard.state.MEMBER_PROFILENAME
        end
        if(user.userData.profileImage ~= "") then
            if(utils.fileExist(user.userData.profileImage, system.DocumentsDirectory) == true) then
                row.profileImage = display.newImageRect(row, user.userData.profileImage, system.DocumentsDirectory, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
                PROFILE_IMG_EXIST = true
            else
                local defaultImage = "images/main_menu_icons/pic_photo_80x90.png"
                row.profileImage = display.newImageRect(row, defaultImage, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
            end
        else
            local defaultImage = "images/main_menu_icons/pic_photo_80x90.png"
            row.profileImage = display.newImageRect(row, defaultImage, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
        end
            
        row.profileImage.anchorX = 0
        row.profileImage.anchorY = 0
        row.profileImage.x = 10
        row.profileImage.y = 20
        row.profileImage:addEventListener("touch", onMemberProfileImageTap)
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
        row.profileImageCamera:addEventListener("touch", onMemberProfileImageTap)
        row:insert(row.profileImageCamera)
        
        row.memberNameLabel = display.newText(language["joinScene"]["name_editbox"], 0, 0, native.systemFont, 12)
        row.memberNameLabel.anchorX = 0
        row.memberNameLabel.anchorY = 0
        row.memberNameLabel.x = row.profileImage.x + row.profileImage.width + 10
        row.memberNameLabel.y = row.profileImage.y + 20
        row.memberNameLabel:setFillColor(0, 0, 0)
        row:insert(row.memberNameLabel)
        
        local function onSubmit(event)
            local text = event.target:getText();
            if event.phase == "submitted" then
                if(text == "") then
                    utils.showMessage(language["joinScene"]["notinput_memberName"])
                    return 
                else
                end
            end
        end
        
        row.memberNameField = widget.newEditField
        {
            labelColor = {0,0,0,1},
            maxChars = 50,
            editHintColor = {1,1,1,1},
            hint = language["joinScene"]["kidsName_simple_input"],
            editFont = native.systemFont,
            editFontSize = __textFieldFontSize__,
            editFontColor = {1,1,1,1},
            onSubmit = onSubmit,
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
            },
            buttons = {
                {
                    kind = "clear",
                    defaultFile = "images/widgets/clear.png"
                }
            }
        }
        memberNameField = row.memberNameField
        row.memberNameField.text = user.userData.name
        row.memberNameField.anchorX = 0
        row.memberNameField.anchorY = 0
        row.memberNameField.width = rowWidth - row.memberNameLabel.x - row.memberNameLabel.width - 50 
        row.memberNameField.x = row.memberNameLabel.x + row.memberNameLabel.width + 40
        row.memberNameField.y = row.memberNameLabel.y - ((row.memberNameField.height - row.memberNameLabel.height)/2) --row.memberNameLabel.y
        row:insert(row.memberNameField)
        
        row.memberPhonenumLabel = display.newText(language["joinScene"]["phonenum_editbox"], 0, 0, native.systemFont, 12)
        row.memberPhonenumLabel.anchorX = 0
        row.memberPhonenumLabel.anchorY = 0
        row.memberPhonenumLabel.x = row.memberNameLabel.x
        row.memberPhonenumLabel.y = row.memberNameLabel.y + row.memberNameLabel.height + 30 
        row.memberPhonenumLabel:setFillColor(0, 0, 0)
        row:insert(row.memberPhonenumLabel)
        
        row.memberPhonenumField = widget.newEditField
        {
            labelColor = {0,0,0,1},
            maxChars = 50,
            editHintColor = {1,1,1,1},
            hint = language["joinScene"]["phonenum_input"],
            editFont = native.systemFont,
            editFontSize = __textFieldFontSize__,
            editFontColor = {1,1,1,1},
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
            },
            inputType = "phone",
            buttons = {
                {
                    kind = "clear",
                    defaultFile = "images/widgets/clear.png"
                }
            }
        }
        memberPhonenumField = row.memberPhonenumField
        memberPhonenumField.text = user.userData.phonenum
        row.memberPhonenumField.anchorX = 0
        row.memberPhonenumField.anchorY = 0
        row.memberPhonenumField.width = rowWidth - row.memberNameLabel.x - row.memberNameLabel.width - 50
        row.memberPhonenumField.x = row.memberNameField.x
        row.memberPhonenumField.y = row.memberPhonenumLabel.y - ((row.memberPhonenumField.height - row.memberPhonenumLabel.height)/2) --row.memberNameLabel.y
        row:insert(row.memberPhonenumField)
        
        if user.userData.jobType == __TEACHER__ then
            row.centerTypeLabel = display.newText(language["kidInfoScene"]["center_type_label"], 0, 0, rowWidth * 0.25, 20, native.systemFont, 12)
            row.centerTypeLabel.anchorX = 0
            row.centerTypeLabel.anchorY = 0
            row.centerTypeLabel.x = (rowWidth - rowWidth * 0.25 - rowWidth * 0.65 - 10) * 0.5
            row.centerTypeLabel.y = row.memberPhonenumLabel.y + row.memberPhonenumLabel.height + 30
            row.centerTypeLabel:setFillColor(0, 0, 0)
            row:insert(row.centerTypeLabel)

            row.centerTypeButton = widget.newButton
            {
                width = rowWidth * 0.65,
                height = 30,
                defaultFile = "images/input/selectbox_full_width.png",
                overFile = "images/input/selectbox_full_width.png",
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                emboss = true,
                fontSize = __buttonFontSize__,
                label = language["joinScene"]["centerType"][tonumber(centerType)],
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
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                emboss = true,
                fontSize = __buttonFontSize__,
                label = countryName,
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
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                emboss = true,
                fontSize = __buttonFontSize__,
                label = stateName,
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
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                emboss = true,
                fontSize = __buttonFontSize__,
                label = cityName,
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
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                emboss = true,
                fontSize = __buttonFontSize__,
                label = centerName,
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
                labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                emboss = true,
                fontSize = __buttonFontSize__,
                label = user.getClassNameOfTeacher4Display(),
                onRelease = classButtonEvent
            }
            classButton = row.classButton
            row.classButton.anchorX = 0
            row.classButton.x = row.classLabel.x + row.classLabel.width + 10
            row.classButton.y = row.classLabel.y + row.classLabel.height * 0.5
            row.classButton.label_org = language["joinScene"]["class_select_txt"]
            row:insert(row.classButton)
            
            row.infoTxt2 = display.newText(language["kidInfoScene"]["info_txt2"], 0, 0, rowWidth - 20, 40, native.systemFont, 10)
            row.infoTxt2.anchorX = 0
            row.infoTxt2.anchorY = 0
            row.infoTxt2.x = 10
            row.infoTxt2.y = row.classButton.y + row.classButton.height * 0.5 + 5
            row.infoTxt2:setFillColor(0, 0, 0)
            row:insert(row.infoTxt2)
        end
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
        storyboard.purgeScene("scripts.mngHomeScene")
        storyboard.gotoScene("scripts.mngHomeScene", "slideRight", 300)
    end
    
    return true
end

local function updateMemberInfoCallback( event )
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
                    activityIndicator:destroy()
                    access:updateMemberInfo(user.userData.id)
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
        
        if memberNameField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_kidName"])
            return true
        end
        if memberPhonenumField:getText() == "" then
            utils.showMessage(language["joinScene"]["notinput_phonenum"])
            return true
        end
        if tonumber(utils.trim(memberPhonenumField:getText())) == nil then
            utils.showMessage(language["joinScene"]["phonenum_notnumber"])
            return true
        end
        if user.userData.jobType == __TEACHER__ then
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
            
            if centerAddressRefData.selectedTeacherClasses == nil or #centerAddressRefData.selectedTeacherClasses == 0 then
                utils.showMessage(language["joinScene"]["notselected_class"])
                return true
            end
        end
        
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
        if user.userData.jobType == __TEACHER__ then --선생
            if centerId ~= user.userData.centerid then
                local alert = native.showAlert( language["appTitle"], language["kidInfoScene"]["transfer_confirm"], { language["kidInfoScene"]["confirm"], language["kidInfoScene"]["cancel"] }, 
                function(event)
                    if "clicked" == event.action then
                        local i = event.index
                        if 1 == i then
                            local params = {
                                member_id = user.userData.id,
                                member_name = memberNameField:getText(),
                                phonenum = memberPhonenumField:getText(),
                                filename = PROFILE_IMG_EXIST and user.userData.profileImage or "",
                                dir = PROFILE_IMG_EXIST and system.DocumentsDirectory or "",
                                center_id = centerId,
                                class_id = getClassIDs()--classId
                            }
                            if PROFILE_IMG_EXIST and user.userData.profileImage then
                                user.userData.profileImage = user.userData.profileImage
                            end
                            user.userData.name = memberNameField:getText()
                            user.userData.phonenum = memberPhonenumField:getText()
                            user.userData.centerId = centerId
                            user.userData.centerName = centerName
                            user.userData.classId = centerAddressRefData.selectedTeacherClasses[1].id
                            user.userData.className = centerAddressRefData.selectedTeacherClasses[1].name
                            user.userData.ClassListOfTeacher = centerAddressRefData.selectedTeacherClasses
                            
                            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                            api.update_member2_info(params, updateMemberInfoCallback)
                        elseif 2 == i then
                        end
                    end
                end )
            else
                local params = {
                    member_id = user.userData.id,
                    member_name = memberNameField:getText(),
                    phonenum = memberPhonenumField:getText(),
                    filename = PROFILE_IMG_EXIST and user.userData.profileImage or "",
                    dir = PROFILE_IMG_EXIST and system.DocumentsDirectory or "",
                    center_id = centerId,
                    class_id = getClassIDs()--classId
                }
                if PROFILE_IMG_EXIST and user.userData.profileImage then
                    user.userData.profileImage = user.userData.profileImage
                end
                user.userData.name = memberNameField:getText()
                user.userData.phonenum = memberPhonenumField:getText()
                user.userData.centerId = centerId
                user.userData.centerName = centerName
                user.userData.classId = centerAddressRefData.selectedTeacherClasses[1].id
                user.userData.className = centerAddressRefData.selectedTeacherClasses[1].name
                user.userData.ClassListOfTeacher = centerAddressRefData.selectedTeacherClasses
                
                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                api.update_member2_info(params, updateMemberInfoCallback)
            end
        else --관리자
            local params = {
                member_id = user.userData.id,
                member_name = memberNameField:getText(),
                phonenum = memberPhonenumField:getText(),
                filename = PROFILE_IMG_EXIST and user.userData.profileImage or "",
                dir = PROFILE_IMG_EXIST and system.DocumentsDirectory or "",
            }
            user.userData.name = memberNameField:getText()
            user.userData.phonenum = memberPhonenumField:getText()
            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
            api.update_member1_info(params, updateMemberInfoCallback)
        end
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

local function getDataCallback(event)
    activityIndicator:destroy()
    if ( event.isError ) then
        print( "Network error!")
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
                    centerType = data.member.center_type
                    countryId = data.member.country_id
                    countryName = data.member.country_name
                    stateId = data.member.state_id
                    stateName = data.member.state_name
                    cityId = data.member.city_id
                    cityName = data.member.city_name
                    centerId = data.member.center_id
                    centerName = data.member.center_name
                    classId = data.member.class_id
                    className = data.member.class_name
                    
                    memberInfo.centerType = data.member.center_type
                    memberInfo.countryId = data.member.country_id
                    memberInfo.stateId = data.member.state_id
                    memberInfo.cityId = data.member.city_id
                    memberInfo.centerId = data.member.center_id
                    memberInfo.classId = data.member.class_id
                    
                    memberInfoTable:insertRow{
                        rowHeight = CATEGORY_ROW_HEIGHT,
                        isCategory = true,
                        rowColor = { default = __activeKidListColor__},
                        lineColor = { 1, 0, 0, 0 }
                    }
                    memberInfoTable:insertRow{
                        rowHeight = ROW_HEIGHT + 120,
                        rowColor = {  default = { 1, 1, 1 }, over = { 1, 1, 1 }},
                        lineColor = { 0.5, 0.5, 0.5, 0 }
                    }
                else
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage(language["joinScene"]["wrong_join"])
                end
            end
        end
    end
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
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

    memberInfoTable = widget.newTableView{
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
    memberInfoTable.x = display.contentWidth / 2
    group:insert(memberInfoTable)
    
    local navBar = widget.newNavigationBar({
        title = language["memberInfoUpdateScene"]["title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_member_info(user.userData.id, getDataCallback)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    storyboard.returnTo = "scripts.mngHomeScene"
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

    print("memberInfoUpdateScene Exit")
    
    if (sharePanel) then
        sharePanel.isShowing = false
        sharePanel:hide()
    end
--    display.remove(sharePanel)
--    sharePanel = nil
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
    print( "Overlay removed: " .. event.sceneName )
    if (centerAddressRefData.centerType ~= nil) then
        if (event.sceneName == "scripts.centerTypeListScene") then
            centerType = centerAddressRefData.centerType
            centerTypeName = centerAddressRefData.centerTypeName
            centerTypeButton:setLabel(centerTypeName)
            if centerType2 == nil then
                centerType2 = memberInfo.centerType
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
                countryId2 = memberInfo.countryId
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
                stateId2 = memberInfo.stateId
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
                cityId2 = memberInfo.cityId
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
                centerId2 = memberInfo.centerId
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
--    if (centerAddressRefData.classId ~= nil) then
--        if (event.sceneName == "scripts.classListScene") then
--            classId = centerAddressRefData.classId
--            className = centerAddressRefData.className
--            classButton:setLabel(className)
--        end
--        centerAddressRefData.classId = nil
--        centerAddressRefData.className = nil
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