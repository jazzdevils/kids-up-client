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

local ROW_HEIGHT = 120
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
local noticeTable
local params
local pageno  --페이징 번호
local pagesize = 10 --리스트 갯수
local springStart

local firstNoticeID
local activityIndicator
local loadingApi
local tablespinnerImageSheet = graphics.newImageSheet( "images/etc/tablespinner.png", tablespinner:getSheet() )
local isLastData = false

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.notice_data
    local existImage = row.params.existImage
    
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
        row.imgCnt = 0
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 6, 6)
        row.rect.anchorX= 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) /2
        row.rect.y = 5
        row:insert(row.rect)

        local str = rowData.title
        local sTitle
        if(rowData.class.id ~= "") then
            if(rowData.type == "1") then
                --전체공지
                sTitle =  "[ "..language["noticeScene"]["all_class"].." ]".."  "..str
            elseif(rowData.type == "2") then
                --개별공지
                sTitle =  "[ "..rowData.class.name .." ".. language["noticeScene"]["title"].." ]".."  "..str
            end
        else
            --원장이 보낸글
            sTitle =  "[ "..language["noticeScene"]["all_class"].." ]".."  "..str
        end
        
        if(utils.UFT8Len(sTitle) > __TITLE_LIMIT_LENGTH__) then
            sTitle = utils.UTF8Sub(sTitle, 1, __TITLE_LIMIT_LENGTH__) .. "..."
        end
        row.title = display.newText(sTitle, 12, 0, native.systemFontBold, 12 )
        row.title.anchorX = 0
        row.title.anchorY = 0
        row.title:setFillColor( 0 )
        row.title.x = row.rect.x + LEFT_PADDING
        row.title.y = 10

--          Contents  
        local sContents 
        if(rowData.status == __AVAILABLE_STATUS__) then
            sContents = rowData.contents
        else
            sContents = language["noticeScene"]["deleted_contents"]
        end
        
        
        if(utils.UFT8Len(sContents) > __CONTENTS_LIMIT_LENGTH__) then
            sContents = utils.UTF8Sub(sContents, 1, __CONTENTS_LIMIT_LENGTH__) .. "..."
        end 
        local contents_options = {
            --parent = textGroup,
            text = sContents,     
            height = 45,
            width = __appContentWidth__ - 50,     --required for multi-line and alignment
            font = native.systemFontBold,   
            fontSize = __LIST_SCENE_TEXT_SIZE__,
            align = "left"  --new alignment parameter
        }
        row.contents = display.newText(contents_options)
        row.contents.anchorX = 0
        row.contents.anchorY = 0
        row.contents:setFillColor( 0 )
        row.contents.y = row.title.y + row.title.height + 5
        row.contents.x = row.title.x

        local stampDate = utils.getTimeStamp(rowData.createtime)
        row.createtime = display.newText(stampDate, 12, 0, native.systemFont, 10)
--            row.createtime = display.newText( rowData.createtime, 12, 0, native.systemFont, 10)
        row.createtime.anchorX = 0
        row.createtime:setFillColor( 0.375, 0.375, 0.375 )
        row.createtime.y = row.height - 35
        row.createtime.x = row.title.x

        row.goodImg = display.newImageRect("images/assets1/btn_like.png", 40 , 15) 
        row.goodImg.anchorX = 0
--            row.goodImg.anchorY = 0
        row.goodImg.x = row.title.x
        row.goodImg.y = row.createtime.y + row.createtime.height + 5
        row:insert(row.goodImg)

--            local goodCount_txt = "いいね "..rowData.goodcnt.."個"
        local goodCount_txt = rowData.goodcnt
        row.goodCount = display.newText(goodCount_txt, 12, 0, native.systemFont, 9)
        row.goodCount.anchorX = 0
        row.goodCount:setFillColor( 1, 1, 1 )
        row.goodCount.y = row.goodImg.y
        row.goodCount.x = row.goodImg.x + 18
        row:insert(row.goodCount)

        row.commentImg = display.newImageRect("images/assets1/btn_comment.png", 40 , 15) 
        row.commentImg.anchorX = 0
--            row.commentImg.anchorY = 0
        row.commentImg.x = row.goodImg.x + row.goodImg.width + 10
        row.commentImg.y = row.goodImg.y
        row:insert(row.commentImg)

