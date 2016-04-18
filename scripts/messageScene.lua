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
local CALENDAR_BOX_HEIGHT = 40

local springStart
local needToReload = false
local needToPastload = false
local pullDown = nil
local reloadspinner
local reloadInProgress = false
local msgTable
local pageno  --페이징 번호
local pagesize = 10 --리스트 갯수
local springStart

local firstMsgID--새로운 데이타기 있는지 확인용
local activityIndicator
local isLastData = false
local loadingApi
local setYear
local setMonth
local thisYear
local thisMonth
local tabBar
local tablespinnerImageSheet = graphics.newImageSheet( "images/etc/tablespinner.png", tablespinner:getSheet() )	
local rowsHeight

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
-- @return

--local function controlTabBar(old_y, new_y)
--    if(tabBar and rowsHeight > __appContentHeight__) then
--        if( math.abs(old_y) < math.abs(new_y) ) then
--            if(math.abs(new_y) - math.abs(old_y) > 50 ) then
--                transition.to( tabBar, { time=200, alpha=0, onComplete=nil })
--            end
--        elseif(math.abs(new_y) < math.abs(old_y) ) then
--            if(math.abs(old_y) - math.abs(new_y) > 50 ) then
--                transition.to( tabBar, { time=200, alpha=1, onComplete=nil })
--            end
--        end
--    end
--end

local function isPastTime()
    local now = os.date("*t")
    local dtNow = os.time( { year = now.year, month = now.month, day = 1, } )
    local dtThen = os.time( { year = setYear, month = setMonth, day = 1, })

    local differDay = os.difftime(dtNow, dtThen)
    if(differDay == 0 or differDay < 0) then
        return false -- 현재, 미래
    else
        return true --과거
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
        if(msgTable) then
            local cnt = json_data.contact_cnt
            if (firstMsgID) then
