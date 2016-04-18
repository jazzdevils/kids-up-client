---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")
require("widgets.widgetext")

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

local ROW_HEIGHT = 140
local NODATA_ROW_HEIGHT = 280
local REFRESH_ROW_HEIGHT = 50
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local LEFT_PADDING = 5
local SELECT_CLASS_BAR = 30

local springStart
local needToReload = false
local needToPastload = false
local pullDown = nil
local reloadspinner
local reloadInProgress = false
local mamatalkTable
local pageno  --페이징 번호
local pagesize = 10 --리스트 갯수
local springStart

local firstID--새로운 데이타기 있는지 확인용
local activityIndicator
local loadingApi

local selected_class_id
local selectClassName

local pickerList
local imageGroup
local tablespinnerImageSheet = graphics.newImageSheet( "images/etc/tablespinner.png", tablespinner:getSheet() )	
local isLastData = false

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function clearScreen()
    if(pickerList and pickerList.isShowing == true) then
--        pickerList:closeUp()
--        pickerList.isShowing = false
        pickerList:removeSelf()
        pickerList = nil
        
        return true
    end
end

local function alignImage(row, filename, dir, x, y, width, height, contentsImage, id)
    local img
    if (dir) then
        img = display.newImage(row, filename, dir )
    else
        img = display.newImage(row, filename )
    end
    
    img.alpha = 0
    img.anchorX = 0
    img.anchorY = 0
    img.width = width
    img.height = height
    img.x = x
    img.y = y

    transition.to(img, { alpha = 1.0 } )
    imageGroup:insert(img)
    row:insert(img)
end

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.mamatalk_data
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
            
            local writerImgFileName
            if(rowData.writer.img) then
                writerImgFileName = rowData.writer.img:match("([^/]+)$")         
            end

            local imageWidth = 30
            local imageHeight = 30
            if(writerImgFileName) then
                if(utils.fileExist(writerImgFileName, system.TemporaryDirectory) == true) then
                    alignImage(row, writerImgFileName, system.TemporaryDirectory, 
                        row.rect.x + LEFT_PADDING, row.rect.y + 5, imageWidth, imageHeight, false)
                else
                    network.download(
                        rowData.writer.img,
                        "GET",
                        function(event) 
                            if ( event.isError ) then
                                alignImage(row, "images/assets1/pic_photo_30x30.png", nil, 
                                    row.rect.x + LEFT_PADDING, row.rect.y + 5, imageWidth, imageHeight, false
                                )
                            elseif(event.phase == "ended") then    
                                alignImage(row, writerImgFileName, system.TemporaryDirectory, 
                                    row.rect.x + LEFT_PADDING, row.rect.y + 5, imageWidth, imageHeight, false
                                ) 
                            end
                        end ,
                        writerImgFileName,
                        system.TemporaryDirectory
                    )
                end
            end
            
            row.writer = display.newText(rowData.writer.name, 0, 0, native.systemFont, 10)
            row.writer.anchorX = 0
            row.writer.anchorY = 0
            row.writer:setFillColor(0)
            row.writer.x = LEFT_PADDING + row.rect.x + imageWidth + LEFT_PADDING
            row.writer.y = row.rect.y + 5
            row:insert(row.writer)
            
            local stampDate = utils.getTimeStamp(rowData.createtime)
            row.createtime = display.newText(stampDate, 12, 0, native.systemFont, 10)
            row.createtime.anchorX = 0
            row.createtime.anchorY = 0
--            row.createtime:setFillColor( 0.375, 0.375, 0.375 )
            row.createtime:setFillColor(unpack(__Read_NoticeList_FontColor__))
            row.createtime.x = row.writer.x
            row.createtime.y = row.writer.y + row.writer.height +3
            row:insert(row.createtime)
            
            local sTitle = rowData.title
            if(utils.UFT8Len(sTitle) > __TITLE_LIMIT_LENGTH__) then
                sTitle = utils.UTF8Sub(sTitle, 1, __TITLE_LIMIT_LENGTH__) .. "..."
            end
            row.title = display.newText(sTitle, 12, 0, native.systemFontBold, 12 )
            row.title.anchorX = 0
            row.title.anchorY = 0
