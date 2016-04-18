---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.widget_sharePanelEx")
require("widgets.widgetext")
require("widgets.activityIndicator")

--local widget = require "widget"
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
local sceneData = require("scripts.sceneData")
local api = require("scripts.api")
local authority = require("scripts.user_authority")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local IMAGE_MAX_COUNT = 5
local SELECT_CLASS_BAR = 30

local sharePanel

local photolist 
local photolist_add 
local photolistGroup 

local content_textBox
local title_textBox
local notice_id

local CONTENT_TEXTBOX_HEIGHT = 100
local TITLE_TEXTBOX_HEIGHT = 40
local activityIndicator

local pickerList

local selected_class_id
local selectClassName
local contentField_Move_Y = 100
local pickerList_Move_Y = 50
local button_keyboardOnOff
local display_group
local imageScrollView
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function clearScreen()
    native.setKeyboardFocus(nil)
    
    if (display_group.y < 0) then
        transition.to(display_group, {y = 0, time=100, onComplete=nil})
    end
    
    if (button_keyboardOnOff) then
        button_keyboardOnOff.isVisible = false
    end
    
    if(pickerList and pickerList.isShowing == true) then
        pickerList:closeUp()
        pickerList.isShowing = false
        
--        return true
    end
    
    if (sharePanel and sharePanel.isShowing == true) then
        sharePanel:hide()
        sharePanel.isShowing = false
        
        return true
    end
end

local function freeMemoryAndGo(needRefresh)
    sceneData.freeSceneDataWithUID("photolist")
    sceneData.freeSceneDataWithUID("noticeContents")
    sceneData.freeSceneDataWithUID("noticeTitle")
    sceneData.freeSceneDataWithUID("photolist_add")
    
    if(needRefresh and needRefresh == true) then
        storyboard.purgeScene("scripts.noticeScene")
    end
    
    storyboard.gotoScene("scripts.noticeScene", "slideRight", 300)
end

local function addPhoto(event)
    if (display_group.y < 0) then
        transition.to(display_group, {y = 0, time=100, onComplete=nil})
    end
    
    if(clearScreen() == true) then
        return true
    end
    
    sceneData.addSceneDataWithUID("photolist", photolist)
    
    if(title_textBox and title_textBox.text ~= "") then
        sceneData.addSceneDataWithUID("noticeTitle", title_textBox.text)
    end
    
    if(content_textBox and content_textBox.text ~= "") then
        sceneData.addSceneDataWithUID("noticeContents", content_textBox.text)
    end
    
    if(sharePanel) then
        sharePanel:show()
        sharePanel.fromScene = storyboard.getCurrentSceneName()
        sharePanel.imagePath = system.TemporaryDirectory
        sharePanel.imageMaxCount = IMAGE_MAX_COUNT
        sharePanel.isShowing = true
    else
        sharePanel = widget.newSharingPanelEx()
        sharePanel:show()
        sharePanel.fromScene = storyboard.getCurrentSceneName()
        sharePanel.imagePath = system.TemporaryDirectory
        sharePanel.imageMaxCount = IMAGE_MAX_COUNT
        sharePanel.isShowing = true
    end
    
    return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        if(clearScreen() == true) then
            return true
        end
        
        freeMemoryAndGo(true)
    end
    
    return true
end