--            local commentCount_txt = "コメント "..rowData.reply_cnt.."個"            
        local commentCount_txt = rowData.reply_cnt
        row.commentCount = display.newText(commentCount_txt, 12, 0, native.systemFont, 9)
        row.commentCount.anchorX = 0
        row.commentCount:setFillColor( 1 ,1 ,1 )
        row.commentCount.y = row.goodCount.y
        row.commentCount.x = row.commentImg.x + 18
        row:insert(row.commentCount)

        if(rowData.schedule_added_yn ~= "0") then
            row.inScheduleImg = display.newImageRect("images/assets1/btn_calendar.png", 20 , 15) 
            row.inScheduleImg.anchorX = 0
            row.inScheduleImg.x = row.commentImg.x + row.commentImg.width + 10
            row.inScheduleImg.y = row.commentImg.y
            row:insert(row.inScheduleImg)
        end    

        if(authority.validAuthorityByUser(__VIEW_COMFIRMED_COUNT__) == true) then
            local readCount_txt = rowData.target.read_cnt.."/"..rowData.target.total_cnt
            row.readCount = display.newText(readCount_txt, 12, 0, native.systemFont, 9)
            row.readCount.anchorX = 0
            row.readCount:setFillColor( 0.375, 0.375, 0.375 )
            row.readCount.y = row.goodCount.y
            if(row.inScheduleImg) then
                row.readCount.x = row.inScheduleImg.x + row.inScheduleImg.width + 10
            else
                row.readCount.x = row.commentImg.x + row.commentImg.width + 10
            end

            row:insert(row.readCount)
        end    

        if(rowData.status == __AVAILABLE_STATUS__) then --유효한 내용인가?
            if(user.userData.jobType == __PARENT__) then
                if(rowData.readyn == "0") then --안 읽었으면
--                        row.readMsgImg = display.newImageRect("images/assets1/icon_mail_close.png", 20, 24)
                    row.rect:setFillColor(unpack(__UnRead_NoticeList_RowColor__))
                    row.title:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                    row.contents:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                    row.createtime:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                elseif(rowData.readyn == "1") then    --읽었으면 1
--                        row.readMsgImg = display.newImageRect("images/assets1/icon_mail_open.png", 20, 24)
                    row.title:setFillColor(unpack(__Read_NoticeList_FontColor__))
                    row.contents:setFillColor(unpack(__Read_NoticeList_FontColor__ ))
                    row.createtime:setFillColor(unpack(__Read_NoticeList_FontColor__))
                end
            else
--                    row.readMsgImg = display.newImageRect("images/assets1/icon_mail_open.png", 20, 24)
                row.title:setFillColor(unpack(__Read_NoticeList_FontColor__))
                row.contents:setFillColor(unpack(__Read_NoticeList_FontColor__ ))
                row.createtime:setFillColor(unpack(__Read_NoticeList_FontColor__))
            end
        else --삭제된 내용인가?
--                row.readMsgImg = display.newImageRect("images/assets1/icon_mail_close.png", 20, 24)
            row.rect:setFillColor(0.7, 0.7, 0.7)
            row.title:setFillColor(0.8, 0.8, 0.8)
            row.contents:setFillColor(1, 1, 1)
            row.createtime:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
        end

--            row.readMsgImg.anchorX = 0
--            row.readMsgImg.anchorY = 0
--            row.readMsgImg.x = row.rect.width - row.readMsgImg.width
--            row.readMsgImg.y = 8
        if(existImage == true)then
            row.imgIcon = display.newImageRect("images/assets1/icon_photo.png", 20 , 20)
            row.imgIcon.anchorX = 0
            row.imgIcon.anchorY = 0
            row.imgIcon.x = row.rect.width - row.imgIcon.width
            row.imgIcon.y = row.rect.y + 5
            row:insert(row.imgIcon)
        end

        row.rightArrow = display.newImageRect("images/assets1/icon_detail.png", 20 , 20)
        row.rightArrow.anchorX = 0
        row.rightArrow.anchorY = 0
        row.rightArrow.x = row.rect.width - row.rightArrow.width
        row.rightArrow.y = row.rect.height - row.rightArrow.height

        row:insert(row.title )
        row:insert(row.contents)
        row:insert(row.createtime)
        row:insert(row.rightArrow)