--            row.title:setFillColor( 0 )
            row.title:setFillColor(unpack(__Read_NoticeList_FontColor__))
            row.title.x = row.rect.x + LEFT_PADDING
            row.title.y = row.rect.y + 5 + imageHeight + 10
            row:insert(row.title)
            
--          Contents  
            local sContents = rowData.contents
            if(utils.UFT8Len(sContents) > __CONTENTS_LIMIT_LENGTH__) then
                sContents = utils.UTF8Sub(sContents, 1, __CONTENTS_LIMIT_LENGTH__) .. "..."
            end    
            local contents_options = {
                text = sContents,     
                height = 45,
                width = __appContentWidth__ - 50,     --required for multi-line and alignment
                font = native.systemFontBold,   
                fontSize = __LIST_SCENE_TEXT_SIZE__,
                align = "left"  --new alignment parameter
            }
            row.contents = display.newText(contents_options )
            row.contents.anchorX = 0
            row.contents.anchorY = 0
--            row.contents:setFillColor( 0 )
            row.contents:setFillColor(unpack(__Read_NoticeList_FontColor__ ))
            row.contents.y = row.title.y + row.title.height + 5
            row.contents.x = row.title.x
            row:insert(row.contents)
            
            row.goodImg = display.newImageRect("images/assets1/btn_like.png", 40 , 15) 
            row.goodImg.anchorX = 0
--            row.goodImg.anchorY = 0
            row.goodImg.x = row.title.x
            row.goodImg.y = row.rect.y + row.rect.height - row.goodImg.height
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
            row:insert(row.rightArrow)
        else
            --Row 데이타가 없음..따라서 데이타 없다고 표시
            row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
            row:insert(row.rect )
            
            row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
            row.noDataimg.anchorY = 0
            row.noDataimg.x = display.contentCenterX
            row.noDataimg.y = 20
            row:insert(row.noDataimg)
            
            row.noData_txt = display.newText(language["mamatalkScene"]["no_data"], 12, 0, native.systemFont, 12)
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
        if(mamatalkTable) then
            local cnt = json_data.mamatalk_cnt
            if (firstID) then
--              과거 데이타 추가  
                if (cnt > 0) then
                    if(tonumber(firstID) == tonumber(json_data.mamatalk[1].id)) then
                        --새로운 내용이 없음
                        return true 
                    elseif(tonumber(firstID) > tonumber(json_data.mamatalk[1].id)) then
                        --과거 데이터 가져옴
                        if (cnt < pagesize ) then
                            isLastData = true
                        end
                        
                        for i = 1, cnt do
                            local existImage = existImage(json_data.mamatalk[i])
                            mamatalkTable:insertRow{
                                rowHeight = ROW_HEIGHT,
                                rowColor = {  default = { 1, 1, 1,0 }, over = { 1, 1, 1, 0}},
                                lineColor = { 0.5, 0.5, 0.5 },
                                params = {
                                    mamatalk_data = json_data.mamatalk[i],
                                    existImage = existImage
                                }
                            }
                        end
                        return true
                    end
                end
            else
--              새로고침 또는 처음 로딩, 반 선택
                if(cnt > 0) then
                    firstID = json_data.mamatalk[1].id

                    mamatalkTable:deleteAllRows()

                    mamatalkTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 }},
                    }
                    for i = 1, cnt do
                        local existImage = existImage(json_data.mamatalk[i])
                        mamatalkTable:insertRow{
                            rowHeight = ROW_HEIGHT,
                            rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                            lineColor = { 0.5, 0.5, 0.5 },
                            params = {
                                mamatalk_data = json_data.mamatalk[i],
                                existImage = existImage
                            }
                        }		
                    end
                else
                    mamatalkTable:deleteAllRows()
                    
                    mamatalkTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0}},
                    }--헤더로
                    mamatalkTable:insertRow{
                         rowHeight = NODATA_ROW_HEIGHT,
                         rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                         lineColor = { 0.5, 0.5, 0.5 },
                         params = {
                            mamatalk_data = nil
                        }
                    }--아직 데이타가 없다는 내용을 표시하기위한 로row
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
                    utils.showMessage(language["common"]["wrong_connection"])
                end
            end
        end
    end
    
    return true
end

