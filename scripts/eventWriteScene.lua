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
local loadsave = require("scripts.loadsave")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local IMAGE_MAX_COUNT = 5
local SELECT_CLASS_BAR = 30
local MAP_BUTTON_WIDTH = 70

local sharePanel

local photolist --파일명
local photolistGroup    --파일명으로 만든 오브젝트 이미지

local content_textBox
local title_textBox
local address_textBox

local CONTENT_TEXTBOX_HEIGHT = 100
local TITLE_TEXTBOX_HEIGHT = 40
local activityIndicator

--local pickerList
local classPickerList
local datePickerList

local selected_class_id
local selectClassName
local selectedEventDate
local contentField_Move_Y = 100
local addressField_Move_Y = 170
local pickerList_Move_Y = 50
local button_keyboardOnOff
local display_group
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function saveTempFile()
    local dataTable = {}
    dataTable.member_id = user.userData.id --작성자 아이디
    dataTable.title = title_textBox.text --제목
    dataTable.contents = content_textBox.text --내용
    dataTable.address = address_textBox.text --주소
                
    loadsave.saveTable(dataTable, __TMP_FILE_EVENT_WRITE__, system.DocumentsDirectory)
end

local function clearScreen()
    native.setKeyboardFocus(nil)
    
    if (display_group.y < 0) then
        transition.to(display_group, {y = 0, time=100, onComplete=nil})
    end
    
    if (button_keyboardOnOff) then
        button_keyboardOnOff.isVisible = false
    end
    
    if (classPickerList and classPickerList.isShowing == true) then
       classPickerList:closeUp()
    end

    if (datePickerList and datePickerList.isShowing == true) then
       datePickerList:closeUp()
    end
    
    if (sharePanel and sharePanel.isShowing == true) then
        sharePanel:hide()
        sharePanel.isShowing = false
        
        return true
    end
end

local function freeMemoryAndGo(needRefresh)
    sceneData.freeSceneDataWithUID("photolist")
    sceneData.freeSceneDataWithUID("eventContents")
    sceneData.freeSceneDataWithUID("eventTitle")
    sceneData.freeSceneDataWithUID("eventDate")
    sceneData.freeSceneDataWithUID("mapAddress")
    sceneData.freeSceneDataWithUID("photolist_add")
    sceneData.freeSceneDataWithUID("selectedClassId")
    
    if(needRefresh and needRefresh == true) then
        storyboard.purgeScene("scripts.eventScene")
    end
    
    storyboard.gotoScene("scripts.eventScene", "slideRight", 300)
end

