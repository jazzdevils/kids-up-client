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
local countryId, countryName, countries, localGroup, centerInfo
local centerAddressRefData
local popupWidth = __appContentWidth__ - 50
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
    local rowData = row.params.center_data
    
    row.rightArrow = display.newImageRect("images/assets1/icon_detail.png", 20 , 20)
    row.rightArrow.anchorX = 0
    row.rightArrow.anchorY = 0
    row.rightArrow.x = 10
    row.rightArrow.y = (rowHeight - row.rightArrow.height) * 0.5
    row:insert(row.rightArrow)
    
    local labelWidth = rowWidth - 20 - row.rightArrow.width
    
    local centername_options = {
        width = labelWidth,
        text = rowData.center_name,     
        font = native.systemFontBold,   
        fontSize = __DEFAULT_FONT_SIZE__,
        align = "left"  --new alignment parameter
    }
    row.centername = display.newText(centername_options)
    row.centername.anchorX = 0
    row.centername.anchorY = 0
    row.centername:setFillColor( 0 )
    row.centername.y = 10
    row.centername.x = row.rightArrow.x + row.rightArrow.width + 10
    row:insert(row.centername)
--    rowTitle:setFillColor( unpack(__POPUP_TABLE_ROW_TXT_COLOR__) )

    local addr = rowData.country_name .. " ".. rowData.state_name .. " ".. rowData.city_name .." "..rowData.address_detail  
--    local addr = "You can construct URLs to a song or artist page once you know its id as returned by API calls above."
    local addr_options = {
        width = labelWidth,
        text = addr,     
        font = native.systemFont,   
        fontSize = __DEFAULT_FONT_SIZE__,
        align = "left"  --new alignment parameter
    }
    row.addr = display.newText(addr_options)
    row.addr.anchorX = 0
    row.addr.anchorY = 0
    row.addr:setFillColor( 0 )
    row.addr.y = row.centername.y + row.centername.height + 8
    row.addr.x = row.centername.x
    row:insert(row.addr)
    
    local createdate_options = {
        text = utils.convert2LocaleDateStringFromYYYYMMDD(rowData.regist_date),     
        font = native.systemFont,   
        fontSize = __DEFAULT_FONT_SIZE__,
        align = "left"  --new alignment parameter
    }
    row.createDate = display.newText(createdate_options)
    row.createDate.anchorX = 0
    row.createDate.anchorY = 0
    row.createDate:setFillColor( 0 )
    row.createDate.y = rowHeight - row.createDate.height - 4
    row.createDate.x = row.addr.x
    row:insert(row.createDate)
    
    if rowData.invitation_code ~= "" then
        local invitation_options = {
            text = language["searchCenterListScene"]["exist_invitation_code"],     
            font = native.systemFont,   
            fontSize = __DEFAULT_FONT_SIZE__,
            align = "left"  --new alignment parameter
        }
        row.invitation = display.newText(invitation_options)
        row.invitation.anchorX = 0
        row.invitation.anchorY = 0
        row.invitation:setFillColor( 0 )
        row.invitation.y = row.createDate.y 
        row.invitation.x = row.createDate.x + row.createDate.width + 10
        row:insert(row.invitation)
    end
        
end

local function onRowTouch( event )
    local phase = event.phase
    local row = event.target
    local center_data = row.params.center_data
    if "release" == phase  then
        centerAddressRefData.countryId = center_data.country_id
        centerAddressRefData.countryName = center_data.country_name
        centerAddressRefData.stateId = center_data.state_id
        centerAddressRefData.stateName = center_data.state_name
        centerAddressRefData.cityId = center_data.city_id
        centerAddressRefData.cityName = center_data.city_name
        centerAddressRefData.centerId = center_data.center_id
        centerAddressRefData.centerName = center_data.center_name
        centerAddressRefData.invitationCode = center_data.invitation_code
        
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
    local popupFrame = display.newImageRect(localGroup, "images/bg_set/bg_frame_full.png", __appContentWidth__ - 20, __appContentHeight__ - 100)
    popupFrame.x = display.contentCenterX
    popupFrame.y = display.contentCenterY

    local popupTitleRec = display.newRect( localGroup, popupFrame.x, popupFrame.y - popupFrame.height / 2 + 12 + 6, popupFrame.width - 10, 30 , 6)
    popupTitleRec.strokeWidth = 0
    popupTitleRec:setFillColor( unpack(__POPUP_TITLE_BG_COLOR__) )

    local popupTitleOptions = 
    {
        parent = localGroup,
        text = language["searchCenterListScene"]["title"],
        x = popupTitleRec.x,
        y = popupTitleRec.y,
        width = popupFrame.width - 6,
        font = native.systemFontBold,
        fontSize = __textLabelFontSize__,
        align = "center"
    }
    local popupTitle = display.newText(popupTitleOptions)
    popupTitle:setFillColor( unpack(__POPUP_TITLE_TXT_COLOR__) )

    local tableView = widget.newTableView
    {
        left = popupTitleRec.x - (popupTitleRec.width) / 2,
        top = popupTitleRec.y + popupTitleRec.height / 2 ,
        height = popupFrame.height - popupTitleRec.height - 45,
        width = popupTitleRec.width ,
        backgroundColor = { 1, 1, 1 },
        rowTouchDelay = __tableRowTouchDelay__,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch
    }
    for i = 1, data.center_cnt do
        tableView:insertRow(
            {
                rowHeight = 90,
                rowColor = { default = { 1, 1, 1 }, over = { 0.8, 0.8, 0.8} },
                params = {
                    center_data = data.center[i],
                }
            }
        )
    end
    localGroup:insert(tableView)

    local close_button = widget.newButton
    {
        width = 150 ,
        height = 30 ,
        left = display.contentCenterX - 150 / 2,
        top = tableView.y + tableView.height / 2 + 5 , 
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["searchCenterListScene"]["popup_close_button"],
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
                    if data.center_cnt > 0 then
                        renderTableView(data)
                    else
                        storyboard.hideOverlay()
                        
                        utils.showMessage(language["searchCenterListScene"]["no_data"])
                    end
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
    api.get_CenterList_byName(centerAddressRefData.centerType, params.searchName, listCallback) 
--    api.get_CenterList_byName(centerAddressRefData.centerType, "レインボ", listCallback) 
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