local function getPastDataCallback(event)
    local function makeRow(json_data)
        if(mamatalkTable) then
            local cnt = json_data.mamatalk_cnt
            if(cnt > 0) then
                if (cnt < pagesize ) then
                    isLastData = true
                end
                for i = 1, cnt do
                    local existImage = existImage(json_data.mamatalk[i])
                    mamatalkTable:insertRow{
                        rowHeight = ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            mamatalk_data = json_data.mamatalk[i],
                            existImage = existImage
                        }
                    }		
                end
            else
                isLastData = true
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
    mamatalkTable:scrollToIndex(1, 10, nil)
    local reloadCompleteTimer = timer.performWithDelay( 1000, reloadcomplete, 1 )      	 
end

local function onRowTouch( event )
    if event.phase == "release" then
        local id = event.row.index
        local rowData = event.target.params.mamatalk_data
        
        if(id ~= 1 and rowData) then
            storyboard.purgeScene("scripts.mamatalkViewScene")
            local options = {
                effect = "slideLeft",
                time = 300,
            }
            storyboard.isAction = true
            sceneData.addSceneData("scripts.mamatalkScene", "scripts.mamatalkViewScene", rowData)
            storyboard.gotoScene("scripts.mamatalkViewScene", options)
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
            
        springStart = mamatalkTable:getContentPosition( )
        print("springStart", springStart)
        
--        clearScreen()
    elseif ( event.phase == "moved") then
        if (mamatalkTable:getContentPosition( ) > springStart + REFRESH_ROW_HEIGHT) then
            needToReload = true
            transition.to( pullDown, { time=100, rotation=180 } )
        end    
        
        if (mamatalkTable:getContentPosition( ) < springStart - (REFRESH_ROW_HEIGHT * 0.5)) then
            needToPastload = true
--            transition.to( pullDown, { time=100, rotation=180 } )
        end
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "down" and needToReload == true and loadingApi == false ) then
--      새로고침  
        reloadInProgress = true  --turn this off at the end of the reload function
        needToReload = false
	if(pullDown) then
            pullDown.alpha = 0
        end
	reloadspinner.alpha = 1
        reloadspinner:start()              
        loadingApi = true
        firstID = nil
        isLastData = false
        pageno = 1
        if(selected_class_id == "0" or selected_class_id == "") then
            api.get_mamatalk_list(user.userData.centerid, "", pageno, pagesize, getDataCallback)
        else
            api.get_mamatalk_list(user.userData.centerid, selected_class_id, pageno, pagesize, getDataCallback)
        end
        
        reloadTable() 
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "up" and needToPastload == true and loadingApi == false) then    
--      과거데이타
        if (isLastData == false) then
            needToPastload = false
            loadingApi = true
            pageno = pageno + 1
            if(selected_class_id == "0" or selected_class_id == "") then
                api.get_mamatalk_list(user.userData.centerid, "", pageno, pagesize, getPastDataCallback)
            else
                api.get_mamatalk_list(user.userData.centerid, selected_class_id, pageno, pagesize, getPastDataCallback)
            end
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
        storyboard.purgeScene("scripts.mamatalkWriteScene")
        storyboard.gotoScene("scripts.mamatalkWriteScene" , "slideLeft", 300)
    end
    
    return true
end

