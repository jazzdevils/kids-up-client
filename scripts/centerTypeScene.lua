---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language, lang = getLanguage()
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
local json = require("json")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local navBar
local memberType, memberTypeLabel, centerType, centerTypeLabel
local countryId, countryName, stateId, stateName, cityId, cityName, centerName, centerId, classId, className, invitationCode, detailAddress
local NAVI_BAR_HEIGHT = 50
local ROW_HEIGHT = 70
local centerTypeTable
local activityIndicator

local function onBackButton(event)
    if event.phase == "ended" then
        local options = {
            effect = "slideRight",
            time = 300,
            params = {
                memberType = memberType,
                memberTypeLabel = memberTypeLabel,
                centerType = centerType,
                centerTypeLabel = centerTypeLabel,
                countryId = countryId,
                countryName = countryName,
                stateId = stateId,
                stateName = stateName,
                cityId = cityId,
                cityName = cityName,
                centerName = centerName,
                detailAddress = detailAddress,
                centerId = centerId,
                classId = classId,
                className = className,
                invitationCode = invitationCode,
            }
        }
        storyboard.purgeScene("scripts.memberTypeScene")
        storyboard.gotoScene( "scripts.memberTypeScene", options) 
    end
    
    return true
end

local function onNextButton(event)
    if event.phase == "ended" then
        if centerType == nil then
            utils.showMessage( language["joinScene"]["notselected_centertype"] )
        else
            local options = {
                effect = "slideLeft",
                time = 300,
                params = {
                    memberType = memberType,
                    memberTypeLabel = memberTypeLabel,
                    centerType = centerType,
                    centerTypeLabel = centerTypeLabel,
                    countryId = countryId,
                    countryName = countryName,
                    stateId = stateId,
                    stateName = stateName,
                    cityId = cityId,
                    cityName = cityName,
                    centerName = centerName,
                    detailAddress = detailAddress,
                    centerId = centerId,
                    classId = classId,
                    className = className,
                    invitationCode = invitationCode,
                }
            }
            if memberType == __TEACHER__ or memberType == __PARENT__ then
                storyboard.purgeScene("scripts.centerAddressScene")
                storyboard.gotoScene( "scripts.centerAddressScene", options ) 
            else
                storyboard.purgeScene("scripts.centerAddress4DirectorScene")
                storyboard.gotoScene( "scripts.centerAddress4DirectorScene", options ) 
            end
        end
    end
    
    return true
end

local function scrollListener( event )
   return true
end

local function onRowTouch( event )
    if event.phase == "release" or event.phase == "tap" then
        local row = event.target
        centerType = row.radioChecked.centerType
        centerTypeLabel = row.radioChecked.centerTypeLabel
        if centerTypeTable:getNumRows() > 0 then
        for k = 1, centerTypeTable:getNumRows() do
            local r = centerTypeTable:getRowAtIndex(k)
            if r then
                local rc = r.radioChecked
                local ru = r.radioUnChecked
                if centerType == rc.centerType then
                    rc.alpha = 1
                    ru.alpha = 0
                else
                    rc.alpha = 0
                    ru.alpha = 1
                end
            end
        end
    end
    end
    return true
end

local function onRowRender( event )
    local row = event.row
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local index = row.index 
    
    local rowData = row.params.centertype;
    if rowData then