--              과거 데이타 추가  
                if (cnt > 0) then
                    if(tonumber(firstMsgID) == tonumber(json_data.contact[1].id)) then
                        --새로운 내용이 없음
                        return true 
                    elseif(tonumber(firstMsgID) > tonumber(json_data.contact[1].id)) then
                        --과거 데이터 가져옴
                        if (cnt < pagesize ) then
                            isLastData = true
                        end
                        
                        for i = 1, cnt do
                            local existImage = existImage(json_data.contact[i])
                            msgTable:insertRow{
                                rowHeight = ROW_HEIGHT,
                                rowColor = {  default = { 1, 1, 1,0 }, over = { 1, 1, 1, 0}},
                                lineColor = { 0.5, 0.5, 0.5 },
                                params = {
                                    contact_data = json_data.contact[i],
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
                    firstMsgID = json_data.contact[1].id
--
                    msgTable:deleteAllRows()
                    rowsHeight = 0

                    msgTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 }},
                    }
                    msgTable:insertRow{ --category
                        rowHeight = CALENDAR_BOX_HEIGHT,
                        rowColor = { default = __SELECT_CLASS_RECT_COLOR__, },
--                        lineColor = { 1, 0, 0 },
                        isCategory = true,
                        params = {
                            row_Data = nil,
                        }
                    }
                    for i = 1, cnt do
                        local existImage = existImage(json_data.contact[i])
                        msgTable:insertRow{
                            rowHeight = ROW_HEIGHT,
                            rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                            lineColor = { 0.5, 0.5, 0.5 },
                            params = {
                                contact_data = json_data.contact[i],
                                existImage = existImage
                            }
                        }		
                    end
                else
                    msgTable:deleteAllRows()
                    rowsHeight = 0
                    tabBar.alpha = 1

                    msgTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0}},
                    }--헤더로
                    msgTable:insertRow{ --category
                        rowHeight = CALENDAR_BOX_HEIGHT,
                        rowColor = { default = __SELECT_CLASS_RECT_COLOR__, },
                        lineColor = { 1, 0, 0 },
                        isCategory = true,
                        params = {
                            row_Data = nil,
                        }
                    }
                    msgTable:insertRow{
                         rowHeight = NODATA_ROW_HEIGHT,
                         rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                         lineColor = { 0.5, 0.5, 0.5 },
                         params = {
                            contact_data = nil
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
    
    if ( event.isError ) then
        utils.showMessage(language["common"]["wrong_connection"])
    else
        print("messageScene : "..event.phase)
        if(event.status == 200) then
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

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.contact_data
    local existImage = row.params.existImage
    
    rowsHeight = rowsHeight + row.height
    
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
    
    if(index == 2) then
--        Date Category
        row.leftArrowButton = display.newImageRect("images/assets1/icon_calendar_prev.png", 24 , 24)
        row.leftArrowButton.anchorX = 0
        row.leftArrowButton.anchorY = 0
        row.leftArrowButton.x = 10
        row.leftArrowButton.y = (row.height - row.leftArrowButton.height)*0.5
        row:insert(row.leftArrowButton)
        row.leftArrowButton:addEventListener("touch", 
            function(event)
                if event.phase == "ended" then
                    firstMsgID = nil
                    isLastData = false
                    pageno = 1

                    setMonth = setMonth - 1
                    if setMonth < 1 then
                        setMonth = 12
                        setYear = setYear - 1
                    end

                    local sDateYYYYMM = string.format("%04d", setYear)..string.format("%02d", setMonth)
                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                    loadingApi = true
                    api.get_contact_list2(user.userData.centerid, sDateYYYYMM, user.userData.id, user.getActiveKid_IDByAuthority(), pageno, pagesize, getDataCallback)
                end
                return true    
            end
        )
        
        row.yearMonthName = display.newText(utils.convert2LocaleDateStringYYYYMM(setYear, setMonth), 0, 0, 0, 0, native.systemFont, 20 )
        row.yearMonthName:setFillColor(unpack(__Read_NoticeList_FontColor__))
        row.yearMonthName.anchorY = 0
        row.yearMonthName.x = display.contentCenterX
        row.yearMonthName.y = (row.height - row.yearMonthName.height)*0.5
        row:insert( row.yearMonthName )
        
        if(isPastTime() == true) then
            row.rightArrowButton = display.newImageRect("images/assets1/icon_calendar_next.png", 24 , 24)
            row.rightArrowButton.anchorX = 0
            row.rightArrowButton.anchorY = 0
            row.rightArrowButton.x = row.width - row.rightArrowButton.width - 10
            row.rightArrowButton.y = row.leftArrowButton.y
            row:insert(row.rightArrowButton)
            row.rightArrowButton:addEventListener("touch", 
                function(event) 
                    if event.phase == "ended" then
                        firstMsgID = nil
                        isLastData = false
                        pageno = 1

                        setMonth = setMonth + 1
                        if setMonth > 12 then
                            setMonth = 1
                            setYear = setYear + 1
                        end

                        local sDateYYYYMM = string.format("%04d", setYear)..string.format("%02d", setMonth)
                        loadingApi = true
                        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                        api.get_contact_list2(user.userData.centerid, sDateYYYYMM, user.userData.id, user.getActiveKid_IDByAuthority(), pageno, pagesize, getDataCallback)
                    end 
                    return true    
                end
            )
        end
        
        return true
    end
    
    if(rowData and index > 2) then
        row.imgCnt = 0

        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 6, 6)
        row.rect.anchorX= 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) /2
        row.rect.y = 5
        row:insert(row.rect)
        
        if(user.userData.jobType == __PARENT__) then
            if(rowData.type == __MESSAGE_FROM_CENTER__) then
                row.typeImg = display.newImageRect("images/assets1/icon_private.png", 15 , 15) 
                row.typeImg.anchorX = 0
                row.typeImg.anchorY = 0
                row.typeImg.x = row.rect.x + LEFT_PADDING
                row.typeImg.y = row.rect.y + LEFT_PADDING
                row:insert(row.typeImg)
                
                row.typeDesc = display.newText(language["messageScene"]["from_school"], 12, 0, native.systemFontBold, 12)
                row.typeDesc.anchorX = 0
                row.typeDesc.anchorY = 0
                row.typeDesc:setFillColor( 0, 0, 0 )
                row.typeDesc.x = row.typeImg.x + row.typeImg.width + 10
                row.typeDesc.y = row.typeImg.y
                row:insert(row.typeDesc)
            else
                row.typeDesc = display.newText(language["messageScene"]["from_home"], 12, 0, native.systemFontBold, 12)
                row.typeDesc.anchorX = 0
                row.typeDesc.anchorY = 0
                row.typeDesc:setFillColor( 0, 0, 0 )
                row.typeDesc.x = row.rect.x + LEFT_PADDING
                row.typeDesc.y = row.rect.y + LEFT_PADDING
                row:insert(row.typeDesc)
            end
        else
            if(rowData.type == __MESSAGE_FROM_HOME__) then
                row.typeImg = display.newImageRect("images/assets1/icon_private.png", 15 , 15) 
                row.typeImg.anchorX = 0
                row.typeImg.anchorY = 0
                row.typeImg.x = row.rect.x + LEFT_PADDING
                row.typeImg.y = row.rect.y + LEFT_PADDING
                row:insert(row.typeImg)
                
                row.typeDesc = display.newText(language["messageScene"]["from_home"], 12, 0, native.systemFontBold, 12)
                row.typeDesc.anchorX = 0
                row.typeDesc.anchorY = 0
                row.typeDesc:setFillColor( 0, 0, 0 )
                row.typeDesc.x = row.typeImg.x + row.typeImg.width + 10
                row.typeDesc.y = row.typeImg.y
                row:insert(row.typeDesc)
                
                row.writer = display.newText("[ " .. rowData.writer.name .. " ]", 12, 0, native.systemFont, 12)
                row.writer.anchorX = 0
                row.writer.anchorY = 0
                row.writer:setFillColor( 0, 0, 0 )
                row.writer.x = row.typeDesc.x + row.typeDesc.width + 5
                row.writer.y = row.typeDesc.y
                row:insert(row.writer)
                
                row.classname = display.newText( rowData.class.name , 12, 0, native.systemFont, 12)
                row.classname.anchorX = 0
                row.classname.anchorY = 0
                row.classname:setFillColor( unpack(__Read_NoticeList_FontColor__) )
                row.classname.x = row.writer.x + row.writer.width + 5
                row.classname.y = row.writer.y
                row:insert(row.classname)
            else
                row.typeDesc = display.newText(language["messageScene"]["from_school"], 12, 0, native.systemFontBold, 12)
                row.typeDesc.anchorX = 0
                row.typeDesc.anchorY = 0
                row.typeDesc:setFillColor( 0, 0, 0 )
                row.typeDesc.x = row.rect.x + LEFT_PADDING
                row.typeDesc.y = row.rect.y + LEFT_PADDING
                row:insert(row.typeDesc)
            end
        end
        
