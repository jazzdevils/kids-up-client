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
local func = require("scripts.commonFunc")

local ROW_HEIGHT = 80
local NODATA_ROW_HEIGHT = 280
local REFRESH_ROW_HEIGHT = 50
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local LEFT_PADDING = 5

local springStart
local needToReload = false
local needToPastload = false
local pullDown = nil
local reloadspinner
local reloadInProgress = false
local newsTable
local springStart

--local firstID--새로운 데이타기 있는지 확인용
local activityIndicator

local tablespinnerImageSheet = graphics.newImageSheet( "images/etc/tablespinner.png", tablespinner:getSheet() )	

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.news_data
    
    if index == 1 then 
        if (pullDown == nil) or (pullDown.x == nil) then
            pullDown = display.newImage( row, "images/etc/downloadarrow.png")
            pullDown.anchorX = 0.5
            pullDown.anchorY = 0.5
            pullDown.x = __appContentWidth__ * 0.5
            pullDown.y = REFRESH_ROW_HEIGHT * 0.5
	else
            pullDown.alpha = 1
	end

	if (reloadspinner == nil)  or (reloadspinner.x == nil) then
            reloadspinner = widget.newSpinner
            {
                width = 128,
		height = 128,
                sheet = tablespinnerImageSheet,
		startFrame = 1,
		count = 8,
		time = 800
            }
	
            reloadspinner.alpha = 0	
            reloadspinner.anchorX = 0.5
            reloadspinner.anchorY = 0.5
            reloadspinner.x = __appContentWidth__*0.5
            reloadspinner.y = REFRESH_ROW_HEIGHT * 0.5
	end
		
	row:insert(reloadspinner)
        
        return
    end
        if(rowData) then
            row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 6, 6)
            row.rect.anchorX= 0
            row.rect.anchorY = 0
            row.rect.x = (row.width - row.rect.width) /2
            row.rect.y = 5
            row:insert(row.rect)
            
            local sTitle = ""
            if (rowData.thread_type == __NOTICE_THREAD_TYPE__) then
                if(rowData.thread_subtype == __COMMENT_SUB_TYPE__) then
                    sTitle = language["newsScene"]["new_comment"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_comment.png", 24 , 24)
                else
                    sTitle = language["newsScene"]["new_notice"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_news.png", 24 , 24)
                end
                
                row.desc = display.newText(language["newsScene"]["mnu_notice"], 12, 0, native.systemFont, __textLabelFontSize__ )
            elseif (rowData.thread_type == __MESSAGE_THREAD_TYPE__) then
                if(rowData.thread_subtype == __COMMENT_SUB_TYPE__) then
                    sTitle = language["newsScene"]["new_comment"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_comment.png", 24 , 24)
                else
                    sTitle = language["newsScene"]["new_message"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_attend.png", 24 , 24)
                end
                
                row.desc = display.newText(language["newsScene"]["mnu_message"], 12, 0, native.systemFont, __textLabelFontSize__ )
            elseif (rowData.thread_type == __EVENT_THREAD_TYPE__) then   
                if(rowData.thread_subtype == __COMMENT_SUB_TYPE__) then
                    sTitle = language["newsScene"]["new_comment"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_comment.png", 24 , 24)
                else
                    sTitle = language["newsScene"]["new_event"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_event.png", 24 , 24)
                end
                
                row.desc = display.newText(language["newsScene"]["mnu_event"], 12, 0, native.systemFont, __textLabelFontSize__ )
            elseif (rowData.thread_type == __APPROVE_THERAD_TYPE__) then   
                
                sTitle = language["newsScene"]["new_approve"]
                row.icon = display.newImageRect("images/assets1/icon_setting_cnf_children.png", 24 , 24)
                row.desc = display.newText(language["newsScene"]["mnu_approve"], 12, 0, native.systemFont, __textLabelFontSize__ )
            elseif (rowData.thread_type == __MAMATALK_THREAD_TYPE__) then    
                if(rowData.thread_subtype == __COMMENT_SUB_TYPE__) then
                    sTitle = language["newsScene"]["new_comment"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_comment.png", 24 , 24)
                else
                    sTitle = language["newsScene"]["new_mamatalk"]
                    row.icon = display.newImageRect("images/assets1/icon_setting_mamatalk.png", 24 , 24)
                end
                
                row.desc = display.newText(language["newsScene"]["mnu_mamatalk"], 12, 0, native.systemFont, __textLabelFontSize__ )
            elseif (rowData.thread_type == __MEALMENU_THREAD_TYPE__) then        
                sTitle = language["newsScene"]["new_mealmenu"]
                row.icon = display.newImageRect("images/assets1/icon_setting_lunch.png", 24 , 24)
                row.desc = display.newText(language["newsScene"]["mnu_mealmenu"], 12, 0, native.systemFont, __textLabelFontSize__ )
            elseif (rowData.thread_type == __KIDS_ATTENDANCE_TYPE__) then        
                sTitle = language["newsScene"]["new_attendance"]
                row.icon = display.newImageRect("images/assets1/icon_setting_attend2.png", 24 , 24)
                row.desc = display.newText(language["newsScene"]["mnu_attendance"], 12, 0, native.systemFont, __textLabelFontSize__ )
            end
            row.icon.anchorX = 0
            row.icon.anchorY = 0
            row.icon.x = row.rect.x + LEFT_PADDING
            row.icon.y = row.rect.y + LEFT_PADDING
            row:insert(row.icon)
            
            row.desc:setFillColor(0.4, 0.5, 0.6)
            row.desc.anchorX = 0
            row.desc.anchorY = 0
            row.desc.x = row.icon.x + row.icon.width + LEFT_PADDING + LEFT_PADDING
            row.desc.y = row.icon.y
            row:insert(row.desc )
            
            row.title = display.newText(sTitle, 12, 0, native.systemFont, __textLabelFontSize__ )
            row.title.anchorX = 0
            row.title.anchorY = 0
            row.title:setFillColor( 0 )
            row.title.x = row.desc.x
            row.title.y = row.desc.y + row.desc.height + 10
            row:insert(row.title )
            
            local stampDate = utils.getTimeStamp(rowData.createtime)
            row.createtime = display.newText(stampDate, 12, 0, native.systemFont, 10)
            row.createtime.anchorX = 0
            row.createtime:setFillColor( 0.375, 0.375, 0.375 )
            row.createtime.y = row.rect.y + row.rect.height - row.createtime.height 
            row.createtime.x = row.title.x
            row:insert(row.createtime)
           
            row.rightArrow = display.newImageRect("images/assets1/icon_detail.png", 20 , 20)
            row.rightArrow.anchorX = 0
            row.rightArrow.anchorY = 0
            row.rightArrow.x = row.rect.width - row.rightArrow.width
            row.rightArrow.y = row.rect.height - row.rightArrow.height

            row:insert(row.rightArrow)
--            row:insert(row.readMsgImg)
        else
            --Row 데이타가 없음..따라서 데이타 없다고 표시
            row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
            row:insert(row.rect )
            
            row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
            row.noDataimg.anchorY = 0
            row.noDataimg.x = display.contentCenterX
            row.noDataimg.y = 20--row.rect.height - row.noData.height
            row:insert(row.noDataimg)
            
            row.noData_txt = display.newText(language["eventScene"]["no_data"], 12, 0, native.systemFont, 12)
            row.noData_txt.anchorY = 0
            row.noData_txt:setFillColor( 0 ,0 ,0 )
            row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
            row.noData_txt.x = display.contentCenterX
            row:insert(row.noData_txt)
        end
end
	
local function getDataCallback(event)
    local function makeRow(json_data)
        if(newsTable) then
            local cnt = json_data.news_cnt
            if(cnt > 0) then
                newsTable:deleteAllRows()

                newsTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                    rowHeight = REFRESH_ROW_HEIGHT,
                    rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 }},
                }
                for i = 1, cnt do
                    newsTable:insertRow{
                        rowHeight = ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            news_data = json_data.news[i]
                        }
                    }		
                end
            else
                --처음부터 데이터가 없었는지 확인
                newsTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                    rowHeight = REFRESH_ROW_HEIGHT,
                    rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0}},
                }--헤더로
                newsTable:insertRow{
                     rowHeight = NODATA_ROW_HEIGHT,
                     rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                     lineColor = { 0.5, 0.5, 0.5 },
                     params = {
                        news_data = nil
                    }
                }--아직 공지가 없다는 내용을 표시하기위한 로row
            end    
        end
        
        return true
    end
    