--        row.bg = display.newImageRect("images/bg_set/bg_frame_320x110.png", rowWidth - 10, rowHeight)
--        row.bg.x = rowWidth * 0.5
--        row.bg.y = rowHeight * 0.5
--        row:insert(row.bg)
        
        row.roundRect = display.newRoundedRect( 0, 0, rowWidth - 40, row.height - 10, 6 )
        row.roundRect.strokeWidth = 3
        row.roundRect:setFillColor( 1 )
        row.roundRect:setStrokeColor( 118/255, 135/255, 151/255 )
        row.roundRect.anchorX = 0
        row.roundRect.anchorY = 0
        row.roundRect.x = (rowWidth - row.roundRect.width) * 0.5
        row.roundRect.y = (rowHeight - row.roundRect.height) * 0.5
        row:insert(row.roundRect)
        
        row.radioChecked = display.newImageRect("images/input/radio_checked.png", 22, 22)
        row.radioChecked.centerType = rowData.type
        row.radioChecked.centerTypeLabel = rowData.name
        row.radioChecked.anchorX = 0
        row.radioChecked.anchorY = 0
        row.radioChecked.x = row.roundRect.x + 5 
        row.radioChecked.y = row.roundRect.y + 8
        row:insert(row.radioChecked)
        if centerType == rowData.type then
            row.radioChecked.alpha = 1
        else
            row.radioChecked.alpha = 0
        end
        
        row.radioUnChecked = display.newImageRect("images/input/radio_unchecked.png", 22, 22)
        row.radioUnChecked.centerType = rowData.type
        row.radioUnChecked.centerTypeLabel = rowData.name
        row.radioUnChecked.anchorX = 0
        row.radioUnChecked.anchorY = 0
        row.radioUnChecked.x = row.roundRect.x + 5
        row.radioUnChecked.y = row.roundRect.y + 8
        row:insert(row.radioUnChecked)
        if centerType == rowData.type then
            row.radioUnChecked.alpha = 0
        else
            row.radioUnChecked.alpha = 1
        end

        local labelOptions = 
        {
            text = rowData.name,
            width = row.roundRect.width - 50,
            font = native.systemFontBold,   
            fontSize = __textLabelFontSize__,
            align = "left"
        }
        row.label = display.newText(labelOptions)
        row.label:setFillColor( 0,0,0 )
        row.label.anchorX = 0
        row.label.anchorY = 0
        row.label.x = row.radioChecked.x + row.radioChecked.width + 10
        row.label.y = row.radioChecked.y
        row:insert(row.label)
        
        local descOptions = 
        {
            text = rowData.desc,
            width = row.roundRect.width - 50,
            font = native.systemFont,   
            fontSize = __textLabelFont12Size__,
            align = "left"
        }
        row.desc = display.newText(descOptions)
        row.desc:setFillColor( 0,0,0 )
        row.desc.anchorX = 0
        row.desc.anchorY = 0
        row.desc.x = row.label.x
        row.desc.y = (row.roundRect.y + row.roundRect.height) - row.desc.height - 5  --row.label.y + row.label.height + 5
        row:insert(row.desc)
    else
        row.bg = display.newImageRect("images/bg_set/bg_frame_320x110.png", rowWidth - 10, rowHeight - 10)
        row.bg.x = rowWidth * 0.5
        row.bg.y = rowHeight * 0.5
        row:insert(row.bg)

        row.nodataLabel = display.newText( {text = language["common"]["there_is_nodata"], fontSize = __textLabelFont14Size__} )
        row.nodataLabel:setFillColor( 0,0,0,0.3 )
        row.nodataLabel.x = rowWidth * 0.5
        row.nodataLabel.y = rowHeight * 0.5
        row:insert(row.nodataLabel)
    end
end

local function listCallback(event)
    local function makeRow(json_data)
        if(centerTypeTable) then
            local cnt = json_data.centertype_cnt
            if(cnt > 0) then
                centerTypeTable:deleteAllRows()
                for i = 1, cnt do
                    centerTypeTable:insertRow{
                        rowHeight = ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } },
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            centertype = json_data.centertype[i]
                        }
                    }
                end
            else
                centerTypeTable:deleteAllRows()
                centerTypeTable:insertRow{
                    rowHeight = ROW_HEIGHT,
                    rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } },
                    lineColor = { 0.5, 0.5, 0.5 },
                    params = {
                        centertype = nil
                    }
                }
            end
        end
    end
    
    if (activityIndicator) then
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

function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    
    local btn_left_opt = {
        label = language["top"]["back"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onBackButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",
    }

    local btn_right_opt = {
        label = language["top"]["next"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onNextButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_next_normal.png",
        overFile = "images/top_with_texts/btn_top_text_next_touched.png",
    }

    navBar = widget.newNavigationBar({
        title = language["joinScene"]["centertype_select_title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })
    group:insert(navBar)

    local progressFrame = display.newRect( group, display.contentCenterX, navBar.height + 3, __appContentWidth__, 6 )
    progressFrame.strokeWidth = 0
    progressFrame:setFillColor( 0, 0, 0 )
    
    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height
    
    centerTypeTable = widget.newTableView{
        top = navBar.height + progressFrame.height + 20,
        height = __appContentHeight__  - navBar.height - progressFrame.height - picFooter.height - logoFooter.height - 20,
        width = __appContentWidth__ - 40,
        maxVelocity = 1,
        backgroundColor = { 0.9, 0.9, 0.9, 0},
        noLines = true,
        hideBackground = false,
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        listener = scrollListener
    }
    centerTypeTable.x = display.contentCenterX
    group:insert(centerTypeTable)
    
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_center_type_list(utils.getLanguageType4api(lang), listCallback)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    local params = event.params
    if params then
        memberType = params.memberType
        memberTypeLabel = params.memberTypeLabel
        centerType = params.centerType
        centerTypeLabel = params.centerTypeLabel
        countryId = params.countryId
        countryName = params.countryName
        stateId = params.stateId
        stateName = params.stateName
        cityId = params.cityId
        cityName = params.cityName
        centerName = params.centerName
        detailAddress = params.detailAddress
        centerId = params.centerId
        classId = params.classId
        className = params.className
        invitationCode = params.invitationCode
    end
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 2 / 5, 6, 3 )
    progress.anchorX = 0
    progress.anchorY = 0
    progress.x = display.contentWidth - __appContentWidth__
    progress.y = navBar.height
    progress:setFillColor( unpack(__PROGRESS_BAR_COLOR) )
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
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
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

