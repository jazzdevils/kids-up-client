---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.widget_sharePanelEx")
require("widgets.widgetext")
require("widgets.activityIndicator")
require("widgets.widget_editfield")

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

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local IMAGE_MAX_COUNT = 1
local SELECT_CLASS_BAR = 30

local sharePanel

local photolist --파일명

local content_textBox
local CONTENT_TEXTBOX_HEIGHT = 100

local activityIndicator
local pickerList
local menuDate_data
local selectedDate
local imageScrollView
local button_keyboardOnOff
local display_group
local contentField_Move_Y = 100

---------------------------------------------------------------------------
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
    end
    
    if (sharePanel and sharePanel.isShowing == true) then
        sharePanel:hide()
        sharePanel.isShowing = false
        
        return true
    end
end

local function addPhoto(event)
    native.setKeyboardFocus(nil)
    
    if (display_group.y < 0) then
        transition.to(display_group, {y = 0, time=100, onComplete=nil})
    end
    
    if(clearScreen() == true) then
        return true
    end
    
    sceneData.addSceneDataWithUID("photolist", photolist)
    if(content_textBox and content_textBox.text ~= "") then
        sceneData.addSceneDataWithUID("mealMenuContents", content_textBox.text)
    end
    
    if (sharePanel and sharePanel.isShowing == true) then
        sharePanel:hide()
        sharePanel.isShowing = false
    else
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
    end
    
    return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        sceneData.freeSceneDataWithUID("photolist")
        sceneData.freeSceneDataWithUID("mealMenuContents")
        sceneData.freeSceneDataWithUID("mealMenuDate")
        
        if (clearScreen() == true) then
            return true
        end
        
        storyboard.gotoScene("scripts.mealMenuListScene", "slideRight", 300)
    end
    
    return true
end

local function getDataCallback(event)
    if(event.isError) then
        print("Post error")    
        activityIndicator:destroy()
        sceneData.freeSceneDataWithUID("photolist")
        sceneData.freeSceneDataWithUID("mealMenuContents")
        sceneData.freeSceneDataWithUID("mealMenuDate")
        utils.showMessage(language["common"]["wrong_connection"])
    elseif(event.phase == "ended") then
        activityIndicator:destroy()
        local data = json.decode(event.response)
        if (data) then
            if(data.status == "OK") then
                sceneData.freeSceneDataWithUID("photolist")
                sceneData.freeSceneDataWithUID("mealMenuContents")
                sceneData.freeSceneDataWithUID("mealMenuDate")
                                                                                                                                
                storyboard.purgeScene("scripts.mealMenuListScene")
                storyboard.gotoScene("scripts.mealMenuListScene", "slideRight", 300)
            else
                print("Post error")
                sceneData.freeSceneDataWithUID("photolist")
                sceneData.freeSceneDataWithUID("mealMenuContents")
                sceneData.freeSceneDataWithUID("mealMenuDate")
                
                utils.showMessage(language["common"]["wrong_connection"])
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
        
        if(photolist and photolist[IMAGE_MAX_COUNT] and photolist[IMAGE_MAX_COUNT] ~= "") then
            if(content_textBox and content_textBox.text ~= "") then
                if(utils.UFT8Len(content_textBox.text) < __MEAL_MENU_CONTENT_LIMIT_LENGTH__ ) then --글자수 체크
                    local strYear = string.format("%04d",menuDate_data.year)
                    local strMonth = string.format("%02d",menuDate_data.month)
                    local strDay = string.format("%02d",menuDate_data.day)
                    local params = {
                        center_id = user.userData.centerid,
                        date = strYear..strMonth..strDay,
                        title = content_textBox.text,
                        member_id = user.userData.id,
                        filename = photolist[1],
                        dir = system.TemporaryDirectory,
                        class_id = user.userData.classId
                    }
                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                    api.post_dailymenu_data(params, getDataCallback)
                else
                    utils.showMessage(language["mealMenuWriteScene"]["contents_limit_length"])
                    native.setKeyboardFocus(content_textBox)
                end
            else
                utils.showMessage(language["mealMenuWriteScene"]["input_contents"])
            end
        else
            utils.showMessage(language["mealMenuWriteScene"]["select_photo"])
        end
    end
    
    return true
end

local function onAddDateButtonClick(event)
    clearScreen()
    