local function getDataCallback(event)
    if(event.isError) then
        print("Post error")    
        activityIndicator:destroy()
        freeMemoryAndGo(false)
    elseif(event.phase == "ended") then
        activityIndicator:destroy()
        local data = json.decode(event.response)
        if (data) then
            if(data.status == "OK") then
                if(notice_id) then
                    if(photolist_add and #photolist_add > 0) then
                        local photoCount = #photolist_add
                        local uploadingCount = 0
                        local uploadedCount = 0
                        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["image_upload"])
                        
                        for i = 1, photoCount do
                            if (utils.fileExist(photolist_add[i], system.TemporaryDirectory) == true) then
                                uploadingCount = uploadingCount + 1
                                
                                local params = {
                                    center_id = user.userData.centerid,
                                    notice_id = notice_id,
                                    filename = photolist_add[i],
                                    dir = system.TemporaryDirectory
                                }
                                api.post_notice_image(params, 
                                    function(event) 
                                        if(event.isError) then
                                            uploadedCount = uploadedCount + 1

                                            if(uploadingCount == uploadedCount) then
                                                activityIndicator:destroy()
                                                freeMemoryAndGo(true)
                                            end
                                        elseif(event.phase == "ended") then
                                            uploadedCount = uploadedCount + 1

                                            if(uploadingCount == uploadedCount) then
                                                activityIndicator:destroy()
                                                freeMemoryAndGo(true)
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    else
                        freeMemoryAndGo(true)
                    end
                else
                    freeMemoryAndGo(true)
                end
            else
                print("Post error")    
            end
        end
    end
end

local function onRightButton(event)
    if event.phase == "ended" then
        if(clearScreen() == true) then
            return true
        end
        
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        if(title_textBox and title_textBox.text ~= "") then
            if(content_textBox and content_textBox.text ~= "") then
                local title = title_textBox.text
                local contents = content_textBox.text
                local toWhere  -- (1:all class, 2:only 1 class)
                if(selected_class_id and selected_class_id == "") then
                    toWhere = 1 
                else
                    toWhere = 2 
                end
                
                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                
                api.update_notice_contents(notice_id, selected_class_id, title, contents, getDataCallback)
            else
                utils.showMessage(language["noticeEditScene"]["input_contents"])
                native.setKeyboardFocus(content_textBox) 
                
                return true
            end
        else
            utils.showMessage(language["noticeEditScene"]["input_title"])
            native.setKeyboardFocus(title_textBox) 
            
            return true
        end
    end
end

local function viewClass()
    clearScreen()
    
    if display.contentHeight <= 480 then
        transition.to(display_group, {y = - pickerList_Move_Y, time=100, onComplete=nil})
    end
    
    local startIndexClass = 1 
    local classes = {}
    local class_label = {}
    
    if user.userData.jobType == __DIRECTOR__ then
        local class_cnt = #user.classList
        classes[1] = {id = "",name = language["noticeEditScene"]["all_class"], desc = ""}
        class_label[1] = language["noticeEditScene"]["all_class"]
        for i = 1, class_cnt do
            local class = {}
            class.id = user.classList[i].id
            class.name = user.classList[i].name
            classes[i+1] = class
            class_label[i+1] = user.classList[i].name

            if(class.id == selected_class_id) then
                startIndexClass = i+1
            end
        end
    elseif user.userData.jobType == __TEACHER__ then
        local class_cnt = #user.userData.ClassListOfTeacher
        for i = 1, class_cnt do
            local class = {}
            class.id = user.userData.ClassListOfTeacher[i].id
            class.name = user.userData.ClassListOfTeacher[i].name
            classes[i] = class
            class_label[i] = user.userData.ClassListOfTeacher[i].name

            if(class.id == selected_class_id) then
                startIndexClass = i
            end
        end
    end
        
    local columnData = 
    {
        -- Years
        {
            align = "center",
            width = __appContentWidth__- 50,
            startIndex = startIndexClass,
            labels = class_label
        },
    
    }  
        
    pickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
--            pickerHeight = 130,
            pickerData = columnData,
            titleText = language["noticeEditScene"]["select_class"],
--            onScroll = nil,
            okButtonText = language["noticeEditScene"]["ok"],
            onClose =   function()
                            native.setKeyboardFocus(title_textBox)
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                local obj = event.target
                                local value = pickerList.pickerWheel:getValues()
                                print(value[1].value)
                                print(value[1].index)
                                local classData = classes[value[1].index]
                                
                                selected_class_id = classData.id
                                selectClassName.text = classData.name
                            end
                        end,
        }
    )
    pickerList.isShowing = true
       
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    display_group = group
    
    if(event.params and event.params.notice_id) then
        notice_id = event.params.notice_id  --update
    end
    
    photolist_add = sceneData.getSceneDataWithUID("photolist_add")
    if(photolist_add == nil) then
        photolist_add = {}
