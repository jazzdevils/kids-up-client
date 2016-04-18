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
local json = require("json")

local navBar
local activityIndicator

local mngTableView
local LEFT_PADDING = 10

local function onRowTouch(event)
    local index = event.target.index
    local obj = event.target
    
    if(event.phase == "release") then
        
    end
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    local rowData = row.params.center_data
    
    if(rowData) then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 6, 6)
        row.rect.anchorX= 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) /2
        row.rect.y = 2
        row:insert(row.rect)

        local strType = "Type : " .. rowData.center_type_name
        row.title = display.newText(strType, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.title.anchorX = 0
        row.title.anchorY = 0
        row.title:setFillColor( 0 )
        row.title.x = row.rect.x + LEFT_PADDING
        row.title.y = 10
        row:insert(row.title)
        
        local strCenterName = "CenterName : " .. rowData.center_name
        row.centername = display.newText(strCenterName, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.centername.anchorX = 0
        row.centername.anchorY = 0
        row.centername:setFillColor( 0 )
        row.centername.x = row.title.x
        row.centername.y = row.title.y + row.title.height + 2
        row:insert(row.centername)
        
        local strAddress = "Address : " .. rowData.country_name .. " "..rowData.state_name .. " "..rowData.city_name
        row.address = display.newText(strAddress, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.address.anchorX = 0
        row.address.anchorY = 0
        row.address:setFillColor( 0 )
        row.address.x = row.title.x
        row.address.y = row.centername.y + row.centername.height + 2
        row:insert(row.address)
        
        row.address_detail = display.newText(rowData.address_detail, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.address_detail.anchorX = 0
        row.address_detail.anchorY = 0
        row.address_detail:setFillColor( 0 )
        row.address_detail.x = row.title.x
        row.address_detail.y = row.address.y + row.address.height + 2
        row:insert(row.address_detail)
        
        local strName = "Name : " .. rowData.member_name
        row.name = display.newText(strName, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.name.anchorX = 0
        row.name.anchorY = 0
        row.name:setFillColor( 0 )
        row.name.x = row.title.x
        row.name.y = row.address_detail.y + row.address_detail.height + 2
        row:insert(row.name)
        
        local strEmail = "E-Mail : " .. rowData.email
        row.email = display.newText(strEmail, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.email.anchorX = 0
        row.email.anchorY = 0
        row.email:setFillColor( 0 )
        row.email.x = row.title.x
        row.email.y = row.name.y + row.name.height + 2
        row:insert(row.email)
        
        local strPhone = "Phone : " .. rowData.phonenum
        row.phonenum = display.newText(strPhone, 12, 0, native.systemFontBold, __textLabelFont12Size__ )
        row.phonenum.anchorX = 0
        row.phonenum.anchorY = 0
        row.phonenum:setFillColor( 0 )
        row.phonenum.x = row.title.x
        row.phonenum.y = row.email.y + row.email.height + 2
        row:insert(row.phonenum)
        
--        local stampDate = utils.getTimeStamp(rowData.createtime)
        local stampDate = rowData.createtime
        row.createtime = display.newText(stampDate, 12, 0, native.systemFont, __textLabelFont12Size__)
        row.createtime.anchorX = 0
        row.createtime:setFillColor( 0.375, 0.375, 0.375 )
        row.createtime.y = row.title.x
        row.createtime.x = row.rect.width - row.createtime.width - 2
        row:insert(row.createtime)
        
        row.ok_button = widget.newButton
        {
            width = 60,
            height = 30,
            defaultFile = "images/button/btn_purple_1_normal.png",
            overFile = "images/button/btn_purple_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            labelYOffset = -2,
            fontSize = __textLabelFont12Size__,
            label = "OK",
            onRelease = function(event)
                            if event.phase == "ended" then
                                native.showAlert(language["appTitle"], "Are you sure OK?", { "Yes", "No"}, 
                                    function(event)
                                        if "clicked" == event.action then
                                            local i = event.index
                                            if 1 == i then
                                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                                                api.do_Center_Ask_Approve(rowData.center_id, 
                                                    function(e)
                                                        activityIndicator:destroy()
                                                        if(e.isError) then
                                                        else
                                                            mngTableView._view._velocity = 0
                                                            mngTableView:deleteRow(row.index)
                                                        end
                                                    end
                                                )     
                                            end
                                        end    
                                    end
                                )
                            end
                        end
        }
        row.ok_button.anchorX = 0
        row.ok_button.anchorY = 0
        row.ok_button.x = row.title.x
        row.ok_button.y = row.rect.y + row.rect.height - row.ok_button.height - 2
        row:insert(row.ok_button)

        row.delete_button = widget.newButton
        {
            width = 60,
            height = 30,
            defaultFile = "images/button/btn_blue_1_normal.png",
            overFile = "images/button/btn_blue_1_touched.png",
            labelColor = { default={1,1,1}, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            labelYOffset = -2,
            fontSize = __textLabelFont12Size__,
            label = "Delete",
            onRelease = function(event)
                            if event.phase == "ended" then
                                native.showAlert(language["appTitle"], "Are you sure delete?", { "Yes", "No"}, 
                                    function(event)
                                        if "clicked" == event.action then
                                            local i = event.index
                                            if 1 == i then
                                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["delete"])
                                                    
                                                api.delete_Center_Ask_Approve(rowData.center_id, 
                                                    function(e)
                                                        activityIndicator:destroy()
                                                        if(e.isError) then
                                                        else
                                                            mngTableView._view._velocity = 0
                                                            mngTableView:deleteRow(row.index)
                                                        end
                                                    end
                                                )       
                                            end
                                        end    
                                    end
                                )
                            end
                        end
        }
        row.delete_button.anchorX = 0
        row.delete_button.anchorY = 0
        row.delete_button.x = row.title.x + row.ok_button.width + 20
        row.delete_button.y = row.ok_button.y
        row:insert(row.delete_button)
        
        if rowData.approval_state == 1 then --이메일 인증 완료한 경우
            row.approve_icon = display.newImageRect("images/assets1/icon_attend.png", 15 , 15)
            row.approve_icon.anchorX = 0
            row.approve_icon.anchorY = 0
            row.approve_icon.x = row.rect.width - row.approve_icon.width
            row.approve_icon.y = row.rect.height - row.approve_icon.height
            row:insert(row.approve_icon)
            
            row.ok_button.isVisable = false --인증한곳은 인증버튼 필요없음
        end
            
--        row.approve_icon = approval_state address_detail
    else
        --Row 데이타가 없음..따라서 데이타 없다고 표시
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row:insert(row.rect )

        row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
        row.noDataimg.anchorY = 0
        row.noDataimg.x = display.contentCenterX
        row.noDataimg.y = 20
        row:insert(row.noDataimg)

        row.noData_txt = display.newText("Nothing", 12, 0, native.systemFont, 12)
        row.noData_txt.anchorY = 0
        row.noData_txt:setFillColor( 0 ,0 ,0 )
        row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
        row.noData_txt.x = display.contentCenterX
        row:insert(row.noData_txt)
    end
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene("scripts.settingScene", "slideRight", 300)
    end
    
    return true
end

local function getDataCallback(event)
    local function makeRow(json_data)
        if(mngTableView) then
            local cnt = json_data.approval_cnt
            if(cnt > 0) then
                mngTableView:deleteAllRows()

                for i = 1, cnt do
                    mngTableView:insertRow{
                        rowHeight = 170,
                        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            center_data = json_data.approval[i],
                        }
                    }		
                end
            else
                mngTableView:deleteAllRows()

                mngTableView:insertRow{
                     rowHeight = 280,
                     rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                     lineColor = { 0.5, 0.5, 0.5 },
                     params = {
                        center_data = nil
                    }
                }
            end
        end
        
        return true
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

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = "Back",
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }

    navBar = widget.newNavigationBar({
            title = "Administrator",
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
        })
    group:insert(navBar)
    
    mngTableView = widget.newTableView{
        top = navBar.height,
        height = __appContentHeight__ - navBar.height - __statusBarHeight__,
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
    mngTableView.x = display.contentWidth / 2
    group:insert(mngTableView)   
        
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_Center_Ask_Approval_List( getDataCallback )
    
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = __DEFAULT_HOMESCENE_NAME__
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