--            row:insert(row.readMsgImg)
    else
        --Row 데이타가 없음..따라서 데이타 없다고 표시
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row:insert(row.rect )

        row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
        row.noDataimg.anchorY = 0
        row.noDataimg.x = display.contentCenterX
        row.noDataimg.y = 20
        row:insert(row.noDataimg)

        row.noData_txt = display.newText(language["noticeScene"]["no_data"], 12, 0, native.systemFont, 12)
        row.noData_txt.anchorY = 0
        row.noData_txt:setFillColor( 0 ,0 ,0 )
        row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
        row.noData_txt.x = display.contentCenterX
        row:insert(row.noData_txt)
    end
end
        
local function existImage(list)
    if(list.img1 and list.img1.url and list.img1.url ~= "") then
        return true
    end
    if(list.img2 and list.img2.url and list.img2.url ~= "") then
        return true
    end
    if(list.img3 and list.img3.url and list.img3.url ~= "") then
        return true
    end
    if(list.img4 and list.img4.url and list.img4.url ~= "") then
        return true
    end
    if(list.img5 and list.img5.url and list.img5.url ~= "") then
        return true
    end
    if(list.img6 and list.img6.url and list.img6.url ~= "") then
        return true
    end
    if(list.img7 and list.img7.url and list.img7.url ~= "") then
        return true
    end
    if(list.img8 and list.img8.url and list.img8.url ~= "") then
        return true
    end
    if(list.img9 and list.img9.url and list.img9.url ~= "") then
        return true
    end
    if(list.img10 and list.img10.url and list.img10.url ~= "") then
        return true
    end
    
    return false
end                

local function getDataCallback(event)
    local function makeRow(json_data)
        if(noticeTable) then
            local cnt = json_data.notice_cnt
            if (firstNoticeID) then
--              과거 데이타 추가  
                if (cnt > 0) then
                    if(tonumber(firstNoticeID) == tonumber(json_data.notice[1].id)) then
                        --새로운 내용이 없음
                        return true 
                    elseif(tonumber(firstNoticeID) > tonumber(json_data.notice[1].id)) then
                        --과거 데이터 가져옴
                        if (cnt < pagesize ) then
                            isLastData = true
                        end
                        
                        for i = 1, cnt do
                            local existImage = existImage(json_data.notice[i])
                            noticeTable:insertRow{
                                rowHeight = ROW_HEIGHT,
                                rowColor = {  default = { 1, 1, 1,0 }, over = { 1, 1, 1, 0}},
                                lineColor = { 0.5, 0.5, 0.5 },
                                params = {
                                    notice_data = json_data.notice[i],
                                    existImage = existImage
                                }
                            }
                        end
                        return true
                    end
                else
                    isLastData = true
                end
            else
--              새로고침 또는 처음 로딩
                if(cnt > 0) then
                    firstNoticeID = json_data.notice[1].id

                    noticeTable:deleteAllRows()

                    noticeTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 }},
                    }
                    for i = 1, cnt do
                        local existImage = existImage(json_data.notice[i])
                        noticeTable:insertRow{
                            rowHeight = ROW_HEIGHT,
                            rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                            lineColor = { 0.5, 0.5, 0.5 },
                            params = {
                                notice_data = json_data.notice[i],
                                existImage = existImage
                            }
                        }		
                    end
                else
                    noticeTable:deleteAllRows()
                    
                    noticeTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0}},
                    }--헤더로
                    noticeTable:insertRow{
                         rowHeight = NODATA_ROW_HEIGHT,
                         rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                         lineColor = { 0.5, 0.5, 0.5 },
                         params = {
                            notice_data = nil
                        }
                    }--아직 공지가 없다는 내용을 표시하기위한 로row
                end
            end
        end
        
        return true
    end
    
    loadingApi = false
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
    noticeTable:scrollToIndex(1, 10, nil)
    local reloadCompleteTimer = timer.performWithDelay( 3000, reloadcomplete, 1 )      	 
end

