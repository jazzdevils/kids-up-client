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

local content_textBox
local title_textBox

local CONTENT_TEXTBOX_HEIGHT = 100
local TITLE_TEXTBOX_HEIGHT = 40
local activityIndicator

local pickerList

local selectedEventDate
local display_group
local contentField_Move_Y = 100
local pickerList_Move_Y = 50
local button_keyboardOnOff

local line3
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function saveTempFile()
    local dataTable = {}
    dataTable.member_id = user.userData.id --작성자 아이디
    dataTable.title = title_textBox.text --제목
    dataTable.contents = content_textBox.text --내용
                
    loadsave.saveTable(dataTable, __TMP_FILE_CALENDAR_WRITE__, system.DocumentsDirectory)
end

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
end

local function freeMemoryAndGo(needRefresh)
    sceneData.freeSceneDataWithUID("calendarContents")
    sceneData.freeSceneDataWithUID("calendarTitle")
    sceneData.freeSceneDataWithUID("calendarDate")
    sceneData.freeSceneDataWithUID("mapAddress")
    
    if(needRefresh and needRefresh == true) then
        storyboard.purgeScene("scripts.calendarScene")
    end
    
    storyboard.gotoScene("scripts.calendarScene", "slideRight", 300)
end

local function onLeftButton(event)
    local function isSavedThread()
        if (utils.fileExist(__TMP_FILE_CALENDAR_WRITE__, system.DocumentsDirectory) == true) then
            local tmpData = loadsave.loadTable(__TMP_FILE_CALENDAR_WRITE__, system.DocumentsDirectory)
            if(tmpData.member_id == user.userData.id and tmpData.title == title_textBox.text 
                and tmpData.contents == content_textBox.text) then

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
--            if (content_textBox.text == language["calendarWriteScene"]["input_contents"]) then
--                content_textBox.text = ""
--            end
--        end
        
        if(title_textBox.text ~= "" or content_textBox.text ~= "" ) then
            if isSavedThread() == false then
                native.showAlert(language["appTitle"], language["calendarWriteScene"]["delete_question"], 
                    { language["calendarWriteScene"]["yes"], language["calendarWriteScene"]["no"] }, 
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
        if(title_textBox and title_textBox.text ~= "") then
            if(content_textBox and content_textBox.text ~= "") then
                utils.showMessage(language["calendarWriteScene"]["temp_save"])
                saveTempFile()    
            else
                utils.showMessage(language["calendarWriteScene"]["input_contents"])
                native.setKeyboardFocus(content_textBox) 
                
                return true
            end
        else
            utils.showMessage(language["calendarWriteScene"]["input_title"])
            native.setKeyboardFocus(title_textBox) 
            
            return true
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
                local oDate = sceneData.getSceneDataWithUID("calendarDate")
                if(oDate) then
                    local strYear = string.format("%04d",oDate.year)
                    local strMonth = string.format("%02d",oDate.month)
                    local strDay = string.format("%02d",oDate.day)
                    
                    local params = {
                        center_id = user.userData.centerid,
                        kids_id = user.getActiveKid_IDByAuthority(),
                        date = strYear..strMonth..strDay,
                        member_id = user.userData.id,
                        title = title_textBox.text,
                        detail = content_textBox.text,
                        time = ""
                    }
                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                    api.add_schedule_data(params, 
                        function(event)
                            activityIndicator:destroy()
                            
                            freeMemoryAndGo(true)
                        end
                    )
                else
                    utils.showMessage(language["calendarWriteScene"]["input_date"])
                    
                    return true
                end
            else
                utils.showMessage(language["calendarWriteScene"]["input_contents"])
                native.setKeyboardFocus(content_textBox) 
                
                return true
            end
        else
            utils.showMessage(language["calendarWriteScene"]["input_title"])
            native.setKeyboardFocus(title_textBox) 
            
            return true
        end
    end
end

local function onAddDateButtonClick(event)
    clearScreen()
    
    if display.contentHeight <= 480 then
        transition.to(display_group, {y = - pickerList_Move_Y, time=100, onComplete=nil})
    end
    
    local selectedYear
    local selectedMonth
    local selectedDay
    
    local days = {}
    local years = {}
        
    -- Populate the "days" table
    for d = 1, 31 do
        days[d] = d..language["calendarWriteScene"]["day"]
    end
        
    -- Populate the "years" table
    local currentYear = os.date( "%Y" )
    local startYear = currentYear - 2;
    for y = 1, 3 do
        years[y] = (startYear + y) ..language["calendarWriteScene"]["year"]
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
            labels = language["calendar"]["month"] --{ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"}
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
            
        local a, b = string.find(values[3].value, language["calendarWriteScene"]["day"])
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
            titleText = language["calendarWriteScene"]["input_date"],
            onScroll = onScroll,
            okButtonText = language["calendarWriteScene"]["ok"],
            onClose =   function()
                            if (display_group.y < 0) then
                                transition.to(display_group, {y = 0, time=100, onComplete=nil})
                            end
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                if (display_group.y < 0) then
                                    transition.to(display_group, {y = 0, time=100, onComplete=nil})
                                end
                                
                                if (utils.isValidDate(selectedYear, selectedMonth, selectedDay) == true) then
                                    local strYear = string.format("%04d",selectedYear)
                                    local strMonth = string.format("%02d",selectedMonth)
                                    local strDay = string.format("%02d",selectedDay)
                                    selectedEventDate.text = utils.convert2LocaleDateString(strYear, strMonth, strDay)
                                    local eventDate = {year = strYear, month = strMonth, day = strDay}
                                    sceneData.addSceneDataWithUID("calendarDate", eventDate)
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
                
                if(clearScreen() == true) then
                    return true
                end
            end
        end 
    )
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["calendarWriteScene"]["cancel"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_cancel_normal.png",
        overFile = "images/top_with_texts/btn_top_text_cancel_touched.png", 
    }

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
        title = language["calendarWriteScene"]["title"],
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
        function(event)
            if(event.phase == "ended") then
                if(clearScreen() == true) then
                    return true
                end
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
    
    local line2= display.newLine( 2, rect.y + TITLE_TEXTBOX_HEIGHT + 1, display.contentWidth - 2, rect.y + TITLE_TEXTBOX_HEIGHT + 1 )
    line2:setStrokeColor( 0, 0, 0, 0.5)
    line2.strokeWidth = 2
    group:insert(line2)
    
    line3= display.newLine( 2, line2.y + CONTENT_TEXTBOX_HEIGHT + 4, display.contentWidth - 2, line2.y + CONTENT_TEXTBOX_HEIGHT + 4)
    line3:setStrokeColor( 0, 0, 0, 0.5)
    line3.strokeWidth = 2
    group:insert(line3)
    
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.returnTo = "scripts.calendarScene"
        
    local function title_inputListener( event )
        if event.phase == "began" then
            if (display_group.y < 0) then
                transition.to(display_group, {y = 0, time=100, onComplete=nil})
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
            
            if(pickerList and pickerList.isShowing == true) then
               pickerList:closeUp()
               pickerList.isShowing = false
            end
            
--            if (__deviceType__ == "iphone") then
--                if (content_textBox.text == language["calendarWriteScene"]["input_contents"]) then
--                    content_textBox.text = ""
--                end
--            end
        elseif event.phase == "ended" then
--            if (__deviceType__ == "iphone") then
--                if (content_textBox.text == "") then
--                    content_textBox.text = language["calendarWriteScene"]["input_contents"]
--                end
--            end
        elseif event.phase == "editing" then
            print( event.text )
            
        end
    end
    
    title_textBox = native.newTextField(display.contentCenterX, 
            TITLE_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT, 
            __appContentWidth__- 2, TITLE_TEXTBOX_HEIGHT)
--    title_textBox.text = ""        
    title_textBox.placeholder = language["calendarWriteScene"]["input_title"]
    title_textBox.hasBackground = false
    title_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(title_textBox)
    local title_text = sceneData.getSceneDataWithUID("calendarTitle")
    if(title_text) then
        title_textBox.text = title_text
    end
    title_textBox:addEventListener("userInput", title_inputListener)
    
    content_textBox = native.newTextBox(display.contentCenterX,
            CONTENT_TEXTBOX_HEIGHT/2 + __statusBarHeight__+ NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + TITLE_TEXTBOX_HEIGHT + 3,
            __appContentWidth__ - 2 , 
            CONTENT_TEXTBOX_HEIGHT)
    content_textBox.text = ""
    content_textBox.placeholder = language["calendarWriteScene"]["input_contents"]
    content_textBox.isEditable = true
    content_textBox.strokeWidth = 0
    content_textBox.hasBackground = false
    content_textBox:addEventListener( "userInput", contents_inputListener )
    content_textBox.font = native.newFont(native.systemFont, __INPUT_TEXT_FONT_SIZE__)
    group:insert(content_textBox)
    local content_text = sceneData.getSceneDataWithUID("calendarContents")
    if(content_text) then
        content_textBox.text = content_text
    end
    
--    if (__deviceType__ == "iphone") then
--        if(content_textBox.text == "") then
--            content_textBox.text = language["calendarWriteScene"]["input_contents"]
--        end
--    end
    
    local eventDateGroup = display.newGroup()
    group:insert(eventDateGroup)
    
    local eventDateRect = display.newRect(group, 0, 0, __appContentWidth__, SELECT_CLASS_BAR)
    eventDateRect.anchorX = 0
    eventDateRect.anchorY = 0
    eventDateRect.x = 0
    eventDateRect.y = line3.y 
    eventDateRect.strokeWidth = 0
--    eventDateRect:setFillColor(1, 0, 0, 1)
    eventDateGroup:insert(eventDateRect)
    
    local eventDateText = display.newText(language["calendarWriteScene"]["short_input_date"], 0, 0, native.systemFont, 12)
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
    
    local eventDate_data = sceneData.getSceneDataWithUID("calendarDate")
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
    
    if (utils.fileExist(__TMP_FILE_CALENDAR_WRITE__, system.DocumentsDirectory) == true) then
        local tmpData = loadsave.loadTable(__TMP_FILE_CALENDAR_WRITE__, system.DocumentsDirectory)
        if(tmpData.member_id == user.userData.id) then
            native.showAlert(language["appTitle"], language["calendarWriteScene"]["read_question"], 
                {language["calendarWriteScene"]["yes"], language["calendarWriteScene"]["no"] }, 
                function(event)
                    if "clicked" == event.action then
                        local i = event.index
                        if 1 == i then
                            title_textBox.text = tmpData.title
                            content_textBox.text = tmpData.contents
                            
                            utils.deleteFile(__TMP_FILE_CALENDAR_WRITE__, system.DocumentsDirectory)
                        end    
                    end    
                end
            )
        end
    end
    
    native.setKeyboardFocus(title_textBox)
    
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
    
--    native.setKeyboardFocus(title_textBox)
    
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









