---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local api = require("scripts.api")
local utils = require("scripts.commonUtils")
local user = require("scripts.user_data")
require("widgets.activityIndicator")
local popupWidth = __appContentWidth__ - 40
local popupHeight = __appContentHeight__ / 1.5

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local classes, localGroup
local showNoClassFlag = 0
local activityIndicator
local selectedClassList = {}
local p_row

local function isSelectedClass(class_id)
    local bRtn = false
    for i = 1, #selectedClassList do
        local class = selectedClassList[i]
        if(class.id == class_id) then
            return true
        end
    end
    
    return bRtn
end

local function addSelectedClass(class_id, class_name)
    local class = {}
    class.id = class_id
    class.name = class_name
    table.insert(selectedClassList, class)
end

local function deleteSelectedClass(class_id)
    for i = #selectedClassList, 1, -1 do
        local class = selectedClassList[i]
        if(class.id == class_id) then
            table.remove(selectedClassList, i) 
            
            return
        end
    end
end

local function onRowTouch( event )
    local phase = event.phase
    local row = event.target
    if "release" == phase or "tap" == phase then
        if row.checkedImg.isVisible == true then
            deleteSelectedClass(row.params.class_data.id)
            row.checkedImg.isVisible = false
        else
            addSelectedClass(row.params.class_data.id, row.params.class_data.name)
            row.checkedImg.isVisible = true
        end
    end

    return true
end

local function onRowRender( event )
    local row = event.row
    local rowWidth = row.contentWidth
    local rowHeight = row.contentHeight
    if showNoClassFlag == 1 then
        local idx = row.id - 1
        local rowBgImg
        if row.index % 2 == 1 then
            rowBgImg = display.newImageRect(row, "images/assets2/bg_popup_table_odd_1.png", rowWidth - 4, rowHeight - 4)
        else
            rowBgImg = display.newImageRect(row, "images/assets2/bg_popup_table_even_1.png", rowWidth - 4, rowHeight - 4)
        end
        rowBgImg.x = rowWidth * 0.5
        rowBgImg.y = rowHeight * 0.5
        local rowTitle
        if classes[idx] == nil then
            rowTitle = display.newText( row, language["joinScene"]["noclass"], 0, 0, nil, 14 )
        else
            rowTitle = display.newText( row, classes[idx].name.." ["..classes[idx].desc.."]", 0, 0, nil, 14 )
        end
        rowTitle:setFillColor( unpack(__POPUP_TABLE_ROW_TXT_COLOR__) )
        rowTitle.anchorX = 0
        rowTitle.x = rowWidth / 2 - rowTitle.width / 2
        rowTitle.y = rowHeight * 0.5
    else
        local idx = row.id
        local rowBgImg
        if row.index % 2 == 1 then
            rowBgImg = display.newImageRect(row, "images/assets2/bg_popup_table_odd_1.png", rowWidth - 4, rowHeight - 4)
        else
            rowBgImg = display.newImageRect(row, "images/assets2/bg_popup_table_even_1.png", rowWidth - 4, rowHeight - 4)
        end
        rowBgImg.x = rowWidth * 0.5
        rowBgImg.y = rowHeight * 0.5
        local rowTitle = display.newText( row, classes[idx].name.." ["..classes[idx].desc.."]", 0, 0, nil, 14 )
        rowTitle:setFillColor( unpack(__POPUP_TABLE_ROW_TXT_COLOR__) )
        rowTitle.anchorX = 0
        rowTitle.x = rowWidth / 2 - rowTitle.width / 2
        rowTitle.y = rowHeight * 0.5
        
        row.checkedImg = display.newImageRect("images/input/radio_checked.png", 22, 22)
        row.checkedImg.x = rowBgImg.x + (rowBgImg.width / 2) - 22
        row.checkedImg.y = rowHeight * 0.5
        row:insert(row.checkedImg)
        row.checkedImg.isVisible = isSelectedClass(row.params.class_data.id)
    end
end

local function closeButtonEvent( event )
    if event.phase == "ended" then
        if selectedClassList ~= nil then
            selectedClassList = nil
            storyboard.hideOverlay( "crossFade", 300 ) 
        end
    end
end