--    if (display.contentHeight <= 480 ) then
--        transition.to(display_group, {y = - pickerList_Move_Y, time=100, onComplete=nil})
--    end
    
    local selectedYear
    local selectedMonth
    local selectedDay
    
    local days = {}
    local years = {}
        
    -- Populate the "days" table
    for d = 1, 31 do
        days[d] = d..language["mealMenuWriteScene"]["day"]
    end
        
    -- Populate the "years" table
    local currentYear = os.date( "%Y" )
    local startYear = currentYear - 2;
    for y = 1, 3 do
        years[y] = (startYear + y) ..language["mealMenuWriteScene"]["year"]
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
        selectedYear  = tonumber(string.sub(values[1].value, 1, 4));
        selectedMonth = values[2].index;
            
        local a, b = string.find(values[3].value, language["mealMenuWriteScene"]["day"])
        selectedDay   = tonumber(string.sub(values[3].value, 1, a-1));
    end  
        
    if (selectedYear == nil) or (selectedMonth == nil) or (selectedDay == nil) then
        local date = os.date( "*t" );
        selectedYear = date.year;
        selectedMonth = date.month;
        selectedDay = date.day;
    end
    columnData[1].startIndex =  2--100 - (os.date( "%Y" ) - tonumber(selectedYear));
    columnData[2].startIndex = tonumber(selectedMonth);
    columnData[3].startIndex = tonumber(selectedDay);
        
    pickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
