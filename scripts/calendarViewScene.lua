
---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local tablespinner = require ("scripts.tablespinner")
local api = require("scripts.api")
local user = require("scripts.user_data")
local authority = require("scripts.user_authority")
local sceneData = require("scripts.sceneData")
local userSetting = require("scripts.userSetting")

local ROW_HEIGHT = 120
local ATTENDANCE_ROW_HEIGHT = 70
local REFRESH_ROW_HEIGHT = 50
local DATE_RECT_WIDTH = 30
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local LEFT_PADDING = 10

local calendarTable
local somethingActionOnScene

local activityIndicator
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function translatorView(event)
    local srcContents = event.target.srcContents
    local srcTitle = event.target.srcTitle
    
    if(srcTitle ~= "" or srcContents ~= "") then
        local options = {
            effect = "fromRight",
            time = 300,
            isModal = true,
            params = {
                srcTitle = srcTitle,
                srcContents = srcContents
            }
        }
        
        storyboard.showOverlay("scripts.translatorViewScene", options) 
    end
end

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.schedule_data
    
    if(rowData) then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row.rect.anchorX= 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) /2
        row.rect.y = 5
        row:insert(row.rect)
        
        if(rowData.deletable == __DELETABLE_SCEDULE__) then
            row.delete_icon = display.newImageRect("images/assets1/icon_delete.png", 20, 20)
            row.delete_icon.anchorX = 0
            row.delete_icon.anchorY = 0
            row.delete_icon.x = row.rect.x + row.rect.width - row.delete_icon.width - 5
            row.delete_icon.y = row.rect.y + row.rect.height - row.delete_icon.height - 5
            row:insert(row.delete_icon)
            
            row.delete_icon:addEventListener("tap", 
                function(event)
                    if utils.IS_Demo_mode(storyboard, true) == true then
                        return true
                    end
                    
                    native.showAlert(language["appTitle"], language["calendarScene"]["delete_question"]
                        , { language["calendarScene"]["yes"], language["calendarScene"]["no"]}, 
                        function(event)
                            if "clicked" == event.action then
                                local i = event.index
                                if 1 == i then
                                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["delete"])
                                    somethingActionOnScene = true
                                    api.delete_schedule_data(rowData.id, 
                                        function(e)
                                            activityIndicator:destroy()
                                            if(e.isError) then
                                            else
                                                calendarTable._view._velocity = 0
                                                calendarTable:deleteRow(index)
                                            end
                                        end
                                    )    
                                end
                            end    
                        end
                    )
                end
            )    
        end
        
        if(rowData.type == __ATTENDANCE_TYPE__) then
            local emoticonSize = row.rect.height - 10
            row.emoticon = display.newImageRect("images/assets1/icon_calendar_attend.png", emoticonSize, emoticonSize)
            row.emoticon.anchorX = 0
            row.emoticon.anchorY = 0
            row.emoticon.x = row.rect.x + LEFT_PADDING
            row.emoticon.y = row.rect.y + (row.rect.height - emoticonSize)/2
            row:insert(row.emoticon)
            
            row.attendance_txt = display.newText(language["calendarScene"]["attendance"], 12, 0, native.systemFontBold, __VIEW_SCENE_TEXT_SIZE__ )
            row.attendance_txt.anchorX = 0
            row.attendance_txt.anchorY = 0
            row.attendance_txt:setFillColor( 0 )
            row.attendance_txt.x = row.emoticon.x + row.emoticon.width + LEFT_PADDING
            row.attendance_txt.y = row.rect.y + (row.rect.height - row.attendance_txt.height)/2
            row:insert(row.attendance_txt)
        else
            local sTitle = rowData.title
            row.title = display.newText(sTitle, 12, 0, native.systemFontBold, 12 )
            row.title.anchorX = 0
            row.title.anchorY = 0
            row.title:setFillColor( 0 )
            row.title.x = row.rect.x + LEFT_PADDING
            row.title.y = 10
            row:insert(row.title)
            
            local content_txt_options = {
                text = rowData.detail,     
                width = row.rect.width - 20,
                font = native.systemFont,   
                fontSize = __VIEW_SCENE_TEXT_SIZE__,
                align = "left"  --new alignment parameter
            }
            
            row.paragraphs = {}
            local yOffset = utils.setParagraphContents(row, rowData.detail, content_txt_options, row.title.y + row.title.height, row.title.x)
            
            local urlTable = utils.getURLfromContents(rowData.detail)
            for i = 1, #urlTable do
                content_txt_options.text = urlTable[i]

                local url_text = display.newText(content_txt_options)
                url_text.anchorX = 0
                url_text.anchorY = 0
                url_text.x = row.rect.x + LEFT_PADDING
                url_text.y = yOffset + 5
                row:insert(url_text)
                url_text:setFillColor(unpack( __URL_LINK_COLOR__ ))
                yOffset = yOffset + url_text.height + 5

                url_text:addEventListener("tap", 
                    function()
                        system.openURL( urlTable[i] )
                    end
                )
            end
            
            if(userSetting.settings.toTranslatorLanguageCode ~= "")then
                row.transButton = display.newText(language["calendarScene"]["translation"], 0, 0, native.systemFont, 12)
                row.transButton.anchorX = 0
                row.transButton.anchorY = 0
                row.transButton:setFillColor(0, 0, 1)
                row.transButton.x = row.rect.x + LEFT_PADDING
                row.transButton.y = yOffset + 10--row.contents.y + row.contents.height + 10
                row.transButton.srcTitle = rowData.title
                row.transButton.srcContents = rowData.detail
                row:insert(row.transButton)

                row.transButton:addEventListener("tap", translatorView)
            end
        end
    end