--          Contents  
        local sContents 
        if(rowData.status == __AVAILABLE_STATUS__) then
            sContents = rowData.contents
        else
            sContents = language["messageScene"]["deleted_contents"]
        end
        
        if(utils.UFT8Len(sContents) > __CONTENTS_LIMIT_LENGTH__) then
            sContents = utils.UTF8Sub(rowData.contents, 1, __CONTENTS_LIMIT_LENGTH__) .. "..."
        end 
        local contents_options = {
            --parent = textGroup,
            text = sContents,     
            height = 45,
            width = row.rect.width - 50,     --required for multi-line and alignment
            font = native.systemFontBold,   
            fontSize = __LIST_SCENE_TEXT_SIZE__,
            align = "left"  --new alignment parameter
        }
        row.contents = display.newText(contents_options )
        row.contents.anchorX = 0
        row.contents.anchorY = 0
        row.contents:setFillColor( 0 )
        row.contents.x = row.rect.x + LEFT_PADDING
        row.contents.y = row.typeDesc.y + row.typeDesc.height + LEFT_PADDING
        
        local stampDate = utils.getTimeStamp(rowData.createtime)
        row.createtime = display.newText(stampDate, 12, 0, native.systemFont, __LIST_SCENE_TEXT_SIZE__)
        row.createtime.anchorX = 0
        row.createtime:setFillColor( 0.375, 0.375, 0.375 )
        row.createtime.y = row.height - 35
        row.createtime.x = row.contents.x

        row.commentImg = display.newImageRect("images/assets1/btn_comment.png", 40 , 15) 
        row.commentImg.anchorX = 0
        row.commentImg.anchorY = 0
        row.commentImg.x = row.contents.x
        row.commentImg.y = row.rect.y + row.rect.height - row.commentImg.height - LEFT_PADDING --row.createtime.y + row.createtime.height + LEFT_PADDING
        row:insert(row.commentImg)