--            editField = row.pickerField,
            pickerData = columnData,
            titleText = language["mealMenuWriteScene"]["input_date"],
            onScroll = onScroll,
            okButtonText = language["mealMenuWriteScene"]["ok"],
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                if (utils.isValidDate(selectedYear, selectedMonth, selectedDay) == true) then
                                    menuDate_data.year = selectedYear
                                    menuDate_data.month = selectedMonth
                                    menuDate_data.day = selectedDay

                                    local strYear = string.format("%04d",selectedYear)
                                    local strMonth = string.format("%02d",selectedMonth)
                                    local strDay = string.format("%02d",selectedDay)
                                    selectedDate.text = utils.convert2LocaleDateString(strYear, strMonth, strDay)
                                    local eventDate = {year = strYear, month = strMonth, day = strDay}
                                    sceneData.addSceneDataWithUID("mealMenuDate", eventDate)
                                else
                                    utils.showMessage(language["date_format"]["invalid_date"])
                                    
                                    return true
                                end
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
    
    photolist = sceneData.getSceneDataWithUID("photolist")
    if(photolist == nil) then
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
        label = language["mealMenuWriteScene"]["cancel"],
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
        label = language["mealMenuWriteScene"]["ok"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_ok_normal.png",
        overFile = "images/top_with_texts/btn_top_text_ok_touched.png", 
    }

    local navBar = widget.newNavigationBar({
        title = language["mealMenuWriteScene"]["title"],
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
    navBar:addEventListener("touch", function() clearScreen() end)
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
    
    local eventDateGroup = display.newGroup()
    group:insert(eventDateGroup)
    
    local eventDateRect = display.newRect(group, 0, 0, __appContentWidth__, SELECT_CLASS_BAR)
    eventDateRect.anchorX = 0
    eventDateRect.anchorY = 0
    eventDateRect.x = 0
    eventDateRect.y = nameRect.y + (nameRect.height * 0.5) 
    eventDateRect.strokeWidth = 0
--    eventDateRect:setFillColor(0, 0, 0, 1)
    eventDateGroup:insert(eventDateRect)
    
    local eventDateText = display.newText(language["mealMenuWriteScene"]["short_input_date"], 0, 0, native.systemFont, 12)
    eventDateText.anchorX = 0
    eventDateText.anchorY = 0
    eventDateText.x = 10
    eventDateText.y = eventDateRect.y + (eventDateRect.height - eventDateText.height)/2
    eventDateText:setFillColor( 0 )
    eventDateGroup:insert(eventDateText)
    eventDateGroup:addEventListener("tap", 
        function()
            if(pickerList and pickerList.isShowing == true) then
                pickerList:closeUp()
                pickerList.isShowing = false

                return true
            end
            
            onAddDateButtonClick()
        end 
    )
    
    menuDate_data = sceneData.getSceneDataWithUID("mealMenuDate")
    if (menuDate_data == nil) then
        menuDate_data = {}
    end
    local eventDate_txt
    if(menuDate_data and menuDate_data.year and menuDate_data.year ~= "") then
        eventDate_txt = utils.convert2LocaleDateString(menuDate_data.year, menuDate_data.month, menuDate_data.day)
    else
        local date = os.date( "*t" );
        eventDate_txt = utils.convert2LocaleDateString(date.year, date.month, date.day)
        menuDate_data.year = date.year
        menuDate_data.month = date.month
        menuDate_data.day = date.day
    end
    selectedDate = display.newText(eventDate_txt, 0, 0, native.systemFont, 12)
    selectedDate.anchorX = 0
    selectedDate.anchorY = 0
    selectedDate.x = eventDateText.x + eventDateText.width + 10
    selectedDate.y = eventDateText.y
    selectedDate:setFillColor( 0 )
    eventDateGroup:insert(selectedDate)
    
    local line = display.newLine( 2, eventDateRect.y + SELECT_CLASS_BAR + 1, display.contentWidth - 2, eventDateRect.y + SELECT_CLASS_BAR + 1 )
    line:setStrokeColor( 0, 0, 0, 0.5)
    line.strokeWidth = 2
    group:insert(line)
    
    imageScrollView = widget.newScrollView
    {
--        top = 0,
--        left = 0,
        width = __appContentWidth__,
        height = 60,
        scrollWidth = __appContentWidth__,
        scrollHeight = 0,
        verticalScrollDisabled = true,
--        hideBackground = true,
--        backgroundColor = { 0.8, 0.8, 0.8 },
        listener =  function(event)
                        if(event.phase == "ended") then
                            if(clearScreen() == true) then
                                return true
                            end
                            
                        end
                    end
    }    
    imageScrollView.anchorX = 0
    imageScrollView.anchorY = 0
    imageScrollView.x = 0
    imageScrollView.y = nameRect.y + nameRect.height + CONTENT_TEXTBOX_HEIGHT + SELECT_CLASS_BAR - 3
    group:insert(imageScrollView)
    
    local photoImageSize = 60
    local startX = 5
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
    
    local function deleteImg(event)
        if(clearScreen() == true) then
            return true
        end

        local obj = event.target    
        native.showAlert(language["appTitle"], language["noticeWriteScene"]["delete_photo"], 
            { language["noticeWriteScene"]["yes"], language["noticeWriteScene"]["no"] }, 
            function(event)
                if "clicked" == event.action then
                    local i = event.index
                    if 1 == i then
                        if(obj.name == photolist[1]) then
                            display.remove(obj.deleteIcon)
                            table.remove(photolist, 1)
                            display.remove(obj)
                        end
                    end
                end    
            end
        )
    end
    
    if(#photolist == IMAGE_MAX_COUNT) then
        if(utils.fileExist(photolist[IMAGE_MAX_COUNT], system.TemporaryDirectory) == true) then
            local mealimage = display.newImageRect(photolist[IMAGE_MAX_COUNT], system.TemporaryDirectory, 0, 0 )
            mealimage.width = photoImageSize
            mealimage.height = photoImageSize
            mealimage.anchorX = 0
            mealimage.anchorY = 0
            mealimage.name = photolist[IMAGE_MAX_COUNT]
            mealimage.x = addPhotoButton.x + addPhotoButton.width + 5
            mealimage.y = 0
            imageScrollView:insert(mealimage)
            
            mealimage.deleteIcon = display.newImageRect("images/assets1/icon_delete_photo.png", 20, 20)
            mealimage.deleteIcon.anchorX = 0
            mealimage.deleteIcon.anchorY = 0
            mealimage.deleteIcon.x = mealimage.x + mealimage.width - mealimage.deleteIcon.width
            mealimage.deleteIcon.y = mealimage.height - mealimage.deleteIcon.height
            imageScrollView:insert(mealimage.deleteIcon)
            
            mealimage:addEventListener("tap", deleteImg)
        end
    end
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.mealMenuListScene"
        
    local function inputListener( event )
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
            
--            if (__deviceType__ == "iphone") then
--                if (content_textBox.text == language["mealMenuWriteScene"]["input_contents"]) then
--                    content_textBox.text = ""
--                end
--            end
        elseif event.phase == "ended" then
--            if (__deviceType__ == "iphone") then
--                if (content_textBox.text == "") then
--                    content_textBox.text = language["mealMenuWriteScene"]["input_contents"]
--                end
--            end
        elseif event.phase == "editing" then
            print( event.text )
        end
    end
    
    content_textBox = native.newTextBox(display.contentCenterX,
            CONTENT_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + SELECT_CLASS_BAR + 4,
            display.contentWidth - 2, 
            CONTENT_TEXTBOX_HEIGHT)
    content_textBox.text = ""
    content_textBox.placeholder = language["mealMenuWriteScene"]["input_contents"]
    content_textBox.isEditable = true
    content_textBox.strokeWidth = 0
    content_textBox.hasBackground = false
    content_textBox:addEventListener( "userInput", inputListener)
    content_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(content_textBox)
    
    local content_text = sceneData.getSceneDataWithUID("mealMenuContents")
    if(content_text) then
        content_textBox.text = content_text
    end
    
--    if (__deviceType__ == "iphone") then
--        if(content_textBox.text == "") then
--            content_textBox.text = language["mealMenuWriteScene"]["input_contents"]
--        end
--    end
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
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    clearScreen()
    
    if (sharePanel) then
        sharePanel.isShowing = false
        sharePanel:hide()
    end
    
    if(content_textBox) then
        content_textBox:removeSelf()
        content_textBox = nil
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







