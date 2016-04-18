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
local widget = require("widget")
local language = getLanguage()
local json = require("json")
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
local api = require("scripts.api")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30

local content_textBox
local title_textBox

local activityIndicator

local timePickerList

local selectedEventDate
local display_group
local previous_scene
local start_button
local end_button
local msgDisplaySet

local start_hour
local start_minute
local end_hour
local end_minute
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        if msgDisplaySet == true then
            if start_hour and start_minute and end_hour and end_minute then
                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                api.set_message_time(user.userData.centerid, "1", 
                    string.format("%.2d", start_hour), 
                    string.format("%.2d", start_minute), 
                    string.format("%.2d", end_hour), 
                    string.format("%.2d", end_minute),  
                    function(event)
                        if(event.isError) then
                            activityIndicator:destroy()
                            utils.showMessage( language["common"]["wrong_connection"] )
                        elseif(event.phase == "ended") then
                            activityIndicator:destroy()
                            user.userData.message_time.set_yn = "1"
                            user.userData.message_time.s_hours = string.format("%.2d", start_hour)
                            user.userData.message_time.s_min = string.format("%.2d", start_minute)
                            user.userData.message_time.e_hour = string.format("%.2d", end_hour)
                            storyboard.gotoScene(previous_scene, "slideRight", 300)
                        end
                    end )
            else
                utils.showMessage("시간을 설정해 주세요.")
            end
        else
            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
            api.set_message_time(user.userData.centerid, "0", "00", "00", "00", "00", 
                function(event)
                    if(event.isError) then
                        activityIndicator:destroy()
                        utils.showMessage( language["common"]["wrong_connection"] )
                    elseif(event.phase == "ended") then
                        activityIndicator:destroy()
                        user.userData.message_time.set_yn = "0"
                        storyboard.gotoScene(previous_scene, "slideRight", 300)
                    end
                end )
        end
    end
end

local function onAddTimeButtonClick(_set)
    local selected_ampm_Index
    local selectedHours
    local selectedMinute
    
    local am_pm = {"오전","오후"}
    local hours = {"00","01","02","03","04","05","06","07","08","09","10","11","12"}
    local minutes = {"00","10","20","30","40","50"}    
        
    local columnData = 
    {
        -- 오전, 오후
        {
            align = "center",
            width = 80,
            startIndex = 10,
            labels = am_pm
        },
            
        -- 시간
        { 
            align = "right",
            width = 90,
            startIndex = 3,
            labels = hours--language["calendar"]["month"] --{ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"}
        },
            
        -- 분
        {
            align = "right",
            width = 90,
            startIndex = 9,
            labels = minutes
        }
    }  
        
    local function onScroll(event)
        local values = event.values
        selected_ampm_Index = values[1].index
        selectedHours = values[2].value
        selectedMinute = values[3].value
    end  
        
    if _set == "start" then
        columnData[1].startIndex = 1
    else
        columnData[1].startIndex = 2
    end
    
    columnData[2].startIndex = 1
    columnData[3].startIndex = 1
        
    timePickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
--            editField = row.pickerField,
            pickerData = columnData,
            titleText = "시간을 설정해 주세요.",
            onScroll = onScroll,
            okButtonText = "OK",
            onClose =   function()
                            timePickerList.isShowing = false
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                local values = timePickerList.pickerWheel:getValues()
                                selected_ampm_Index = values[1].index
                                selectedHours = values[2].value
                                selectedMinute = values[3].value
                                
                                local strTime
                                if selected_ampm_Index == 1 then
                                    strTime = "오전".. " "..selectedHours..":"..selectedMinute
                                else
                                    strTime = "오후".. " "..selectedHours..":"..selectedMinute
                                end
                                if _set == "start" then
                                    start_button:setLabel(strTime)
                                else
                                    end_button:setLabel(strTime)
                                end
                                if selected_ampm_Index == 2 then --1: 오전, 2: 오후
                                    selectedHours = selectedHours + 12
                                end
                                if _set == "start" then
                                    start_hour = selectedHours
                                    start_minute = selectedMinute
                                else
                                    end_hour = selectedHours
                                    end_minute = selectedMinute
                                end
                            end
                        end,
        }
    ) 
    timePickerList.isShowing = true   
       
    return true
end

