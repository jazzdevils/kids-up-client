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
require("widgets.activityIndicator")

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local countryId, countryName, countries, localGroup
local centerAddressRefData
local popupWidth = __appContentWidth__ - 100
local popupHeight = display.contentCenterY
local txtFirstClicked = false
local activityIndicator

local function touchStateListener( event )
    local img = event.target
    centerAddressRefData.countryId = img.countryId
    centerAddressRefData.countryName = img.countryName
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
    rowBgImg.countryId = countries[row.index].id
    rowBgImg.countryName = countries[row.index].name
    rowBgImg:addEventListener( "touch", touchStateListener )
    local options = {
        parent = row,
        x = rowWidth / 2,
        y = rowHeight * 0.5,
        text = countries[row.id].name,
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

local function closeButtonEvent( event )
    if event.phase == "ended" then
       storyboard.hideOverlay( "crossFade", 300 ) 
    end
    
    return true
end

local function renderTableView( data )
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
        text = language["joinScene"]["country_select_txt"],
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
        height = popupWidth - popupTitleRec.height - 40,
        width = popupWidth,
        backgroundColor = { 0.9, 0.9, 0.9 },
        noLines = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch
    }
    for i = 1, data.country_cnt do
        tableView:insertRow(
            {
                rowHeight = 34,
                rowColor = { default = { 0.9, 0.9, 0.9 } }
            }
        )
    end
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
end

local function listCallback(event)
    if (activityIndicator) then
        activityIndicator:destroy()
    end    
    
    if ( event.isError ) then
        print( "Network error!")
        storyboard.hideOverlay()
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            if (data) then
                if(data.status == "OK") then
                    countries = data.country
                    renderTableView(data)
                else
                    utils.showMessage(language["joinScene"]["join_error"])
                end
            end
        else
            storyboard.hideOverlay()
            utils.showMessage(language["common"]["wrong_connection"])
        end
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    localGroup = group
    local params = event.params
    if ( params.centerAddressRefData ~= nil ) then
        centerAddressRefData = params.centerAddressRefData
    end
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.country_list_api(listCallback)
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