local function addPhoto(event)
    if(clearScreen() == true) then
        return true
    end
    
    sceneData.addSceneDataWithUID("photolist", photolist)
    
    if(title_textBox and title_textBox.text ~= "") then
        sceneData.addSceneDataWithUID("eventTitle", title_textBox.text)
    end
    
    if(content_textBox and content_textBox.text ~= "") then
        sceneData.addSceneDataWithUID("eventContents", content_textBox.text)
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
                if(data.event_id) then
                    local event_id = data.event_id
                    if(photolist and #photolist > 0) then
                        local photoCount = #photolist
                        local uploadingCount = 0
                        local uploadedCount = 0
                        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["image_upload"])
                        
                        for i = 1, photoCount do
                            if (utils.fileExist(photolist[i], system.TemporaryDirectory) == true) then
                                uploadingCount = uploadingCount + 1
                                
                                local params = {
                                    center_id = user.userData.centerid,
                                    event_id = event_id,
                                    filename = photolist[i],
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

local function onLeftButton(event)
    local function isSavedThread()
        if (utils.fileExist(__TMP_FILE_EVENT_WRITE__, system.DocumentsDirectory) == true) then
            local tmpData = loadsave.loadTable(__TMP_FILE_EVENT_WRITE__, system.DocumentsDirectory)
            if(tmpData.member_id == user.userData.id and tmpData.title == title_textBox.text 
                and tmpData.contents == content_textBox.text and tmpData.address == address_textBox.text) then

                return true
            else
                return false
            end
        else
            return false
        end
    end
    
    if event.phase == "ended" then
        if(clearScreen() == true) then
            return true
        end
        
--        if (__deviceType__ == "iphone") then
--            if (content_textBox.text == language["eventWriteScene"]["input_contents"]) then
--                content_textBox.text = ""
--            end
--        end
        
        if(title_textBox.text ~= "" or content_textBox.text ~= "" ) then
            if isSavedThread() == false then
                native.showAlert(language["appTitle"], language["eventWriteScene"]["delete_question"], 
                    { language["eventWriteScene"]["yes"], language["eventWriteScene"]["no"] }, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                                freeMemoryAndGo(false)    
                            end    
                        end    
                    end
                )
            else
                freeMemoryAndGo(false)    
            end
        else
            freeMemoryAndGo(false)    
        end
    end
    
    return true
end

local function onRightSideButton(event)
    if(event.phase == "ended") then
        utils.showMessage(language["eventWriteScene"]["temp_save"])
        
        saveTempFile()
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
                local toWhere  -- (1:all class, 2:only 1 class)
                if(selected_class_id and selected_class_id == "0") then --전체반 선택
                    toWhere = 1 --전체 반
                    selected_class_id = "" --전체 반의경우 공백
                else
                    toWhere = 2 --한개 반
                end
                local params = {}
                params.type = toWhere
                params.center_id = user.userData.centerid
                params.class_id = selected_class_id
                params.member_id = user.userData.id
                params.title = title_textBox.text
                params.contents = content_textBox.text
                params.address = address_textBox.text
                
                local eventDate = sceneData.getSceneDataWithUID("eventDate")
                local strEventDate = ""
                if(eventDate and eventDate.year and eventDate.year ~= "") then
                    strEventDate = eventDate.year..eventDate.month..eventDate.day
                end
                
                params.date = strEventDate
                
                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                api.post_event_contents(params, getDataCallback)
            else
                utils.showMessage(language["eventWriteScene"]["input_contents"])
                native.setKeyboardFocus(content_textBox) 
                
                return true
            end
        else
            utils.showMessage(language["eventWriteScene"]["input_title"])
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
    
    local startIndexClass = 1 -- default
    local classes = {}
    local class_label = {}
    if user.userData.jobType == __DIRECTOR__ then
        local class_cnt = #user.classList
        classes[1] = {id = "0",name = language["eventWriteScene"]["all_class"], desc = ""}
        class_label[1] = language["eventWriteScene"]["all_class"]
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
        {
            align = "center",
            width = __appContentWidth__- 50,
            startIndex = startIndexClass,
            labels = class_label
        },
    
    }  
        
    classPickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
--            pickerHeight = 130,
            pickerData = columnData,
            titleText = language["eventWriteScene"]["select_class"],
--            onScroll = nil,
            okButtonText = language["eventWriteScene"]["ok"],
            onClose =   function()
                            native.setKeyboardFocus(title_textBox)
                            classPickerList.isShowing = false
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                local obj = event.target
                                local value = classPickerList.pickerWheel:getValues()
                                print(value[1].value)
                                print(value[1].index)
                                local classData = classes[value[1].index]
                                
                                selected_class_id = classData.id
                                selectClassName.text = classData.name
                                
                                sceneData.addSceneDataWithUID("selectedClassId", selected_class_id)
                                
                                classPickerList:closeUp()
                            end
                            
                            return true
                        end,
        }
    )
    classPickerList.isShowing = true
       
    return true
end

local function onAddDateButtonClick(event)
    clearScreen()
    
    if (display.contentHeight <= 480 ) then
        transition.to(display_group, {y = - pickerList_Move_Y, time=100, onComplete=nil})
    end
    
    local selectedYear
    local selectedMonth
    local selectedDay
    
    local days = {}
    local years = {}
        
    -- Populate the "days" table
    for d = 1, 31 do
        days[d] = d..language["eventWriteScene"]["day"]
    end
        
    -- Populate the "years" table
    local currentYear = os.date( "%Y" )
    local startYear = currentYear - 1;
    for y = 1, 3 do
        years[y] = (startYear + y) ..language["eventWriteScene"]["year"]
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
        datePickerList.pickerWheel._view._didTap = false
        local values = event.values