--    loadingApi = false
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
--            local data = json.decode('{"status":"OK","message":"","news_cnt":5,"news":[{"member_id":"78","device_id":"1","thread_type":"4","thread_id":"276","title":"お知らせ:ううつ","createtime":"2014-11-21 17:21:14"},{"member_id":"78","device_id":"1","thread_type":"1","thread_id":"275","title":"お知らせ:aaa","createtime":"2014-11-21 15:54:52"},{"member_id":"78","device_id":"1","thread_type":"1","thread_id":"274","title":"お知らせ:あああああ","createtime":"2014-11-21 15:51:03"},{"member_id":"78","device_id":"1","thread_type":"1","thread_id":"262","title":"お知らせ:foobar","createtime":"2014-11-21 11:16:18"},{"member_id":"78","device_id":"1","thread_type":"1","thread_id":"262","title":"お知らせ:foobar","createtime":"2014-11-21 11:16:00"}]}')
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

local function reloadTable()
    local function reloadcomplete()   
        if (reloadspinner ~= nil) and (reloadspinner.x ~= nil) then 
	    reloadspinner:stop()
            reloadspinner.alpha = 0
        end	 	   
	transition.to( pullDown, { time=250, rotation=0, onComplete= function()	
                if (pullDown ~= nil) and (pullDown.x ~= nil) then
                    pullDown.alpha = 1; 
	   	end
                reloadInProgress = false; 
	end } )        	 
    end
    newsTable:scrollToIndex(1, 10, nil)
    local reloadCompleteTimer = timer.performWithDelay( 2000, reloadcomplete, 1 )      	 