local function okButtonEvent( event )
    if event.phase == "ended" then
        if #selectedClassList == 0 then
            utils.showMessage(language["classList4TeacherByDirectorScene"]["notselected_class"])
            
            return
        end
        
        native.showAlert(language["appTitle"], language["mngTeacherListScene"]["change_class"]
            , { language["mngTeacherListScene"]["yes"], language["mngTeacherListScene"]["no"]}, 
            function(event)
                if "clicked" == event.action then
                    local i = event.index
                    if 1 == i then
                        local function getClassIDs()
                            local ids = ""
                            for i = 1, #selectedClassList do
                                if i == #selectedClassList then
                                    ids = ids .. selectedClassList[i].id
                                else
                                    ids = ids .. selectedClassList[i].id .. ","
                                end
                            end
                            return ids
                        end
                        
                        local function compare( a, b )
                            return a.id < b.id
                        end
                        table.sort( selectedClassList, compare ) --id 정렬
                        
                        local classIDs = getClassIDs()
                        local teacher_id = p_row.params.teacher_data.id
                        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                        api.change_teacher_class(teacher_id, classIDs, 
                            function(e)
                                activityIndicator:destroy()
                                if(e.isError) then
                                    utils.showMessage(language["common"]["wrong_connection"])
                                else
                                    if(p_row.className) then
                                        local sClassName = utils.getDisplayClassName4Teacher(selectedClassList)
                                        p_row.className.text = sClassName
                                        p_row.params.teacher_data.class = selectedClassList
                                    end
                                    
                                    storyboard.hideOverlay( "crossFade", 300 ) 
                                end
                            end
                        )
                    end
                end    
            end
        )
        
    end
    
    return true
end

local function renderTableView( data )
    local layerBg = display.newRect( localGroup, display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__ )
    layerBg.strokeWidth = 0
    layerBg:setFillColor( 0, 0, 0, 0.5 )
        
    local popupFrame = display.newImageRect(localGroup, "images/assets2/bg_popup.png", popupWidth + 14, popupHeight + 14)
    popupFrame.x = display.contentCenterX
    popupFrame.y = display.contentCenterY

    local popupTitleRec = display.newRect( localGroup, popupFrame.x, popupFrame.y - popupFrame.height / 2 + 12 + 7, popupWidth, 24 )
    popupTitleRec.strokeWidth = 0
    popupTitleRec:setFillColor( unpack(__POPUP_TITLE_BG_COLOR__) )

    local popupTitleOptions = 
    {
        parent = localGroup,
        text = language["joinScene"]["class_select_txt"].. " (".. p_row.params.teacher_data.name .. ")" ,
        x = popupTitleRec.x,
        y = popupTitleRec.y,
        width = popupWidth,
        font = native.systemFontBold,
        fontSize = __textLabelFontSize__,
        align = "center"
    }
    local popupTitle = display.newText(popupTitleOptions)
    popupTitle:setFillColor( unpack(__POPUP_TITLE_TXT_COLOR__) )

    local tableView = widget.newTableView
    {
        left = popupTitleRec.x - popupWidth / 2,
        top = popupTitleRec.y + popupTitleRec.height / 2,
        height = popupHeight - popupTitleRec.height - 40,
        width = popupWidth,
        backgroundColor = { 0.9, 0.9, 0.9 },
        noLines = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch
    }
    if showNoClassFlag == 1 then
        tableView:insertRow(
            {
                rowHeight = 34,
                rowColor = { default = { 0.9, 0.9, 0.9 } }
            }
        )
    end
    for i = 1, data.class_cnt do
        tableView:insertRow(
            {
                rowHeight = 34,
                rowColor = { default = { 0.9, 0.9, 0.9 } },
                params = {
                    class_data = data.class[i],
                }
            }
        )
    end
    localGroup:insert(tableView)
    
    local button_width = (popupTitleRec.width - 30) / 2
    local ok_button = widget.newButton
    {
        width = button_width ,
        height = 30 ,
        left = display.contentCenterX - button_width - 5,
        top = tableView.y + tableView.height / 2 + 10,
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["popup_ok_button"],
        onRelease = okButtonEvent
    }
    localGroup:insert(ok_button)
    
    local close_button = widget.newButton
    {
        width = button_width ,
        height = 30 ,
        left = display.contentCenterX + 5,
        top = tableView.y + tableView.height / 2 + 10,
        defaultFile = "images/button/btn_red_2_normal.png",
        overFile = "images/button/btn_red_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["popup_close_button"],
        onRelease = closeButtonEvent
    }
    localGroup:insert(close_button)
end

local function listCallback(event)
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage(language["common"]["wrong_connection"])
    else
        activityIndicator:destroy()
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            print(data.status)
            if (data) then
                if(data.status == "OK") then
                    classes = data.class
                    renderTableView(data)
                else
                    utils.showMessage(language["joinScene"]["join_error"])
                end
            end
        end
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    localGroup = group
    local params = event.params
    p_row = params._row
    selectedClassList = table.copy(p_row.params.teacher_data.class)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.class_list_api(user.userData.centerid, listCallback)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view    
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
    localGroup:removeSelf()
    localGroup = nil
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