--            local commentCount_txt = "コメント "..rowData.reply_cnt.."個"            
        local commentCount_txt = rowData.reply_cnt
        row.commentCount = display.newText(commentCount_txt, 12, 0, native.systemFont, 9)
        row.commentCount.anchorX = 0
--        row.commentCount.anchorY = 0
        row.commentCount:setFillColor( 1 ,1 ,1 )
        row.commentCount.x = row.commentImg.x + row.commentImg.width * 0.5
        row.commentCount.y = row.commentImg.y + row.commentImg.height * 0.5
        row:insert(row.commentCount)
        
        if (rowData.target.read_cnt and rowData.target.read_cnt ~= "") then
            local read_cnt = tonumber(rowData.target.read_cnt)
            local total_cnt = tonumber(rowData.target.total_cnt)
            
            if(user.userData.jobType == __PARENT__) then  -- 학부모가 보낸것을 교사가 확인했는지에대한 검사
                if(rowData.type == __MESSAGE_FROM_HOME__ and read_cnt > 0) then 
                    row.confiremd_desc = display.newText(language["messageScene"]["confirmed_teacher"], 12, 0, native.systemFont, __LIST_SCENE_TEXT_SIZE__)
                    row.confiremd_desc.anchorX = 0
                    row.confiremd_desc.anchorY = 0
                    row.confiremd_desc:setFillColor( 0.375, 0.375, 0.375 )
                    row.confiremd_desc.y = row.commentImg.y + (row.commentImg.height - row.confiremd_desc.height) * 0.5
                    row.confiremd_desc.x = row.commentImg.x + row.commentImg.width + LEFT_PADDING
                    row:insert(row.confiremd_desc)
                end
            else -- 교사가 보낸것을 학부모가 확인했는지에대한 검사
                if(rowData.type == __MESSAGE_FROM_CENTER__ ) then
                    if (read_cnt == total_cnt) then
                        row.confiremd_desc = display.newText(language["messageScene"]["confirmed_parent"], 12, 0, native.systemFont, __LIST_SCENE_TEXT_SIZE__)
                    else
                        row.confiremd_desc = display.newText(read_cnt.."/"..total_cnt, 12, 0, native.systemFont, __LIST_SCENE_TEXT_SIZE__)
                    end
                    row.confiremd_desc.anchorX = 0
                    row.confiremd_desc.anchorY = 0
                    row.confiremd_desc:setFillColor( 0.375, 0.375, 0.375 )
                    row.confiremd_desc.y = row.commentImg.y + (row.commentImg.height - row.confiremd_desc.height) * 0.5
                    row.confiremd_desc.x = row.commentImg.x + row.commentImg.width + LEFT_PADDING
                    row:insert(row.confiremd_desc)
                end
            end
        end
        
        if(rowData.status == __AVAILABLE_STATUS__) then
            row.contents:setFillColor(unpack(__Read_NoticeList_FontColor__ )) --default
            row.createtime:setFillColor(unpack(__Read_NoticeList_FontColor__))
            
            if(user.userData.jobType == __PARENT__) then
                if(rowData.type == __MESSAGE_FROM_CENTER__ and rowData.readyn == "0") then 
                    --학부모의 경우 원에서 온 내용이고 안 읽었으면
                    row.rect:setFillColor(unpack(__UnRead_NoticeList_RowColor__))
                    row.contents:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                    row.createtime:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                end 
            else
                -- 선생의 경우 가정에서 온 내용이고 안 읽었으면
                if(rowData.type == __MESSAGE_FROM_HOME__ and rowData.readyn == "0") then 
                    --학부모의 경우 원에서 온 내용이고 안 읽었으면
                    row.rect:setFillColor(unpack(__UnRead_NoticeList_RowColor__))
                    row.contents:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                    row.createtime:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
                end 
            end
        else
            row.rect:setFillColor(0.7, 0.7, 0.7)
            row.contents:setFillColor(1, 1, 1)
            row.createtime:setFillColor(unpack(__UnRead_NoticeList_FontColor__))
        end
        
        if(existImage == true)then
            --이미지 존재
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

        row:insert(row.contents)
        row:insert(row.createtime)
        row:insert(row.rightArrow)
    else
        --Row 데이타가 없음..따라서 데이타 없다고 표시
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row:insert(row.rect )

        row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
        row.noDataimg.anchorY = 0
        row.noDataimg.x = display.contentCenterX
        row.noDataimg.y = 20--row.rect.height - row.noData.height
        row:insert(row.noDataimg)

        row.noData_txt = display.newText(language["messageScene"]["no_data"], 12, 0, native.systemFont, 12)
        row.noData_txt.anchorY = 0
        row.noData_txt:setFillColor( 0 ,0 ,0 )
        row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
        row.noData_txt.x = display.contentCenterX
        row:insert(row.noData_txt)
    end
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
    msgTable:scrollToIndex(1, 10, nil)
    local reloadCompleteTimer = timer.performWithDelay( 3000, reloadcomplete, 1 )      	 