end

local function onRowTouch( event )
    if event.phase == "release" then
        if(event.target.params.news_data) then
            func.clear_news(user.userData.id, "news") --새소식은 새소식 카운트에서 하나빼기
            
            local rowData = event.target.params.news_data
            local options = {
                effect = "fromRight",
                time = 300,
                params = rowData,
            }        
            
            if (rowData.thread_type == __NOTICE_THREAD_TYPE__) then
                -- noticeViewFromNewsScene
                storyboard.isAction = true
                storyboard.purgeScene("scripts.noticeViewFromNewsScene")
                storyboard.gotoScene("scripts.noticeViewFromNewsScene", options)
            elseif (rowData.thread_type == __MESSAGE_THREAD_TYPE__) then
                -- messageViewFromNewsScene
                storyboard.isAction = true
                storyboard.purgeScene("scripts.messageViewFromNewsScene")
                storyboard.gotoScene("scripts.messageViewFromNewsScene", options)
            elseif (rowData.thread_type == __EVENT_THREAD_TYPE__) then   
                -- eventViewFromNewsScene
                storyboard.isAction = true
                storyboard.purgeScene("scripts.eventViewFromNewsScene")
                storyboard.gotoScene("scripts.eventViewFromNewsScene", options)
            elseif (rowData.thread_type == __APPROVE_THERAD_TYPE__) then   
                storyboard.isAction = true
                storyboard.purgeScene("scripts.askApprovalScene")
                storyboard.gotoScene("scripts.askApprovalScene", options)
            elseif (rowData.thread_type == __MAMATALK_THREAD_TYPE__) then    
                -- mamatalkViewFromNewsScene
                storyboard.isAction = true
                storyboard.purgeScene("scripts.mamatalkViewFromNewsScene")
                storyboard.gotoScene("scripts.mamatalkViewFromNewsScene", options)
            elseif (rowData.thread_type == __MEALMENU_THREAD_TYPE__) then        
                storyboard.isAction = true
                storyboard.purgeScene("scripts.mealMenuListScene")
                storyboard.gotoScene("scripts.mealMenuListScene", options)
            elseif (rowData.thread_type == __KIDS_ATTENDANCE_TYPE__) then        
                storyboard.isAction = true
                storyboard.purgeScene("scripts.calendarScene")
                storyboard.gotoScene("scripts.calendarScene", options)
            end
        end
    end
    
    return true
end