--        sceneData.addSceneDataWithUID("photolist_add", photolist_add)
    end
    sceneData.addSceneDataWithUID("photolist_add", photolist_add)
    print("photolist_add : "..#photolist_add)
    photolist = sceneData.getSceneDataWithUID("photolist")
    if(photolist == nil) then
--        photolist = {
--            "d5b9157879a02053708ebfeeef41f0a8964ca02a.jpg",
--            "bfc6746c0a9c4d98b300a654c824d8ab92e35037.jpg",
--            "8e1c7d2237925a0b30cf3070b3003b6df1962974.jpg",
--            "ea23e114ccd3d14877f5ca4c8a39954df1057f4c.jpg",
--            "8549c8b1e92dd1d409e1d726b0d537306c07153a.jpg",
--            "7f4911dbe36288b946b909fa3dac69f8c37d959d.jpg"
--            
--        } --업로드할 이미지리스트(파일명) 테스트 데이타
        photolist = {}
    end    
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    bg:addEventListener("touch", 
        function(event)
            if(event.phase == "ended") then
                if (display_group.y < 0) then
                    transition.to(display_group, {y = 0, time=100, onComplete=nil})
                end

                native.setKeyboardFocus( nil )

                if(clearScreen() == true) then
                    return true
                end
            end
        end
    )
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["noticeEditScene"]["cancel"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_cancel_normal.png",
        overFile = "images/top_with_texts/btn_top_text_cancel_touched.png", 
    }

    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["noticeEditScene"]["ok"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_ok_normal.png",
        overFile = "images/top_with_texts/btn_top_text_ok_touched.png", 
    }

    local navBar = widget.newNavigationBar({
        title = language["noticeEditScene"]["title"],
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
    navBar:addEventListener("touch", 
        function() 
            if(clearScreen() == true) then
                return true
            end
        end 
    )
    group:insert(navBar)
    
    local nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    group:insert(nameRect)
    
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
    group:insert(labelTag)
    
    local rect = display.newRect(group, display.contentCenterX, 0, __appContentWidth__, __appContentHeight__)
    rect.anchorY = 0
    rect.y = nameRect.y + nameRect.height - 15
    rect.strokeWidth = 0
    rect:setFillColor( 1, 1, 1 )
    group:insert(rect)
    
    local selectClassGroup = display.newGroup()
    group:insert(selectClassGroup)
    
    local selectClassRect = display.newRect(group, display.contentCenterX, 0, __appContentWidth__, SELECT_CLASS_BAR)
    selectClassRect.anchorY = 0
    selectClassRect.y = rect.y 
    selectClassRect.strokeWidth = 0
    selectClassGroup:insert(selectClassRect)
    
    local selectClassText = display.newText(language["noticeEditScene"]["short_select_class"], 0, 0, native.systemFont, 12)
    selectClassText.anchorX = 0
    selectClassText.anchorY = 0
    selectClassText.x = 10
    selectClassText.y = selectClassRect.y + (selectClassRect.height - selectClassText.height)/2
    selectClassText:setFillColor( 0 )
    selectClassGroup:insert(selectClassText)
    
--    notice_toWhere = rowData.type,
--    notice_classid = rowData.class.id
    local class_name = ""
    if(event.params and event.params.notice_toWhere) then
        if(event.params.notice_toWhere == "1") then
            --전체
            class_name = ""
            selected_class_id = ""
        elseif(event.params.notice_toWhere == "2") then   
            --반
            if(event.params and event.params.notice_classid) then
                class_name = user.getClassName(event.params.notice_classid)
                selected_class_id = event.params.notice_classid
            else
                class_name = "" --전체
                selected_class_id = ""
            end
        end
    end
    
--    class_name = "" --테스트
    selectClassName = display.newText(class_name, 0, 0, native.systemFont, 12)
    selectClassName.anchorX = 0
    selectClassName.anchorY = 0
    selectClassName.x = selectClassText.x + selectClassText.width + 10
    selectClassName.y = selectClassRect.y + (selectClassRect.height - selectClassText.height)/2
    selectClassName:setFillColor( 0 )
    selectClassGroup:insert(selectClassName)
    if(class_name == "")then
        selectClassName.text = language["noticeEditScene"]["all_class"]
    end
    
    if (user.userData.jobType == __DIRECTOR__) then
        selectClassRect:setFillColor( 0.8, 0.8, 0.8 )
--        selectClassRect:setFillColor( 1, 1, 1 )  --
--        selectClassGroup:addEventListener("tap", 
--            function()
--                if(pickerList and pickerList.isShowing == true) then
--                    pickerList:closeUp()
--                    pickerList.isShowing = false
--                    
--                    return true
--                end
--                
--                viewClass()
--            end 
--        )
    elseif (user.userData.jobType == __TEACHER__) then    
        if #user.userData.ClassListOfTeacher > 1 then
            selectClassRect:setFillColor( 0.8, 0.8, 0.8 )
--            selectClassRect:setFillColor( 1, 1, 1 )  --
--            selectClassGroup:addEventListener("tap", 
--                function()
--                    if(pickerList and pickerList.isShowing == true) then
--                        pickerList:closeUp()
--                        pickerList.isShowing = false
--
--                        return true
--                    end
--
--                    viewClass()
--                end 
--            )
        else
            selectClassRect:setFillColor( 0.8, 0.8, 0.8 )
        end    
    end
    
    local line = display.newLine( 2, selectClassRect.y + SELECT_CLASS_BAR + 1, display.contentWidth - 2, selectClassRect.y + SELECT_CLASS_BAR + 1 )
    line:setStrokeColor( 0, 0, 0, 0.5)
    line.strokeWidth = 2
    group:insert(line)
    
    local line2= display.newLine( 2, rect.y + SELECT_CLASS_BAR + TITLE_TEXTBOX_HEIGHT + 1, display.contentWidth - 2, rect.y + SELECT_CLASS_BAR + TITLE_TEXTBOX_HEIGHT + 1 )
    line2:setStrokeColor( 0, 0, 0, 0.5)
    line2.strokeWidth = 2
    group:insert(line2)
    
    imageScrollView = widget.newScrollView
    {
--        top = 0,
--        left = 0,
        width = __appContentWidth__,
        height = 60,
        scrollWidth = __appContentWidth__,
        scrollHeight = 0,
        verticalScrollDisabled = true,
        hideBackground = true,
        listener =  function(event)
                        if(event.phase == "ended") then
                            if(clearScreen() == true) then
                                return true
                            end
                        end
                        
                        return true
                    end
    }    
    imageScrollView.anchorX = 0
    imageScrollView.anchorY = 0
    imageScrollView.x = 0
    imageScrollView.y = nameRect.y + nameRect.height + TITLE_TEXTBOX_HEIGHT + CONTENT_TEXTBOX_HEIGHT + SELECT_CLASS_BAR - 5
    group:insert(imageScrollView)
    
    photolistGroup = {} -- 
    local photoImageSize = 60
    local startX = 5
    local function deleteImg(event)
        if(clearScreen() == true) then
            return true
        end

        local function remove_photolist_add(filename)
            for i = 1, #photolist_add do
                if(photolist_add[i] == filename) then
                    table.remove(photolist_add, i)

                    return true
                end
            end

            return false
        end

        local obj = event.target    
        native.showAlert(language["appTitle"], language["noticeEditScene"]["delete_photo"], 
            { language["noticeEditScene"]["yes"], language["noticeEditScene"]["no"] }, 
            function(event)
                if "clicked" == event.action then
                    local i = event.index
                    if 1 == i then
                        for i = 1, #photolist do
                            if(obj.name == photolist[i]) then
                                local startIndex = i + 1
                                for j = startIndex, #photolistGroup do
                                    local child = photolistGroup[j]
                                    if(child) then
                                        local originX = child.x
                                        transition.to( child, { time=200, x=(originX - photoImageSize - 5), nil})

                                        local originX = child.deleteIcon.x
                                        transition.to( child.deleteIcon, { time=200, x=(originX - photoImageSize - 5), nil})
                                    end
                                end

                                if(remove_photolist_add(photolist[i]) == false) then
                                    local params = {
                                        center_id = user.userData.centerid,
                                        notice_id = notice_id,
                                        filename = photolist[i],
                                    }
                                    api.delete_notice_image(params, function() end)
                                end

                                display.remove(photolistGroup[i].deleteIcon)
                                table.remove(photolist, i)
                                table.remove(photolistGroup, i)
                                display.remove(obj)

                                break
                            end
                        end
                    end
                end    
            end
        )
    end
    
    local addPhotoButton = widget.newButton
    {
        width = photoImageSize,
        height = photoImageSize,
        defaultFile = "images/assets1/icon_photo.png",
        overFile = "images/assets1/icon_photo.png",
        fontSize = __buttonFontSize__,
        onRelease = addPhoto,
    }
    addPhotoButton.anchorX = 0
    addPhotoButton.anchorY = 0
    addPhotoButton.x = startX
    addPhotoButton.y = (imageScrollView.contentHeight - addPhotoButton.height) / 2
    imageScrollView:insert(addPhotoButton)
    
    for i = 1, #photolist do
        photolistGroup[i] = display.newImageRect(photolist[i], system.TemporaryDirectory, 0, 0 )
        photolistGroup[i].width = photoImageSize
        photolistGroup[i].height = photoImageSize
        photolistGroup[i].anchorX = 0
        photolistGroup[i].anchorY = 0
        
        if(i==1) then
            photolistGroup[i].x = addPhotoButton.x + addPhotoButton.width + 5
        else
            local tmp = photolistGroup[i-1]
            photolistGroup[i].x = tmp.x + tmp.width + 5
        end
        
        photolistGroup[i].y = 0
        photolistGroup[i].name = photolist[i]
        imageScrollView:insert(photolistGroup[i])
        
        photolistGroup[i].deleteIcon = display.newImageRect("images/assets1/icon_delete_photo.png", 20, 20)
        photolistGroup[i].deleteIcon.anchorX = 0
        photolistGroup[i].deleteIcon.anchorY = 0
        photolistGroup[i].deleteIcon.x = photolistGroup[i].x + photolistGroup[i].width - photolistGroup[i].deleteIcon.width
        photolistGroup[i].deleteIcon.y = photolistGroup[i].height - photolistGroup[i].deleteIcon.height
        imageScrollView:insert(photolistGroup[i].deleteIcon)
        
        photolistGroup[i]:addEventListener("tap", deleteImg)
    end
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.returnTo = "scripts.noticeScene"
        
    local function title_inputListener( event )
        if event.phase == "began" then
            if (display_group.y < 0) then
                transition.to(display_group, {y = 0, time=100, onComplete=nil})
            end
            
            if (sharePanel and sharePanel.isShowing == true) then
                sharePanel:hide()
                sharePanel.isShowing = false
            end    
            
            if(pickerList and pickerList.isShowing == true) then
               pickerList:closeUp()
               
               pickerList.isShowing = false
            end
        elseif (event.phase == "submitted") then
            native.setKeyboardFocus(content_textBox)
        elseif event.phase == "editing" then
            print( event.text )
            
        end
    end
    
    local function contents_inputListener( event )
        if event.phase == "began" then
            transition.to(display_group, {y = - contentField_Move_Y, time=100, onComplete=nil})
            if(button_keyboardOnOff) then
                button_keyboardOnOff.isVisible = true
            end
            
            if (sharePanel and sharePanel.isShowing == true) then
                sharePanel:hide()
                sharePanel.isShowing = false
            end    
            if(pickerList and pickerList.isShowing == true) then
               pickerList:closeUp()
               pickerList.isShowing = false
            end
            
--            transition.to(group, {y = group.y - 100, time=100, onComplete=nil})
        elseif event.phase == "ended" then
--            native.setKeyboardFocus(nil)
        elseif event.phase == "editing" then
            print( event.text )
            
        end
    end
    
    title_textBox = native.newTextField(display.contentCenterX, 
            TITLE_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + SELECT_CLASS_BAR, 
            display.contentWidth - 2, TITLE_TEXTBOX_HEIGHT)
    title_textBox.text = ""        
    title_textBox.placeholder = language["noticeEditScene"]["input_title"]
    title_textBox.hasBackground = false
    title_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(title_textBox)
    local title_text = sceneData.getSceneDataWithUID("noticeTitle")
    if(title_text) then
        title_textBox.text = title_text
    end
    title_textBox:addEventListener("userInput", title_inputListener)
    
    content_textBox = native.newTextBox(display.contentCenterX,
            CONTENT_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + TITLE_TEXTBOX_HEIGHT + SELECT_CLASS_BAR + 3,
            display.contentWidth - 2 , 
            CONTENT_TEXTBOX_HEIGHT)
    content_textBox.text = ""
    content_textBox.placeholder = language["noticeEditScene"]["input_contents"]
    content_textBox.isEditable = true
    content_textBox.strokeWidth = 0
    content_textBox.hasBackground = false
    content_textBox:addEventListener( "userInput", contents_inputListener )
    content_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(content_textBox)
    local content_text = sceneData.getSceneDataWithUID("noticeContents")
    if(content_text) then
        content_textBox.text = content_text
    end
    
    button_keyboardOnOff = widget.newButton
    {
        left = 0,
        top = 0,
        width = 60,
        height = 20,
        font = native.systemFont,
        fontSize = 10,
        defaultFile = "images/assets1/btn_key_off.png",
        overFile = "images/assets1/btn_key_off.png",
        onRelease = function(event)
                        native.setKeyboardFocus(nil)
                        
                        if (display_group.y < 0) then
                            transition.to(display_group, {y = 0, time=100, onComplete=nil})
                        end
                        
                        button_keyboardOnOff.isVisible = false
                    end,
    }
    button_keyboardOnOff.anchorX = 0
    button_keyboardOnOff.anchorY = 0
    button_keyboardOnOff.x = __appContentWidth__ - button_keyboardOnOff.width - 10
    button_keyboardOnOff.y = imageScrollView.y + imageScrollView.height + 2
    button_keyboardOnOff.isVisible = false
    group:insert(button_keyboardOnOff)
--    native.setKeyboardFocus(content_textBox)
    
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    native.setKeyboardFocus(nil)
    
    if(title_textBox) then
        title_textBox:removeSelf()
        title_textBox = nil
    end
    
    if(content_textBox) then
        content_textBox:removeSelf()
        content_textBox = nil
    end
    
    for i = #photolistGroup, 1 do
        local child = photolistGroup[i]
        if(child) then
            display.remove(child)
        end
    end
    
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