end

local function onRowTouch( event )
    if event.phase == "release" then
        local id = event.row.index
        local rowData = event.target.params.contact_data
        if(rowData and rowData.status ~= __AVAILABLE_STATUS__) then --삭제된 내용인가?
            return true
        end
        
        if(id ~= 1 and rowData) then
            storyboard.purgeScene("scripts.messageViewScene")
            local options = {
                effect = "slideLeft",
                time = 300,
            }
            sceneData.addSceneData("scripts.messageScene", "scripts.messageViewScene", rowData)
            storyboard.isAction = true
            storyboard.purgeScene("scripts.messageViewScene")
            storyboard.gotoScene("scripts.messageViewScene", options)
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
        
        springStart = msgTable:getContentPosition()
    elseif ( event.phase == "moved") then
        if (thisYear == setYear and thisMonth == setMonth) then
            if(msgTable:getContentPosition()> springStart + REFRESH_ROW_HEIGHT) then
                pullDown.alpha = 1
                needToReload = true
                transition.to( pullDown, { time=100, rotation=180 } )
            end    
        end
        
        if (msgTable:getContentPosition() < springStart - (REFRESH_ROW_HEIGHT * 0.5)) then
            needToPastload = true
        end
        
--        controlTabBar(springStart, msgTable:getContentPosition())
--        print("springStart : "..springStart)
--        print("End : "..msgTable:getContentPosition())
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "down" and needToReload == true and loadingApi == false) then
        if (msgTable:getContentPosition()> springStart + REFRESH_ROW_HEIGHT) then
            if (thisYear == setYear and thisMonth == setMonth) then
                reloadInProgress = true  --turn this off at the end of the reload function
                needToReload = false
                if(pullDown) then
                    pullDown.alpha = 0
                end
                reloadspinner.alpha = 1
                reloadspinner:start()              

                firstMsgID = nil
                pageno = 1
                isLastData = false

                local sDateYYYYMM = string.format("%04d", setYear)..string.format("%02d", setMonth)
--                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                loadingApi = true
                api.get_contact_list2(user.userData.centerid, sDateYYYYMM, user.userData.id, user.getActiveKid_IDByAuthority(), pageno, pagesize, getDataCallback)
                print("calling api")
                reloadTable() 
            end
        end
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "up" and needToPastload == true and loadingApi == false) then    
        if(isLastData == false) then
            needToPastload = false

            pageno = pageno + 1
            print("page : ".. pageno)
            local sDateYYYYMM = string.format("%04d", setYear)..string.format("%02d", setMonth)