--        utils.printTable(values)
        selectedYear  = tonumber(string.sub(values[1].value, 1, 4));
        selectedMonth = values[2].index;
            
        local a, b = string.find(values[3].value, language["eventWriteScene"]["day"])
        selectedDay = tonumber(string.sub(values[3].value, 1, a-1));
    end  
        
    if (selectedYear == nil) or (selectedMonth == nil) or (selectedDay == nil) then
        local date = os.date( "*t" );
        selectedYear = date.year;
        selectedMonth = date.month;
        selectedDay = date.day;
    end
    columnData[1].startIndex =  1--100 - (os.date( "%Y" ) - tonumber(selectedYear));
    columnData[2].startIndex = tonumber(selectedMonth);
    columnData[3].startIndex = tonumber(selectedDay);
        
    datePickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
--            editField = row.pickerField,
            pickerData = columnData,
            titleText = language["eventWriteScene"]["input_date"],
            onScroll = onScroll,
            okButtonText = language["eventWriteScene"]["ok"],
            onClose =   function()
--                            native.setKeyboardFocus(title_textBox)
                            datePickerList.isShowing = false
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                if (utils.isValidDate(selectedYear, selectedMonth, selectedDay) == true) then
                                    local strYear = string.format("%04d",selectedYear)
                                    local strMonth = string.format("%02d",selectedMonth)
                                    local strDay = string.format("%02d",selectedDay)
                                    selectedEventDate.text = utils.convert2LocaleDateString(strYear, strMonth, strDay)
                                    local eventDate = {year = strYear, month = strMonth, day = strDay}
                                    sceneData.addSceneDataWithUID("eventDate", eventDate)
                                    
                                    datePickerList:closeUp()
                                else
                                    utils.showMessage(language["date_format"]["invalid_date"])
                                end
                            end
                            
                            return true
                        end,
        }
    ) 
    datePickerList.isShowing = true   
       
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    display_group = group
    
--    photolist = sceneData.getSceneDataWithUID("photolist")
--    if(photolist == nil) then
--        photolist = {
--            "d5b9157879a02053708ebfeeef41f0a8964ca02a.jpg",
--            "bfc6746c0a9c4d98b300a654c824d8ab92e35037.jpg",
--            "8e1c7d2237925a0b30cf3070b3003b6df1962974.jpg",
--            "ea23e114ccd3d14877f5ca4c8a39954df1057f4c.jpg",
--            "8549c8b1e92dd1d409e1d726b0d537306c07153a.jpg",
--            "7f4911dbe36288b946b909fa3dac69f8c37d959d.jpg"
--            
--        } --업로드할 이미지리스트(파일명) 테스트 데이타
--        photolist = {}
--    end    
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    bg:addEventListener("touch", 
        function(event) 
            if(event.phase == "ended") then
                if(clearScreen() == true) then
                    return true
                end
            end
        end 
    )
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["eventWriteScene"]["cancel"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_cancel_normal.png",
        overFile = "images/top_with_texts/btn_top_text_cancel_touched.png", 
    }

--    local btn_right_opt = {
--        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
--        label = "확인",
--        onEvent = onRightButton,
--        width = 100,
--        height = 50,
--        font = native.systemFont,
--        fontSize = __buttonFontSize__,
--        defaultFile = "images/top_with_texts/btn_top_text_ok_normal.png",
--        overFile = "images/top_with_texts/btn_top_text_ok_touched.png", 
--    }
    
    
    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
--        label = "확인",
        onEvent = onRightButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 35,
        height = 50,
        defaultFile = "images/top/btn_top_edit2_normal.png",
        overFile = "images/top/btn_top_edit2_touched.png",    
    }
    local btn_rightSide_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
