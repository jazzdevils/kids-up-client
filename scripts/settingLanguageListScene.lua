---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
local user = require("scripts.user_data")
local lanCode = require("scripts.translatorLanguageCodes")
local userSetting = require("scripts.userSetting")

local NAME_BAR_HEIGHT = 30
local navBar
local nameRect

local languageTableView

local function onRowTouch(event)
    local index = event.target.index
        
    if(event.phase == "release") then
        local languageCode = lanCode:getLanguageCode(index)
        if(languageCode) then
            userSetting.settings.toTranslatorLanguageCode = languageCode.code
            userSetting.saveSetting()
            
            local options = {
                effect = "fromLeft",
                time = 300,
                params = {
                    fromLogout = true,
                }
            } 
            storyboard.isAction = true
            storyboard.purgeScene("scripts.settingScene")    
            storyboard.gotoScene("scripts.settingScene", options)    
        end
    end
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    local rowData = row.params.code_data
    local code_index = row.params.code_index
    
    row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
    row:insert(row.rect )
    
    row.code_name = display.newText(rowData.name,0, 0, native.systemFontBold, 12)
    row.code_name.anchorX = 0
    row.code_name.anchorY = 0
    row.code_name:setFillColor(0, 0, 0)
    row.code_name.x = 20
    row.code_name.y = (row.height - row.code_name.height) /2
    row:insert(row.code_name)
    
    row.checkedImg = display.newImageRect("images/input/radio_checked.png", 22, 22)
    row.checkedImg.anchorX = 0
    row.checkedImg.anchorY = 0
    row.checkedImg.x = row.rect.width - row.checkedImg.width - 2
    row.checkedImg.y = (row.height - row.checkedImg.height) /2
    row:insert(row.checkedImg)
    row.checkedImg.isVisible = false
    
    if(index == code_index) then
        row.checkedImg.isVisible = true
    else
        row.checkedImg.isVisible = false
    end
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene("scripts.settingScene")
        storyboard.gotoScene("scripts.settingScene", "slideRight", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["settingLanguageListScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }

    nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
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
    
    navBar = widget.newNavigationBar({
            title = language["settingLanguageListScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
        })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
--    native.setActivityIndicator( true )
    languageTableView = widget.newTableView{
        top = navBar.height + nameRect.height + 10,
        height = __appContentHeight__ - navBar.height - nameRect.height - __statusBarHeight__,
        width = display.contentWidth,
        maxVelocity = 1, 
        rowTouchDelay = 60,
--        isLocked = true,
        hideBackground = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
--        noLine = true,
        listener = nil,
    }
    languageTableView.x = display.contentWidth / 2
    group:insert(languageTableView)   
        
    local code_index = lanCode:getIndexOfLanguageCode(userSetting.settings.toTranslatorLanguageCode)    
    for i = 1, #lanCode.codes do
        languageTableView:insertRow{
            rowHeight = 40,
            rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
            lineColor = { 0.5, 0.5, 0.5, 0 },
            params = {
                code_data = lanCode.codes[i],
                code_index = code_index
            }
        }
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
    storyboard.returnTo = "scripts.settingScene"
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