local function onOffSwitchListener( event )
    if utils.IS_Demo_mode(storyboard, true) == true then
        return true
    end
    
    if(event.target.isOn == true) then
        msgDisplaySet = true
        utils.showMessage("설정한 시간", 5000)
        start_button:setEnabled(true)
        end_button:setEnabled(true)
    else
        msgDisplaySet = false
        utils.showMessage("24시간 설정한 시간", 5000)
        start_button:setEnabled(false)
        end_button:setEnabled(false)
        
        start_button:setLabel("시간 설정")
        end_button:setLabel("시간 설정")
        
        start_hour = nil
        start_minute = nil
        end_hour = nil
        end_minute = nil
    end
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    
    if index == 1 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width, row.height, 6)
        row:insert(row.rect )
        
        row.category_info = display.newText("메세지 표시 설정", 0, 0, native.systemFontBold, 12)
        row.category_info.anchorX = 0
        row.category_info.anchorY = 0
        row.category_info.x = 10
        row.category_info.y = (row.contentHeight - row.category_info.height) /2
        row.category_info:setFillColor(0, 0, 0)
        row:insert(row.category_info)
        
        row.onOffSwitch = widget.newSwitch
        {   
            initialSwitchState = msgDisplaySet,
            onRelease = onOffSwitchListener,
        }
        row.onOffSwitch.anchorX = 0
        row.onOffSwitch.anchorY = 0
        row.onOffSwitch.x = row.width - row.onOffSwitch.width
        row.onOffSwitch.y = (row.height - row.onOffSwitch.height)/2 
        row:insert(row.onOffSwitch)
    elseif index == 2 then
        row.category_info = display.newText("보호자 메시지 표시", 0, 0, native.systemFontBold, 12)
        row.category_info.anchorX = 0
        row.category_info.anchorY = 0
        row.category_info.x = 10
        row.category_info.y = (row.contentHeight - row.category_info.height) /2
        row.category_info:setFillColor(0, 0, 0)
        row:insert(row.category_info)
    elseif index == 3 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width, row.height, 6)
        row:insert(row.rect )
        
        local msgText = "メッセージ受付時間が終了いたしました。受付時間外に受信したメッセージは、確認に時間がかかる場合があります。緊急の場合は、お電話にてご連絡お願いいたします。"
        row.category_info = display.newText(msgText, 0, 0, row.width - 20, 0, native.systemFontBold, 12)
        row.category_info.anchorX = 0
        row.category_info.anchorY = 0
        row.category_info.x = 10
        row.category_info.y = (row.contentHeight - row.category_info.height) /2
        row.category_info:setFillColor(0, 0, 0)
        row:insert(row.category_info)    
    elseif index == 4 then
        row.category_info = display.newText("업무 시간 설정", 0, 0, native.systemFontBold, 12)
        row.category_info.anchorX = 0
        row.category_info.anchorY = 0
        row.category_info.x = 10
        row.category_info.y = (row.contentHeight - row.category_info.height) /2
        row.category_info:setFillColor(0, 0, 0)
        row:insert(row.category_info)
    elseif index == 5 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width, row.height, 6)
        row:insert(row.rect )
        
        row.start_info = display.newText("시작 시간 설정", 0, 0, native.systemFontBold, 12)
        row.start_info.anchorX = 0
        row.start_info.anchorY = 0
        row.start_info.x = 10
        row.start_info.y = (row.contentHeight - row.start_info.height) /2
        row.start_info:setFillColor(0, 0, 0)
        row:insert(row.start_info)
        
        row.start_button = widget.newButton
        {
            width = 120 ,
            height = 30 ,
            defaultFile = "images/button/btn_red_1_normal.png",
            overFile = "images/button/btn_red_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            label = "시간 설정",
            onRelease = function()
                            if(timePickerList and timePickerList.isShowing == true) then
                                timePickerList:closeUp()
                                timePickerList.isShowing = false

                                return true
                            end

                            onAddTimeButtonClick("start") --오전
                        end 
        }
        row.start_button.anchorX = 0
        row.start_button.anchorY = 0
        row.start_button.x = row.contentWidth - row.start_button.width - 10
        row.start_button.y = (row.contentHeight - row.start_button.height) /2
        row:insert(row.start_button)
        start_button = row.start_button
        
        if user.userData.message_time.set_yn == "0" then
            row.start_button:setEnabled(false)
        end
    elseif index == 6 then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width, row.height, 6)
        row:insert(row.rect )
        
        row.end_info = display.newText("종료 시간 설정", 0, 0, native.systemFontBold, 12)
        row.end_info.anchorX = 0
        row.end_info.anchorY = 0
        row.end_info.x = 10
        row.end_info.y = (row.contentHeight - row.end_info.height) /2
        row.end_info:setFillColor(0, 0, 0)
        row:insert(row.end_info)
        
        row.end_button = widget.newButton
        {
            width = 120 ,
            height = 30 ,
            defaultFile = "images/button/btn_blue_1_normal.png",
            overFile = "images/button/btn_blue_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            label = "시간 설정",
            onRelease = function()
                            if(timePickerList and timePickerList.isShowing == true) then
                                timePickerList:closeUp()
                                timePickerList.isShowing = false

                                return true
                            end

                            onAddTimeButtonClick("end") 
                        end 
        }
        row.end_button.anchorX = 0
        row.end_button.anchorY = 0
        row.end_button.x = row.contentWidth - row.end_button.width - 10
        row.end_button.y = (row.contentHeight - row.end_button.height) /2
        row:insert(row.end_button)
        end_button = row.end_button
        
        if user.userData.message_time.set_yn == "0" then
            row.end_button:setEnabled(false)
        end
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    display_group = group
    
    previous_scene = storyboard.getPrevious()
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = "Cancel",
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
        label = "Save",
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
    }
    
    local navBar = widget.newNavigationBar({
        title = "표시 시간 설정",
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
    
    local timeTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT,
	height = __appContentHeight__ - NAVI_BAR_HEIGHT - NAME_BAR_HEIGHT - __statusBarHeight__ ,
        width = __appContentWidth__,
	maxVelocity = 1, 
        backgroundColor = { 0.9, 0.9, 0.9, 0},
	noLines = true,
        hideBackground = true,    
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
	onRowRender = onRowRender,
    }
    timeTable.x = display.contentCenterX
    group:insert(timeTable)
    
    local CATEGORY_ROW_HEIGHT = 30
    local rowHeight = 40
    timeTable:insertRow{ --switch
        rowHeight = rowHeight,
        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
        lineColor = { 0.5, 0.5, 0.5 },
    }
    timeTable:insertRow{ --category
        rowHeight = CATEGORY_ROW_HEIGHT,
        rowColor = { default = __activeKidListColor__},
        lineColor = { 1, 0, 0 },
        isCategory = true,
    }
        
    local msgText = "メッセージ受付時間が終了いたしました。受付時間外に受信したメッセージは、確認に時間がかかる場合があります。緊急の場合は、お電話にてご連絡お願いいたします。"
    local msg_info = display.newText(msgText, 0, 0, display.contentWidth - 20, 0, native.systemFontBold, 12)     
    local msgRowHeight = msg_info.height + 20
    display.remove(msg_info)
    
    api.get_message_time(user.userData.centerid,
        function(event)
            if(event.isError) then
                activityIndicator:destroy()
                utils.showMessage( language["common"]["wrong_connection"] )
            elseif(event.phase == "ended") then
                activityIndicator:destroy()
                
                if(event.status == 200) then
                    local data = json.decode(event.response)
                    
                end    
                
            end
        end
    )
    timeTable:insertRow{
        rowHeight = msgRowHeight,
        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
        lineColor = { 0.5, 0.5, 0.5 },
    }
    
    timeTable:insertRow{ --category
        rowHeight = CATEGORY_ROW_HEIGHT,
        rowColor = { default = __activeKidListColor__},
        lineColor = { 1, 0, 0 },
        isCategory = true,
    }
    timeTable:insertRow{
        rowHeight = 50,
        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
        lineColor = { 0.5, 0.5, 0.5 },
    }
    timeTable:insertRow{
        rowHeight = 50,
        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
        lineColor = { 0.5, 0.5, 0.5 },
    }
    
    if user.userData.message_time.set_yn == "0" then
        msgDisplaySet = false
    else
        msgDisplaySet = true
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
    storyboard.returnTo = previous_scene
    
    utils.showMessage("선생님들의 사생활을 보호하기 위해 '설정한 업무 시간 이외의 시간에는 메세지를 확인하기 어렵습니다.'라는 메세지를 표시합니다.", 5000)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    if(timePickerList) then
        timePickerList:closeUp()
        timePickerList.isShowing = false
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