--        label = "임시",
        onEvent = onRightSideButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 35,
        height = 50,
        defaultFile = "images/top/btn_top_save_normal.png",
        overFile = "images/top/btn_top_save_touched.png",    
    }

    local navBar = widget.newNavigationBar({
        title = language["eventWriteScene"]["title"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
        rightSideButton = btn_rightSide_opt,
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
    
    local selectClassText = display.newText(language["eventWriteScene"]["short_select_class"], 0, 0, native.systemFont, 12)
    selectClassText.anchorX = 0
    selectClassText.anchorY = 0
    selectClassText.x = 10
    selectClassText.y = selectClassRect.y + (selectClassRect.height - selectClassText.height)/2
    selectClassText:setFillColor( 0 )
    selectClassGroup:insert(selectClassText)
    
    selected_class_id = sceneData.getSceneDataWithUID("selectedClassId")
    local class_name
    if(selected_class_id) then
        class_name = user.getClassName(selected_class_id)
    else
        class_name = user.getClassName(user.userData.classId)
    end
    
--    class_name = "" --테스트용
    selectClassName = display.newText(class_name, 0, 0, native.systemFont, 12)
    selectClassName.anchorX = 0
    selectClassName.anchorY = 0
    selectClassName.x = selectClassText.x + selectClassText.width + 10
    selectClassName.y = selectClassRect.y + (selectClassRect.height - selectClassText.height)/2
    selectClassName:setFillColor( 0 )
    selectClassGroup:insert(selectClassName)
    if(class_name == "")then
        selected_class_id = ""
        selectClassName.text = language["eventWriteScene"]["all_class"]
    else
        selected_class_id = user.userData.classId
    end
    
    if (user.userData.jobType == __DIRECTOR__) then
        selectClassRect:setFillColor( 1, 1, 1 )  --
        selectClassGroup:addEventListener("touch", 
            function(event)
                if event.phase == "ended" then
                    viewClass()
                end
                
                return true
            end 
        )
    elseif (user.userData.jobType == __TEACHER__) then    
        if #user.userData.ClassListOfTeacher > 1 then
            selectClassGroup:addEventListener("touch", 
                function(event)
                    if event.phase == "ended" then
                        viewClass()
                    end

                    return true
                end 
            )
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
    
    local line3= display.newLine( 2, line2.y + CONTENT_TEXTBOX_HEIGHT + 4, display.contentWidth - 2, line2.y + CONTENT_TEXTBOX_HEIGHT + 4)
    line3:setStrokeColor( 0, 0, 0, 0.5)
    line3.strokeWidth = 2
    group:insert(line3)
    
    
--    local imageScrollView = widget.newScrollView
--    {
----        top = 0,
----        left = 0,
--        width = __appContentWidth__,
--        height = 60,
--        scrollWidth = __appContentWidth__,
--        scrollHeight = 0,
--        verticalScrollDisabled = true,
--        hideBackground = true,
--        listener =  function(event)
--                        if(event.phase == "ended") then
--                            if(clearScreen() == true) then
--                                return true
--                            end
--                        end
--                        
--                        return true
--                    end
--    }    
--    imageScrollView.anchorX = 0
--    imageScrollView.anchorY = 0
--    imageScrollView.x = 0
--    imageScrollView.y = nameRect.y + nameRect.height + TITLE_TEXTBOX_HEIGHT + CONTENT_TEXTBOX_HEIGHT + SELECT_CLASS_BAR - 5
--    group:insert(imageScrollView)
--    
--    photolistGroup = {} -- 
--    local photoImageSize = 60
--    local startX = 5
--    local function deleteImg(event)
--        if(clearScreen() == true) then
--            return true
--        end
--            
--        local obj = event.target    
--        native.showAlert("KidsUp", "선택한 사진을 삭제 하시겠습니까?", { "확인", "취소" }, 
--            function(event)
--                if "clicked" == event.action then
--                    local i = event.index
--                    if 1 == i then
--                        for i = 1, #photolist do
--                            if(obj.name == photolist[i]) then
--                                local startIndex = i + 1
--                                for j = startIndex, #photolistGroup do
--                                    local child = photolistGroup[j]
--                                        if(child) then
--                                            local originX = child.x
--
--                                            transition.to( child, { time=200, x=(originX - photoImageSize - 5), nil})
--                                        end
--                                    end
--
--                                    table.remove(photolist, i)
--                                    table.remove(photolistGroup, i)
--                                    display.remove(obj)
--
--                                    break
--                                end
--                            end
--                    end
--                end    
--            end
--        )
--        
--        return true
--    end
--    
--    local addPhotoButton = widget.newButton
--    {
--        width = photoImageSize,
--        height = photoImageSize,
--        defaultFile = "images/assets1/icon_photo.png",
--        overFile = "images/assets1/icon_photo.png",
--        fontSize = __buttonFontSize__,
--        onRelease = addPhoto,
--    }
--    addPhotoButton.anchorX = 0
--    addPhotoButton.anchorY = 0
--    addPhotoButton.x = startX
--    addPhotoButton.y = (imageScrollView.contentHeight - addPhotoButton.height) / 2
--    imageScrollView:insert(addPhotoButton)
--    
--    local notExistFileindex = {}
--    for i = 1, #photolist do
--        if(utils.fileExist(photolist[i], system.TemporaryDirectory) == true) then
--            photolistGroup[i] = display.newImageRect(photolist[i], system.TemporaryDirectory, 0, 0 )
--            photolistGroup[i].width = photoImageSize
--            photolistGroup[i].height = photoImageSize
--            photolistGroup[i].anchorX = 0
--            photolistGroup[i].anchorY = 0
--
--            if(i==1) then
--                photolistGroup[i].x = addPhotoButton.x + addPhotoButton.width + 5
--            else
--                local tmp = photolistGroup[i-1]
--                photolistGroup[i].x = tmp.x + tmp.width + 5
--            end
--
--            photolistGroup[i].y = 0
--            photolistGroup[i].name = photolist[i]
--            imageScrollView:insert(photolistGroup[i])
--            photolistGroup[i]:addEventListener("tap", deleteImg)
--        else
--            table.insert(notExistFileindex, i) --존재하지 않는 파일 얻기
--        end
--    end
--    
--    for i = #photolist, 1 , -1 do --존재하지 않는 파일 photolist에서 삭제
--        for j = 1, #notExistFileindex do
--            if(i == notExistFileindex[j]) then
--                table.remove(photolist, i)
--                
--                break
--            end
--        end
--    end
    
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    local function title_inputListener( event )
        if event.phase == "began" then
            if (display_group.y < 0) then
                transition.to(display_group, {y = 0, time=100, onComplete=nil})
            end
            
            if (sharePanel and sharePanel.isShowing == true) then
                sharePanel:hide()
                sharePanel.isShowing = false
            end
            
            if (classPickerList and classPickerList.isShowing == true) then
               classPickerList:closeUp()
            end
            
            if (datePickerList and datePickerList.isShowing == true) then
               datePickerList:closeUp()
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
            
            if (classPickerList and classPickerList.isShowing == true) then
               classPickerList:closeUp()
            end
            
            if (datePickerList and datePickerList.isShowing == true) then
               datePickerList:closeUp()
            end
        elseif event.phase == "ended" then
        elseif event.phase == "editing" then
            print( event.text )
            
        end
    end
    
    local function address_inputListener( event )
        local obj = event.target
        if event.phase == "began" then
            transition.to(display_group, {y = - addressField_Move_Y, time=100, onComplete=nil})
            
            if(button_keyboardOnOff) then
                button_keyboardOnOff.isVisible = true
            end
            
            if (sharePanel and sharePanel.isShowing == true) then
                sharePanel:hide()
                sharePanel.isShowing = false
            end
                        
            if (classPickerList and classPickerList.isShowing == true) then
               classPickerList:closeUp()
            end
            
            if (datePickerList and datePickerList.isShowing == true) then
               datePickerList:closeUp()
            end            
        elseif (event.phase == "submitted") then
--            native.setKeyboardFocus(content_textBox)
            if (display_group.y < 0) then
                transition.to(display_group, {y = 0, time=100, onComplete=nil})
            end
        elseif (event.phase == "ended") then
--            native.setKeyboardFocus(nil)
        elseif event.phase == "editing" then
            print( event.text )
        end
    end
    
    title_textBox = native.newTextField(display.contentCenterX, 
            TITLE_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + SELECT_CLASS_BAR, 
            display.contentWidth - 2, TITLE_TEXTBOX_HEIGHT)
    title_textBox.text = ""        
    title_textBox.placeholder = language["eventWriteScene"]["input_title"]
    title_textBox.hasBackground = false
    title_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(title_textBox)
    
    local title_text = sceneData.getSceneDataWithUID("eventTitle")
    if(title_text) then
        title_textBox.text = title_text
    end
    title_textBox:addEventListener("userInput", title_inputListener)
    
    content_textBox = native.newTextBox(display.contentCenterX,
            CONTENT_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + TITLE_TEXTBOX_HEIGHT + SELECT_CLASS_BAR + 3,
            display.contentWidth - 2, 
            CONTENT_TEXTBOX_HEIGHT)
    content_textBox.text = ""
    content_textBox.placeholder = language["eventWriteScene"]["input_contents"]
    content_textBox.isEditable = true
    content_textBox.strokeWidth = 0
    content_textBox.hasBackground = false
    content_textBox:addEventListener( "userInput", contents_inputListener )
    content_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(content_textBox)
    
    local content_text = sceneData.getSceneDataWithUID("eventContents")
    if(content_text) then
        content_textBox.text = content_text
    end
    
--    if (__deviceType__ == "iphone") then
--        if(content_textBox.text == "") then
--            content_textBox.text = language["eventWriteScene"]["input_contents"]
--        end
--    end
    native.setKeyboardFocus(title_textBox)
    
    local address_textBox_LocX = (__appContentWidth__ - 80)/2 + 1
    local address_textBox_LocY = TITLE_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT 
            + SELECT_CLASS_BAR + CONTENT_TEXTBOX_HEIGHT + TITLE_TEXTBOX_HEIGHT + 6
    local address_textBox_width = display.contentWidth - MAP_BUTTON_WIDTH - 10        
    address_textBox = native.newTextField(address_textBox_LocX, address_textBox_LocY, address_textBox_width, TITLE_TEXTBOX_HEIGHT)
    address_textBox.text = ""
    address_textBox.placeholder = language["eventWriteScene"]["map_desc"]
    address_textBox.hasBackground = false
    address_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE_SMALL__)
    group:insert(address_textBox)
    address_textBox:addEventListener("userInput", address_inputListener)
    local address_text = sceneData.getSceneDataWithUID("mapAddress")
    if(address_text) then
        address_textBox.text = address_text
    end
    print(address_textBox.y)
    
    local mapButton = widget.newButton
    {
        left = 0,
        top = 0,
        width = MAP_BUTTON_WIDTH,
        height = 30,
        font = native.systemFont,
        fontSize = 10,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        defaultFile = "images/button_small/btn_small_red_4_normal.png",
        overFile = "images/button_small/btn_small_red_4_touched.png",
--        defaultFile = "images/assets1/btn_map.png",
--        overFile = "images/assets1/btn_map.png",
        label = language["eventWriteScene"]["map_confirm"],
        onRelease = function(event)
                        if(event.phase == "ended") then
                            if(address_textBox.text ~= "") then
                                sceneData.addSceneDataWithUID("mapAddress", address_textBox.text)
                                sceneData.addSceneDataWithUID("eventContents", content_textBox.text)
                                sceneData.addSceneDataWithUID("eventTitle", title_textBox.text)
                                storyboard.isAction = true
                                storyboard.purgeScene("scripts.mapViewScene")
                                storyboard.gotoScene("scripts.mapViewScene", "slideLeft", 300)
                            else
                                utils.showMessage(language["eventWriteScene"]["input_address"])
                                native.setKeyboardFocus(address_textBox) 
                            end
                        end
                    end,
    }
    mapButton.anchorX = 0
    mapButton.anchorY = 0
    mapButton.x = address_textBox_width + 5
    mapButton.y = address_textBox_LocY - mapButton.height/2
    group:insert(mapButton)
    
    local line= display.newLine( 2, address_textBox_LocY + TITLE_TEXTBOX_HEIGHT/2 + 2, display.contentWidth - 2, address_textBox_LocY + TITLE_TEXTBOX_HEIGHT/2 + 2)
    line:setStrokeColor( 0, 0, 0, 0.5)
    line.strokeWidth = 2
    group:insert(line)
    
    local eventDateGroup = display.newGroup()
    group:insert(eventDateGroup)
    
    local eventDateRect = display.newRect(group, 0, 0, __appContentWidth__, SELECT_CLASS_BAR)
    eventDateRect.anchorX = 0
    eventDateRect.anchorY = 0
    eventDateRect.x = 0
    eventDateRect.y = line.y 
    eventDateRect.strokeWidth = 0
--    eventDateRect:setFillColor(1, 0, 0, 1)
    eventDateGroup:insert(eventDateRect)
    
    local eventDateText = display.newText(language["eventWriteScene"]["short_input_date"], 0, 0, native.systemFont, 12)
    eventDateText.anchorX = 0
    eventDateText.anchorY = 0
    eventDateText.x = 10
    eventDateText.y = eventDateRect.y + (eventDateRect.height - eventDateText.height)/2
    eventDateText:setFillColor( 0 )
    eventDateGroup:insert(eventDateText)
    eventDateGroup:addEventListener("touch", 
        function(event)
            if event.phase == "ended" then
                print("eventDateGroup:addEventListener")
--                if(datePickerList and datePickerList.isShowing == true) then
--                    datePickerList:closeUp()
--                    pickerList.isShowing = false
--
--                    return true
--                end

                onAddDateButtonClick()
            end
            
            return true
        end 
    )
    
    local eventDate_data = sceneData.getSceneDataWithUID("eventDate")
    local eventDate_txt
    if(eventDate_data and eventDate_data.year and eventDate_data.year ~= "") then
        eventDate_txt = utils.convert2LocaleDateString(eventDate_data.year, eventDate_data.month, eventDate_data.day)
    else
        eventDate_txt = ""
    end
    selectedEventDate = display.newText(eventDate_txt, 0, 0, native.systemFont, 12)
    selectedEventDate.anchorX = 0
    selectedEventDate.anchorY = 0
    selectedEventDate.x = eventDateText.x + eventDateText.width + 10
    selectedEventDate.y = eventDateText.y
    selectedEventDate:setFillColor( 0 )
    eventDateGroup:insert(selectedEventDate)
    
    if (utils.fileExist(__TMP_FILE_EVENT_WRITE__, system.DocumentsDirectory) == true) then
        local tmpData = loadsave.loadTable(__TMP_FILE_EVENT_WRITE__, system.DocumentsDirectory)
        if(tmpData.member_id == user.userData.id) then
            native.showAlert(language["appTitle"], language["eventWriteScene"]["read_question"], 
                { language["eventWriteScene"]["yes"], language["eventWriteScene"]["no"] }, 
                function(event)
                    if "clicked" == event.action then
                        local i = event.index
                        if 1 == i then
                            title_textBox.text = tmpData.title
                            content_textBox.text = tmpData.contents
                            address_textBox.text = tmpData.address
                            
                            utils.deleteFile(__TMP_FILE_EVENT_WRITE__, system.DocumentsDirectory)
                        end    
                    end    
                end
            )
        end
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
    button_keyboardOnOff.y = eventDateRect.y + eventDateRect.height + 2
    button_keyboardOnOff.isVisible = false
    group:insert(button_keyboardOnOff)
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.eventScene"
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
    
    if(address_textBox) then
        address_textBox:removeSelf()
        address_textBox = nil
    end
    
    if (button_keyboardOnOff) then
        button_keyboardOnOff:removeSelf()
        button_keyboardOnOff = nil
    end
    
    if (sharePanel) then
        sharePanel.isShowing = false
        sharePanel:hide()
    end
    
--    if(pickerList) then
--        pickerList:closeUp()
--        pickerList.isShowing = false
--    end
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