local function scrollListener( event )
    if (reloadInProgress == true) then
        return true
    end
	
    if ( event.phase == "began" ) then
        needToReload = false
        needToPastload = false
        
        springStart = newsTable:getContentPosition( )
        print("springStart", springStart)
    elseif ( event.phase == "moved") then 
        if(newsTable:getContentPosition( ) > springStart + REFRESH_ROW_HEIGHT) then
            needToReload = true
            transition.to( pullDown, { time=100, rotation=180 } )
        end    
        
        if (newsTable:getContentPosition( ) < springStart - (REFRESH_ROW_HEIGHT * 0.5)) then
            needToPastload = true
        end
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "down" and needToReload == true) then
        reloadInProgress = true  --turn this off at the end of the reload function
        needToReload = false
	if(pullDown) then
            pullDown.alpha = 0
        end
	reloadspinner.alpha = 1
        
        reloadspinner:start()              
        
        reloadTable() 
   end    
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "slideRight", 300)
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
    
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    springStart = 0
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["newsScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }

    local tabButton_width = __appContentWidth__/5 - 2--math.floor(display.actualContentWidth/5) - 2
    local tabButton_height = tabButton_width * 0.7--math.floor(tabButton_width * 0.7)
    
    local tabButtonImages = func.getTabButtonImage()
    local tabButtons = {
        {
            label = language["tab_button"]["tab_button_1"],
            defaultFile = "images/bottom/btn_bottom_home_normal.png",
            overFile = "images/bottom/btn_bottom_home_selected.png",
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
--            size = 16,
            width = tabButton_width,
            height = tabButton_height,
            onPress = function() storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "crossFade", 300) end,
        },
        {
            label = language["tab_button"]["tab_button_2"],
            defaultFile = tabButtonImages.message.defaultFile,
            overFile = tabButtonImages.message.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.messageScene")
                            storyboard.gotoScene("scripts.messageScene", "crossFade", 300) 
                        end,
        },
        {
            label = language["tab_button"]["tab_button_3"],
            defaultFile = tabButtonImages.notice.defaultFile,
            overFile = tabButtonImages.notice.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress = function() 
                        storyboard.isAction = true
                        storyboard.purgeScene("scripts.noticeScene")
                        storyboard.gotoScene("scripts.noticeScene", "crossFade", 300) 
                    end,
        },
        {
            label = language["tab_button"]["tab_button_4"],
            defaultFile = tabButtonImages.event.defaultFile,
            overFile = tabButtonImages.event.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.eventScene")
                            storyboard.gotoScene("scripts.eventScene", "crossFade", 300) 
                        end,
        },
        {
            label = language["tab_button"]["tab_button_5"],
            defaultFile = "images/bottom/btn_bottom_schedule_normal.png",
            overFile = "images/bottom/btn_bottom_schedule_selected.png",
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress = function() 
                        storyboard.isAction = true
                        storyboard.purgeScene("scripts.calendarScene")
                        storyboard.gotoScene("scripts.calendarScene", "crossFade", 300) 
                    end,
        },
    }
    
    local tabBarBackgroundFile = "images/bottom/tabBarBg7.png"
    local tabBarLeft = "images/bottom/tabBar_tabSelectedLeft7.png"
    local tabBarMiddle = "images/bottom/tabBar_tabSelectedMiddle7.png"
    local tabBarRight = "images/bottom/tabBar_tabSelectedRight7.png"
    
    local tabBar = widget.newTabBar{
        top =  display.contentHeight - tabButton_height,
        left = 0,
        width = __appContentWidth__,
        backgroundFile = tabBarBackgroundFile,
        tabSelectedLeftFile = tabBarLeft, 
        tabSelectedRightFile = tabBarRight,
        tabSelectedMiddleFile = tabBarMiddle,
        tabSelectedFrameWidth = 0,           
        tabSelectedFrameHeight = 0,--tabButton_height, 
        buttons = tabButtons,
        height = tabButton_height,
    }
    tabBar.x = display.contentWidth / 2
    group:insert(tabBar)
    tabBar:setSelected(0, false)
    
    newsTable= widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT - REFRESH_ROW_HEIGHT,
	height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - tabButton_height - NAME_BAR_HEIGHT - __statusBarHeight__ ,
        width = __appContentWidth__,
	maxVelocity = 1, 
        backgroundColor = { 0.9, 0.9, 0.9, 0},
	noLines = true,
        hideBackground = true,    
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
	listener = scrollListener
    }
    newsTable.x = display.contentCenterX
    group:insert(newsTable)   
    
    local navBar = widget.newNavigationBar({
            title = language["newsScene"]["title"],
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
    
    local nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
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
    
    if utils.IS_Demo_mode(storyboard, false) == true then
        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
        api.get_news_list(user.userData.id, __DEMO_MODE_DEVICE_ID__, getDataCallback)
    else
        local deviceData = user.getDeviceData()
        if(deviceData and deviceData.id) then 
            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
            api.get_news_list(user.userData.id, deviceData.id, getDataCallback)
        else
            newsTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                rowHeight = REFRESH_ROW_HEIGHT,
                rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0}},
            }--헤더로
            newsTable:insertRow{
                 rowHeight = NODATA_ROW_HEIGHT,
                 rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                 lineColor = { 0.5, 0.5, 0.5 },
                 params = {
                    news_data = nil
                }
            }
        end
    end
        
--    api.get_news_list(190, "1", getDataCallback) --테스트 코드(시뮬레이터용)
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
    
    api.cancelRequest()
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