end

local function getHeightofString(str, _width, _font, _fontSize)
    local content_txt_options = 
    {
        text = "",     
        width = _width,
        font = _font,   
        fontSize = _fontSize,
        align = "left",  --new alignment parameter
    }
    local height = utils.getParagraphContentsHeight(str, content_txt_options)
    return height
end
        
local function getDataCallback(event)
    local function makeRow(json_data)
        if(calendarTable) then
            local cnt = json_data.schedule_cnt
            
            if(cnt > 0) then
                for i = 1, cnt do
                    local scheduleType = json_data.schedule[i].type
                    if(scheduleType == __ATTENDANCE_TYPE__) then
                        calendarTable:insertRow{
                            rowHeight = ATTENDANCE_ROW_HEIGHT,
                            rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                            lineColor = { 0.5, 0.5, 0.5 },
                            params = {
                                schedule_data = json_data.schedule[i]
                            }
                        }
                    else
                        calendarTable:insertRow{
                            rowHeight = getHeightofString(json_data.schedule[i].detail, calendarTable.width - 30, native.systemFont, __VIEW_SCENE_TEXT_SIZE__) + 70,
                            rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                            lineColor = { 0.5, 0.5, 0.5 },
                            params = {
                                schedule_data = json_data.schedule[i]
                            }
                        }
                    end
                        		
                end
            end    
        end
        
        return true
    end
    
    if(activityIndicator) then
        activityIndicator:destroy()
    end
--    native.setActivityIndicator( false )
    
    if ( event.isError ) then
        print( "Network error!")
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print(event.status)
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
                    makeRow(data)
                else
                    utils.showMessage(language["common"]["wrong_connection"])
                end
            end
        end
    end
    
    return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        if(somethingActionOnScene == true) then
            storyboard.purgeScene("scripts.calendarScene")
        end
        storyboard.gotoScene("scripts.calendarScene", "slideRight", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    somethingActionOnScene = false
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["calendarScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }
    
    calendarTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + DATE_RECT_WIDTH,
	height = __appContentHeight__ - NAVI_BAR_HEIGHT - NAME_BAR_HEIGHT - __statusBarHeight__ - DATE_RECT_WIDTH,
        width = __appContentWidth__,
	maxVelocity = 1, 
        backgroundColor = { 0.9, 0.9, 0.9, 0},
	noLines = true,
        hideBackground = true,    
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
	onRowRender = onRowRender,
    }
    calendarTable.x = display.contentCenterX
    group:insert(calendarTable)   
    
    local nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    local dateRect = display.newRect(group, display.contentCenterX, 0, __appContentWidth__, DATE_RECT_WIDTH)
    dateRect.anchorY = 0
    dateRect.y = nameRect.y + (nameRect.height / 2)
    dateRect.strokeWidth = 0
    dateRect:setFillColor(unpack(__SELECT_CLASS_RECT_COLOR__))
    
    local sDate = utils.convert2LocaleDateString(event.params.year, event.params.month, event.params.day)..
            " ("..utils.getDayOfWeek(event.params.year, event.params.month, event.params.day)..")"
    
    local dateText = display.newText(sDate, 0, 0, native.systemFontBold, 12)
--    dateText.anchorX = 0
    dateText.anchorY = 0
    dateText.x = display.contentCenterX
    dateText.y = dateRect.y + (dateRect.height - dateText.height)/2
    dateText:setFillColor( 0 )
    group:insert(dateText)
    
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
    
    
    local navBar = widget.newNavigationBar({
        title = language["calendarViewScene"]["title"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
--        includeStatusBar = true
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    
    local paramDate = string.format("%04d",event.params.year)..string.format("%02d",event.params.month)..string.format("%02d",event.params.day)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_schedule_detail2(user.userData.centerid, user.userData.id, user.getActiveKid_IDByAuthority(), paramDate, getDataCallback)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.calendarScene"
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