local function viewClass()
--    if (clearScreen() == true) then
--        return 
--    end
--    clearScreen()
    local startIndexClass = 1 --전체반
    local classes = {}
    local class_label = {}
    local class_cnt = #user.classList
    classes[1] = {id = "0",name = language["mamatalkScene"]["all_class"], desc = ""}
    class_label[1] = language["mamatalkScene"]["all_class"]
    for i = 1, class_cnt do
        local class = {}
        class.id = user.classList[i].id
        class.name = user.classList[i].name
        classes[i+1] = class
        class_label[i+1] = user.classList[i].name
        
        if(class.id == selected_class_id) then
            startIndexClass = i+1
        end
    end
        
    local columnData = 
    {
        -- Years
        {
            align = "center",
            width = __appContentWidth__- 50,
            startIndex = startIndexClass,
            labels = class_label
        },
    
    }  
        
    pickerList = widget.newPickerList(
        {   
            left = 0,
            top = __statusBarHeight__,
            width = __appContentWidth__ ,
            height = __appContentHeight__ -__statusBarHeight__,
--            pickerHeight = 130,
            pickerData = columnData,
            titleText = language["mamatalkScene"]["select_class"],
--            onScroll = nil,
            okButtonText = language["mamatalkScene"]["ok"],
--            onClose = onClosePicker,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                local obj = event.target
                                local value = pickerList.pickerWheel:getValues()
                                print(value[1].value)
                                print(value[1].index)
                                local classData = classes[value[1].index]
                                
                                if(selected_class_id ~= classData.id) then
                                    firstID = nil
                                    pageno = 1
                                    isLastData = false
                                    
                                    selected_class_id = classData.id
                                    selectClassName.text = classData.name

                                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                                    loadingApi = true
                                    if(selected_class_id == "0" or selected_class_id == "") then
                                        api.get_mamatalk_list(user.userData.centerid, "", pageno, pagesize, getDataCallback)
                                    else
                                        api.get_mamatalk_list(user.userData.centerid, selected_class_id, pageno, pagesize, getDataCallback)
                                    end
                                end
                            end
                        end,
        }
    )
    pickerList.isShowing = true
       
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    imageGroup = display.newGroup()
    
    springStart = 0
    firstID = nil
    pageno = 1
    
    func.clear_news(user.userData.id, "mamatalk")
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mamatalkScene"]["back"],
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
        label = language["mamatalkScene"]["write"],
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
            onPress =   function() 
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
    tabBar:setSelected(0, false)
    
    mamatalkTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT - REFRESH_ROW_HEIGHT + SELECT_CLASS_BAR,
	height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - tabButton_height - NAME_BAR_HEIGHT - __statusBarHeight__  - SELECT_CLASS_BAR,
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
    mamatalkTable.x = display.contentCenterX
    group:insert(mamatalkTable)   
    
    local navBar = widget.newNavigationBar({
        title = language["mamatalkScene"]["title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt
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
    
    local selectClassGroup = display.newGroup()
    group:insert(selectClassGroup)
    
    local selectClassRect = display.newRect(group, display.contentCenterX, 0, __appContentWidth__, SELECT_CLASS_BAR)
    selectClassRect.anchorY = 0
    selectClassRect.y = nameRect.y + (nameRect.height / 2)
--    selectClassRect.strokeWidth = 0
    selectClassGroup:insert(selectClassRect)
    
    local selectClassText = display.newText(language["mamatalkScene"]["short_select_class"], 0, 0, native.systemFont, 12)
    selectClassText.anchorX = 0
    selectClassText.anchorY = 0
    selectClassText.x = 10
    selectClassText.y = selectClassRect.y + (selectClassRect.height - selectClassText.height)/2
    selectClassText:setFillColor( 0 )
    selectClassGroup:insert(selectClassText)
    
    local class_name
    selected_class_id = nil
    if(selected_class_id and selected_class_id ~= "0") then
        class_name = user.getClassName(selected_class_id)
    elseif(selected_class_id == "")then
        class_name = user.getClassName(user.userData.classId)
    elseif(selected_class_id == "0")then
        class_name = language["mamatalkScene"]["all_class"]
    else --nil
        class_name = user.getClassName(user.userData.classId)
        selected_class_id = user.userData.classId
    end
    
    selectClassName = display.newText(class_name, 0, 0, native.systemFont, 12)
    selectClassName.anchorX = 0
    selectClassName.anchorY = 0
    selectClassName.x = selectClassText.x + selectClassText.width + 10
    selectClassName.y = selectClassRect.y + (selectClassRect.height - selectClassText.height)/2
    selectClassName:setFillColor( 0 )
    selectClassGroup:insert(selectClassName)
    
    selectClassRect:setFillColor( unpack(__SELECT_CLASS_RECT_COLOR__))  --
    selectClassGroup:addEventListener("touch", 
        function(event)
            if event.phase == "ended" then
                viewClass()
            end
            
            return true
        end 
    )
    
    loadingApi = true
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_mamatalk_list(user.userData.centerid, selected_class_id, pageno, pagesize, getDataCallback)
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
    
--    firstID = nil
--    pageno = 1
    loadingApi = false
    
    api.cancelRequest()
    
    if(pickerList) then
        pickerList:closeUp()
        pickerList.isShowing = false
    end
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