--            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
            loadingApi = true
            api.get_contact_list2(user.userData.centerid, sDateYYYYMM, user.userData.id, user.getActiveKid_IDByAuthority(), pageno, pagesize, getDataCallback)    
        end
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
        storyboard.isAction = true
        
        if(user.userData.jobType == __PARENT__) then
            storyboard.purgeScene("scripts.messageByParentWriteScene")
            storyboard.gotoScene("scripts.messageByParentWriteScene" , "slideLeft", 300)
        elseif(user.userData.jobType == __TEACHER__) then
            storyboard.purgeScene("scripts.messageByTeacherWriteScene")
            storyboard.gotoScene("scripts.messageByTeacherWriteScene" , "slideLeft", 300)
        elseif(user.userData.jobType == __DIRECTOR__) then    
            storyboard.purgeScene("scripts.messageByTeacherWriteScene")
            storyboard.gotoScene("scripts.messageByTeacherWriteScene" , "slideLeft", 300)
        end
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    rowsHeight = 0
    springStart = 0
    firstMsgID = nil
    pageno = 1
    
    func.clear_news(user.userData.id, "contact")
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["messageScene"]["back"],
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
        label = language["messageScene"]["write"],
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
            onPress = nil,  
            selected = true,            
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
    
    msgTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT - REFRESH_ROW_HEIGHT,
	height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - tabButton_height - NAME_BAR_HEIGHT - __statusBarHeight__ ,
--        height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - NAME_BAR_HEIGHT - __statusBarHeight__ ,
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
    msgTable.x = display.contentCenterX
    group:insert(msgTable)   
    
    tabBar = widget.newTabBar{
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
    
--    msgTable = widget.newTableView{
--        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT - REFRESH_ROW_HEIGHT,
----	height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - tabButton_height - NAME_BAR_HEIGHT - __statusBarHeight__ ,
--        height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - NAME_BAR_HEIGHT - __statusBarHeight__ ,
--        width = __appContentWidth__,
--	maxVelocity = 1, 
--        backgroundColor = { 0.9, 0.9, 0.9, 0},
--	noLines = true,
--        hideBackground = true,    
--        rowTouchDelay = __tableRowTouchDelay__,
--        isBounceEnabled = true,
--	onRowRender = onRowRender,
--	onRowTouch = onRowTouch,
--	listener = scrollListener
--    }
--    msgTable.x = display.contentCenterX
--    group:insert(msgTable)   
    
    local navBar
    navBar = widget.newNavigationBar({
        title = language["messageScene"]["title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontsize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
--        includeStatusBar = false
    })
--    if(user.userData.jobType == __PARENT__ or user.userData.jobType == __TEACHER__) then
--        navBar = widget.newNavigationBar({
--            title = language["messageScene"]["title"],
--            width = __appContentWidth__,
--            background = "images/top/bg_top.png",
--            titleColor = __NAVBAR_TXT_COLOR__,
--            font = native.systemFontBold,
--            fontsize = __navBarTitleFontSize__,
--            leftButton = btn_left_opt,
--            rightButton = btn_right_opt,
--    --        includeStatusBar = false
--        })
--    else
--        navBar = widget.newNavigationBar({
--            title = language["messageScene"]["title"],
--            width = __appContentWidth__,
--            background = "images/top/bg_top.png",
--            titleColor = __NAVBAR_TXT_COLOR__,
--            font = native.systemFontBold,
--            fontsize = __navBarTitleFontSize__,
--            leftButton = btn_left_opt,
----            rightButton = btn_right_opt,
--    --        includeStatusBar = false
--        })
--    end    
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
    
    local date = os.date( "*t" )
    setYear = date.year 
    setMonth = date.month
    thisYear = date.year
    thisMonth = date.month
    
    local sDateYYYYMM = string.format("%04d", setYear)..string.format("%02d", setMonth)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    loadingApi = true
    api.get_contact_list2(user.userData.centerid, sDateYYYYMM, user.userData.id, user.getActiveKid_IDByAuthority(), pageno, pagesize, getDataCallback)
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
    
--    firstMsgID = nil
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
    
--    firstMsgID = nil
--    pageno = 1
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