local function onRowTouch( event )
    if event.phase == "release" then
        local id = event.row.index
        local rowData = event.target.params.notice_data
        if(rowData and rowData.status ~= __AVAILABLE_STATUS__) then --삭제된 내용인가?
            return true
        end
        
        if(id ~= 1 and rowData) then
            storyboard.purgeScene("scripts.noticeViewScene")
            
            local options = {
                effect = "slideLeft",
                time = 300,
            }
            sceneData.addSceneData("scripts.noticeScene", "scripts.noticeViewScene", rowData)
            storyboard.isAction = true
            storyboard.gotoScene("scripts.noticeViewScene", options)
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
        
        springStart = noticeTable:getContentPosition( )
        print("springStart", springStart)
    elseif ( event.phase == "moved") then
        if (noticeTable:getContentPosition( ) > springStart + REFRESH_ROW_HEIGHT) then
            needToReload = true
            transition.to( pullDown, { time=100, rotation=180 } )
        end 
        
        if (noticeTable:getContentPosition( ) < springStart - (REFRESH_ROW_HEIGHT * 0.5)) then
            needToPastload = true
        end
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "down" and needToReload == true and loadingApi == false) then
        reloadInProgress = true  --turn this off at the end of the reload function
        needToReload = false
        if(pullDown) then
            pullDown.alpha = 0
        end    
	reloadspinner.alpha = 1
        reloadspinner:start()              
        
        loadingApi = true
        firstNoticeID = nil
        pageno = 1
        isLastData = false
        print("calling api")
        if(user.userData.jobType == __DIRECTOR__ or user.userData.jobType == __TEACHER__) then
            --원장, 선생의 경우 모든공지
            api.notice_get_api(user.userData.centerid, "", user.userData.id, pageno, pagesize, getDataCallback)
        else
            --학부모의 경우 해당 클래스, 전체공지
            api.notice_get_api(user.userData.centerid, user.userData.classId, user.userData.id, pageno, pagesize, getDataCallback)
        end    
        reloadTable() 
        
        print("needToReload")
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "up" and needToPastload == true and loadingApi == false) then    
        if(isLastData == false) then
            needToPastload = false

            print("calling api")
            loadingApi = true
            pageno = pageno + 1
            if(user.userData.jobType == __DIRECTOR__ or user.userData.jobType == __TEACHER__) then
                --원장, 선생의 경우 모든공지
                api.notice_get_api(user.userData.centerid, "", user.userData.id, pageno, pagesize, getDataCallback)
            else
                --학부모의 경우 해당 클래스, 전체공지
                api.notice_get_api(user.userData.centerid, user.userData.classId, user.userData.id, pageno, pagesize, getDataCallback)
            end    
            print("needToPastload PageNo : "..pageno)
        end
   end    
   
   return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "slideRight", 300)
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        storyboard.isAction = true
        storyboard.purgeScene("scripts.noticeWriteScene")
        storyboard.gotoScene("scripts.noticeWriteScene" , "slideLeft", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    springStart = 0
    firstNoticeID = nil
    pageno = 1
    
    func.clear_news(user.userData.id, "notice")
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["noticeScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }

    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["noticeScene"]["write"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
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
            onPress = nil,
            selected = true,
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
            onPress =   function() 
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
    
    noticeTable = widget.newTableView{
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
    noticeTable.x = display.contentCenterX
    group:insert(noticeTable)   
    
    local navBar
    if(authority.validAuthorityByUser(__NOTICE_WRITE__) == true) then
        navBar = widget.newNavigationBar({
            title = language["noticeScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
            rightButton = btn_right_opt,
    --        includeStatusBar = true
        })
    else
        navBar = widget.newNavigationBar({
            title = language["noticeScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
        })
    end    
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
    
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    loadingApi = true
    if(user.userData.jobType == __DIRECTOR__ or user.userData.jobType == __TEACHER__) then
        api.notice_get_api(user.userData.centerid, "", user.userData.id, pageno, pagesize, getDataCallback)
    else
        api.notice_get_api(user.userData.centerid, user.userData.classId, user.userData.id, pageno, pagesize, getDataCallback)
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
    storyboard.returnTo = __DEFAULT_HOMESCENE_NAME__
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
--    firstNoticeID = nil
--    pageno = 1
    loadingApi = false
    
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

