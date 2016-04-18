---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language, lang = getLanguage()
local api = require("scripts.api")
local json = require("json")
local utils = require("scripts.commonUtils")
require("widgets.activityIndicator")
local activityIndicator

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local localGroup
local centerAddressRefData
local popupWidth = __appContentWidth__ - 100
local txtFirstClicked = false
local centerTypes = {}
local tableView

local function touchCenterTypeListener( event )
    local img = event.target
    centerAddressRefData.centerType = img.centerType
    centerAddressRefData.centerTypeName = img.centerTypeName
    txtFirstClicked = true
    return false
end

local function onRowRender( event )
    local row = event.row
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local rowBgImg
    if row.index % 2 == 1 then
        rowBgImg = display.newImageRect(row, "images/assets2/bg_popup_table_odd_1.png", rowWidth - 4, rowHeight - 4)
    else
        rowBgImg = display.newImageRect(row, "images/assets2/bg_popup_table_even_1.png", rowWidth - 4, rowHeight - 4)
    end
    rowBgImg.x = rowWidth * 0.5
    rowBgImg.y = rowHeight * 0.5
    rowBgImg.centerType = centerTypes[row.index].type
    rowBgImg.centerTypeName = centerTypes[row.index].name
    rowBgImg:addEventListener( "touch", touchCenterTypeListener )
    local options = {
        parent = row,
        x = rowWidth / 2,
        y = rowHeight * 0.5,
        text = centerTypes[row.id].name,
        width = rowWidth,
        align = "center",
        fontSize = 14
    }
    local rowTitle = display.newText( options )
    rowTitle:setFillColor( unpack(__POPUP_TABLE_ROW_TXT_COLOR__) )
end

local function onRowTouch( event )
    local phase = event.phase
    local row = event.target
    if ("tap" == phase or "release" == phase) and txtFirstClicked == true then
        storyboard.hideOverlay( "crossFade", 300 )
    end

    return true
end

local function listCallback(event)
    local function makeRow(json_data)
        if(tableView) then
            local cnt = json_data.centertype_cnt
            if(cnt > 0) then
                for i = 1, cnt do
                    centerTypes[i] = {
                        type = json_data.centertype[i].type,
                        name = json_data.centertype[i].name
                    }
                    tableView:insertRow{
                        rowHeight = 34,
                        rowColor = { default = { 0.9, 0.9, 0.9 } }
                    }
                end
            else
                tableView:insertRow{
                    rowHeight = 34,
                    rowColor = { default = { 0.9, 0.9, 0.9 } }
                }
            end
        end
    end
    
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
    if ( event.isError ) then
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
                    makeRow(data)
                else 
                    utils.showMessage( data.message )
                end
            end
        end
    end
    return true
end

local function closeButtonEvent( event )
    if event.phase == "ended" then
       storyboard.hideOverlay( "crossFade", 300 ) 
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    local params = event.params
    if ( params.centerAddressRefData ~= nil ) then
        centerAddressRefData = params.centerAddressRefData
    end
    localGroup = group
    
    local layerBg = display.newRect( localGroup, display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__ )
    layerBg.strokeWidth = 0
    layerBg:setFillColor( 0, 0, 0, 0.5 )

    local popupFrame = display.newImageRect(localGroup, "images/assets2/bg_popup.png", popupWidth + 14, popupWidth + 14)
    popupFrame.x = display.contentCenterX
    popupFrame.y = display.contentCenterY

    local popupTitleRec = display.newRect( localGroup, popupFrame.x, popupFrame.y - popupFrame.height / 2 + 12 + 7, popupWidth, 24 )
    popupTitleRec.strokeWidth = 0
    popupTitleRec:setFillColor( unpack(__POPUP_TITLE_BG_COLOR__) )

    local popupTitleOptions = 
    {
        parent = localGroup,
        text = language["joinScene"]["centertype_select_title"],
        x = popupTitleRec.x,
        y = popupTitleRec.y,
        width = popupWidth,
        font = native.systemFontBold,
        fontSize = __textLabelFontSize__,
        align = "center"
    }
    local popupTitle = display.newText(popupTitleOptions)
    popupTitle:setFillColor( unpack(__POPUP_TITLE_TXT_COLOR__) )

    tableView = widget.newTableView
    {
        left = popupTitleRec.x - popupWidth / 2,
        top = popupTitleRec.y + popupTitleRec.height / 2,
        height = popupWidth - popupTitleRec.height - 40,
        width = popupWidth,
        backgroundColor = { 0.9, 0.9, 0.9 },
        noLines = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch
    }
    localGroup:insert(tableView)

    local close_button = widget.newButton
    {
        width = 150 ,
        height = 30 ,
        left = display.contentCenterX - 150 / 2,
        top = tableView.y + tableView.height / 2 + 10, 
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["popup_close_button"],
        onRelease = closeButtonEvent
    }
    localGroup:insert(close_button)
    
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_center_type_list(utils.getLanguageType4api(lang), listCallback)
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