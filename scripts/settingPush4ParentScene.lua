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
local user = require("scripts.user_data")
local api = require("scripts.api")
local utils = require("scripts.commonUtils")
local json = require("json")
local activityIndicator

local NAME_BAR_HEIGHT = 30
local navBar
local nameRect
local settingTableView
widget.setTheme( "widget_theme_ios7" )

local function onRowTouch(event)
    local index = event.target.index
    local obj = event.target
end

local function setDataCallback(event)   
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
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
                    
                else
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage(language["common"]["wrong_connection"])
                end
            end
        end
    end
    return true
end

local function onOffSwitchListener( event )
    if utils.IS_Demo_mode(storyboard, true) == true then
        return true
    end
    
    local index = event.target.index
    local pushKey = ""
    local pushValue = "1"
    if(index == 1) then
        pushKey = "contact"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    elseif(index == 2) then
        pushKey = "notice"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    elseif(index == 3) then
        pushKey = "event"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    elseif(index == 4) then
        pushKey = "dailymenu"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    elseif(index == 5) then
        pushKey = "reply"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    elseif(index == 6 and user.userData.jobType == __PARENT__) then
        pushKey = "attendance"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    elseif(index == 6 and user.userData.jobType ~= __PARENT__) then
        pushKey = "confirm"
        if(event.target.isOn == true) then
            pushValue = "1"
        else
            pushValue = "0"
        end
    end
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
    api.set_push_receive_yn(user.userData.id, pushKey, pushValue, setDataCallback)
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    local pushValue = row.params.push_value;
    local onOffSwitchStatus 
    
    row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
    row.rect.anchorX = 0
    row.rect.anchorY = 0
    row.rect.x = (row.width - row.rect.width)/2
    row.rect.y = (row.height - row.rect.height)/2
    row:insert(row.rect )
    if index == 1 then
        row.news_txt = display.newText(language["settingPush4ParentScene"]["message"],0, 0, native.systemFontBold, 12)
        row.news_txt.anchorX = 0
        row.news_txt.anchorY = 0
        row.news_txt:setFillColor(0, 0, 0)
        row.news_txt.x = 20
        row.news_txt.y = (row.height - row.news_txt.height) /2
        row:insert(row.news_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end    
    elseif index == 2 then
        row.notice_txt = display.newText(language["settingPush4ParentScene"]["notice"],0, 0, native.systemFontBold, 12)
        row.notice_txt.anchorX = 0
        row.notice_txt.anchorY = 0
        row.notice_txt:setFillColor(0, 0, 0)
        row.notice_txt.x = 20
        row.notice_txt.y = (row.height - row.notice_txt.height) /2
        row:insert(row.notice_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end
    elseif index == 3 then
        row.event_txt = display.newText(language["settingPush4ParentScene"]["event"],0, 0, native.systemFontBold, 12)
        row.event_txt.anchorX = 0
        row.event_txt.anchorY = 0
        row.event_txt:setFillColor(0, 0, 0)
        row.event_txt.x = 20
        row.event_txt.y = (row.height - row.event_txt.height) /2
        row:insert(row.event_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end
    elseif index == 4 then
        row.meals_txt = display.newText(language["settingPush4ParentScene"]["mealmenu"],0, 0, native.systemFontBold, 12)
        row.meals_txt.anchorX = 0
        row.meals_txt.anchorY = 0
        row.meals_txt:setFillColor(0, 0, 0)
        row.meals_txt.x = 20
        row.meals_txt.y = (row.height - row.meals_txt.height) /2
        row:insert(row.meals_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end
    elseif index == 5 then
        row.comment_txt = display.newText(language["settingPush4ParentScene"]["comment"],0, 0, native.systemFontBold, 12)
        row.comment_txt.anchorX = 0
        row.comment_txt.anchorY = 0
        row.comment_txt:setFillColor(0, 0, 0)
        row.comment_txt.x = 20
        row.comment_txt.y = (row.height - row.comment_txt.height) /2
        row:insert(row.comment_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end
    elseif index == 6 and user.userData.jobType == __PARENT__ then
        row.comment_txt = display.newText(language["settingPush4ParentScene"]["attendance"],0, 0, native.systemFontBold, 12)
        row.comment_txt.anchorX = 0
        row.comment_txt.anchorY = 0
        row.comment_txt:setFillColor(0, 0, 0)
        row.comment_txt.x = 20
        row.comment_txt.y = (row.height - row.comment_txt.height) /2
        row:insert(row.comment_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end
    elseif index == 6 and user.userData.jobType ~= __PARENT__ then
        row.comment_txt = display.newText(language["settingPush4ParentScene"]["confirm"],0, 0, native.systemFontBold, 12)
        row.comment_txt.anchorX = 0
        row.comment_txt.anchorY = 0
        row.comment_txt:setFillColor(0, 0, 0)
        row.comment_txt.x = 20
        row.comment_txt.y = (row.height - row.comment_txt.height) /2
        row:insert(row.comment_txt)
        
        if(pushValue[index] == "1") then
            onOffSwitchStatus = true
        else
            onOffSwitchStatus = false
        end
    end
    
    row.onOffSwitch = widget.newSwitch
    {   
        initialSwitchState = onOffSwitchStatus,
        onRelease = onOffSwitchListener,
    }
    row.onOffSwitch.x = row.rect.width - row.onOffSwitch.width + (row.onOffSwitch.width/2)
    row.onOffSwitch.y = row.rect.height - (row.onOffSwitch.height/2) 
    row.onOffSwitch.index = index
    row:insert(row.onOffSwitch)
end

local function getDataCallback(event)
    local function makeRow(json_data)
        local v = {}
        v[1] = json_data.contact
        v[2] = json_data.notice
        v[3] = json_data.event
        v[4] = json_data.dailymenu
        v[5] = json_data.reply        
        if (user.userData.jobType == __PARENT__) then --학부모의 경우만 출석부 푸시 설정 가능
            v[6] = json_data.attendance
        end
        if (user.userData.jobType ~= __PARENT__) then --선생 또는 원장의 경우만 확인 푸시 설정 가능
            v[6] = json_data.confirm
        end
        
        if(settingTableView) then
            for i = 1, #v do
                settingTableView:insertRow{
                    rowHeight = 50,
                    rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                    lineColor = { 0.5, 0.5, 0.5, 0 },
                    params = {
                        push_value = v
                    }
                }
            end
        end
    end
    
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
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
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage(language["common"]["wrong_connection"])
                end
            end
        end
    end
    return true
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
        label = language["settingPush4ParentScene"]["back"],
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
            title = language["settingPush4ParentScene"]["title"],
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
    settingTableView = widget.newTableView{
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
    settingTableView.x = display.contentWidth / 2
    group:insert(settingTableView)   
    
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_push_receive_yn_list(user.userData.id, getDataCallback)
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