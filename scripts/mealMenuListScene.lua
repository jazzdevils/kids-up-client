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
local api = require("scripts.api")
local user = require("scripts.user_data")
local authority = require("scripts.user_authority")
local func = require("scripts.commonFunc")

local ROW_HEIGHT = 130
local REFRESH_ROW_HEIGHT = 50
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local CATEGORY_ROW_HEIGHT = 30
local NODATA_ROW_HEIGHT = 280

local mealsTable
local pageno = 1 --페이징 번호
local pagesize = 5 --리스트 갯수
local isLastData = false

local firstMealMenuDate --새로운 데이타가 있는지 확인용
local activityIndicator
local loadingApi

local pressDeleteButton = false
local previous_scene
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onViewDetailMenu(event)
    if(pressDeleteButton == true) then
        pressDeleteButton = false
        
        return true
    end
    
    if(#event.target.selected_menus > 0 and event.target.selected_menu_thumbImgName) then
        local options =
        {
            effect = "fade",
            time = 300,
            isModal = true,
            params =
                {
                    selected_menus = event.target.selected_menus,
                    selected_menu_date = event.target.selected_menu_date,
                    selected_menu_thumbImgName = event.target.selected_menu_thumbImgName,
                }
            }
        storyboard.showOverlay("scripts.slideImageViewer4MealsMenu", options)
    end
    
--    return true        
end

local function getDataCallback(event)
    local function makeRow(json_data)
        if(mealsTable) then
            local dailymenu_cnt = json_data.dailymenu_cnt
            if(dailymenu_cnt > 0) then
                if (firstMealMenuDate) then
                    if(firstMealMenuDate == json_data.dailymenu[1].date) then
                        --새로운 내용이 없음
                        return true 
                    elseif(firstMealMenuDate > json_data.dailymenu[1].date) then
                        --과거 데이터 가져옴
                        if (dailymenu_cnt < pagesize ) then
                            isLastData = true
                        end
                        
                        for i = 1, dailymenu_cnt do
                            mealsTable:insertRow{ --category
                                rowHeight = CATEGORY_ROW_HEIGHT,
                                rowColor = { default = __activeKidListColor__},
                                lineColor = { 1, 0, 0 },
                                isCategory = true,
                                params = {
                                    row_Data = json_data.dailymenu[i],
                                    no_data = false
                                }
                            }

                            local row_cnt = math.floor(json_data.dailymenu[i].menu_cnt / 3) 
                            if(json_data.dailymenu[i].menu_cnt % 3) > 0 then
                                row_cnt = row_cnt + 1
                            end
                            
                            local rowHeight = ROW_HEIGHT * row_cnt
                            mealsTable:insertRow{
                                rowHeight = rowHeight,
                                rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                                lineColor = { 0.5, 0.5, 0.5 },
                                params = {
                                    row_Data = json_data.dailymenu[i],
                                    no_data = false
                                }
                            }
                        end
                        
                        return true
                    end
                end
                
                firstMealMenuDate = json_data.dailymenu[1].date
                
                mealsTable:deleteAllRows()
                
                mealsTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                    rowHeight = REFRESH_ROW_HEIGHT,
                    rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 }},
                    params = {
--                        row_Data = nil,
                        no_data = false
                    }
                }
                for i = 1, dailymenu_cnt do
                    mealsTable:insertRow{ --category
                        rowHeight = CATEGORY_ROW_HEIGHT,
                        rowColor = { default = __activeKidListColor__},
                        lineColor = { 1, 0, 0 },
                        isCategory = true,
                        params = {
                            row_Data = json_data.dailymenu[i],
                            no_data = false
                        }
                    }
                    
                    local row_cnt = math.floor(json_data.dailymenu[i].menu_cnt / 3) 
                    if(json_data.dailymenu[i].menu_cnt % 3) > 0 then
                        row_cnt = row_cnt + 1
                    end
                    
                    local rowHeight = ROW_HEIGHT * row_cnt
                    mealsTable:insertRow{
                        rowHeight = rowHeight,
                        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            row_Data = json_data.dailymenu[i],
                            no_data = false
                        }
                    }
                end
            else
                --처음부터 데이터가 없었는지 확인
                local rowCount = mealsTable:getNumRows()
                
                if(firstMealMenuDate) then
                    isLastData = true
                else
                    mealsTable:deleteAllRows()
                    mealsTable:insertRow{  -- this is the row containing the pulldown arrow/spinner
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 }},
                        params = {
    --                        row_Data = nil,
                            no_data = false
                        }
                    }
                    mealsTable:insertRow{
                         rowHeight = NODATA_ROW_HEIGHT,
                         rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                         lineColor = { 0.5, 0.5, 0.5 },
                         params = {
                            row_Data = nil,
                            no_data = true,
                        }
                    }--아직 공지가 없다는 내용을 표시하기위한 로row
                      
                end
            end    
        end
    end
    
    loadingApi = false
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
    if ( event.isError ) then
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

local function createDeleteButton(rect, row, image_width, image_height)
    local deleteButton = widget.newButton
    {
        width = 30,
        height = 30,
        defaultFile = "images/assets1/icon_delete_photo.png",
        overFile = "images/assets1/icon_delete_photo.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        fontSize = __buttonFontSize__,
        font = native.systemFontBold,
--        label = language["mealMenuListScene"]["delete"],
        onRelease = function(event) 
            if(event.phase == "ended") then
                print(event.phase)  
                local obj = event.target.object
                pressDeleteButton = true
                
                if utils.IS_Demo_mode(storyboard, true) == true then
                    return true
                end
--                                  
                native.showAlert(language["appTitle"], language["mealMenuListScene"]["delete_menu"], 
                    { language["mealMenuListScene"]["yes"], language["mealMenuListScene"]["no"] }, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
--                                local activeKidData = user.getActiveKidData()
                                local pDate = obj.selected_menu_date
                                local fileName = obj.selected_menu_previewImgName:match("([^/]+)$")  
                                print("delete menu : "..fileName.." date : "..pDate)
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["delete"])
                                loadingApi = true
                                api.delete_dailymenu_data(user.userData.centerid, pDate, fileName, 
                                    function(event)
                                        loadingApi = false
                                        if(event.isError) then
                                            print("delete error")
                                            activityIndicator:destroy()
                                        else
                                            activityIndicator:destroy()
                                            pageno = 1
                                            firstMealMenuDate = nil
                                            loadingApi = true
                                            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                                            api.get_dailymenu_list(user.userData.centerid, user.userData.classId, pageno, pagesize, getDataCallback)
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
    deleteButton.anchorX = 0
    deleteButton.anchorY = 0
    deleteButton.x = rect.x + (image_width - deleteButton.width) + 8
    deleteButton.y = rect.y + (image_height - deleteButton.height) 
    deleteButton.object = rect
    row:insert(deleteButton)
            
    if(authority.validAuthorityByUser(__MEAL_MENU_DELETE__) == true) then
--        권한 확인
        deleteButton.isVisible = true
    else
        deleteButton.isVisible = false
    end
end

local function getNewSize( displayObject, fitWidth, fitHeight)
    local scaleFactor
    if(displayObject.height > displayObject.width) then
        scaleFactor = fitHeight / displayObject.height
    else
        scaleFactor = fitWidth / displayObject.width
    end
    local newWidth = displayObject.width * scaleFactor
    local newHeight = displayObject.height * scaleFactor
    
    return newWidth, newHeight
end

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.row_Data
    local no_data = row.params.no_data
    
    if(no_data == true and rowData == nil and row.isCategory == false) then
--        Row 데이타가 없음..따라서 데이타 없다고 표시
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row:insert(row.rect )

        row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
        row.noDataimg.anchorY = 0
        row.noDataimg.x = display.contentCenterX
        row.noDataimg.y = 20
        row:insert(row.noDataimg)

        row.noData_txt = display.newText(language["mealMenuListScene"]["no_data"], 12, 0, native.systemFont, 12)
        row.noData_txt.anchorY = 0
        row.noData_txt:setFillColor( 0 ,0 ,0 )
        row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
        row.noData_txt.x = display.contentCenterX
        row:insert(row.noData_txt)
    elseif(row.isCategory == true) then
        local sYear = string.sub(rowData.date, 1, 4)
        local sMonth = string.sub(rowData.date, 5, 6)
        local sDay = string.sub(rowData.date, 7, 8)
        local strTmp = utils.convert2LocaleDateString(sYear, sMonth, sDay).. " ("..utils.getDayOfWeek(sYear, sMonth, sDay)..") "..language["mealMenuListScene"]["menu"]
        row.category_info = display.newText(strTmp, 0, 0, native.systemFontBold, 12)
        row.category_info.anchorX = 0
        row.category_info.anchorY = 0
        row.category_info.x = 10
        row.category_info.y = (row.contentHeight - row.category_info.height) /2
        row.category_info:setFillColor(0, 0, 0)
        row:insert(row.category_info)
    elseif(no_data == false and rowData ~= nil and row.isCategory == false) then
        row.anchorX = 0
        row.anchorY = 0
        
        local menu_cnt = rowData.menu_cnt 
        local rect_height = ROW_HEIGHT - 10
        local rect_width = (row.width - 20) / 3
        local PADDING = 5
        
        row.rects = {}
        local startRowIndex = 0
        local rowIndex = 0
        for i = 1, menu_cnt do
            row.rects[i] = display.newRoundedRect(0, 0, rect_width, rect_height, 6)
            row.rects[i].anchorX = 0
            row.rects[i].anchorY = 0
            if(row.rects[i-1]) then
                if(startRowIndex == rowIndex) then
                    row.rects[i].x = PADDING + row.rects[i-1].x + rect_width
                else
                    row.rects[i].x = PADDING
                    startRowIndex = rowIndex
                end
                
                row.rects[i].y = (rowIndex * (rect_height + PADDING)) + PADDING
            else
                row.rects[i].x = PADDING
                row.rects[i].y = PADDING
            end
            
            rowIndex = math.floor(i/3)
            
            row:insert(row.rects[i])
                    
            local imgHeight = row.rects[i].height - 40
            local imgWidth = row.rects[i].width - 10
            local thumb_imgName = rowData.menu[i].thumbnail_image:match("([^/]+)$")  
            
            row.rects[i].imgRect = display.newRect(0, 0, imgWidth, imgHeight)
            row.rects[i].imgRect.anchorX = 0
            row.rects[i].imgRect.anchorY = 0
            row.rects[i].imgRect.x = row.rects[i].x + (row.rects[i].width - imgWidth)/2
            row.rects[i].imgRect.y = row.rects[i].y + 5
            row:insert(row.rects[i].imgRect)
            
            local imgRect_x = row.rects[i].imgRect.x
            if(thumb_imgName) then
                if(utils.fileExist(thumb_imgName, system.TemporaryDirectory) == true) then
                    row.rects[i].img = display.newImage(thumb_imgName, system.TemporaryDirectory)
                    
                    local newWidth, newHeight = getNewSize(row.rects[i].img, imgWidth, imgHeight)
                    row.rects[i].img.width = newWidth --imgWidth
                    row.rects[i].img.height = newHeight--imgHeight
                    
                    row.rects[i].img.anchorX = 0
                    row.rects[i].img.anchorY = 0
                    row.rects[i].img.x = row.rects[i].imgRect.x + (imgWidth - newWidth)/2 --row.rects[i].x + (row.rects[i].width - row.rects[i].img.width)/2
                    row.rects[i].img.y = row.rects[i].imgRect.y--row.rects[i].y + 5--(row.rects[i].height - row.rects[i].img.height)/2
                    
                    if pcall(function() row:insert(row.rects[i].img) end) then
                        createDeleteButton(row.rects[i], row, imgWidth, imgHeight)
                    else
                        if(row.rects[i].img) then
                            display.remove(row.rects[i].img)
                        end
                    end
                else
                    local requestId =
                        network.download(
                            rowData.menu[i].thumbnail_image,
                            "GET",
                            function(event)
                                if (event.isError) then
                                        
                                elseif ( event.phase == "ended" ) then
                                    if(utils.fileExist(event.response.filename, system.TemporaryDirectory) == true) then
                                        row.rects[i].img = display.newImage(event.response.filename, system.TemporaryDirectory)
                                        
                                        local newWidth, newHeight = getNewSize(row.rects[i].img, imgWidth, imgHeight)
                                        row.rects[i].img.width = newWidth
                                        row.rects[i].img.height = newHeight
                                        
                                        row.rects[i].img.anchorX = 0
                                        row.rects[i].img.anchorY = 0
                                        row.rects[i].img.x = imgRect_x + (imgWidth - newWidth)/2
                                        row.rects[i].img.y = row.rects[i].imgRect.y--row.rects[i].y + 5--(row.rects[i].height - row.rects[i].img.height)/2
                                        
                                        if pcall(function() row:insert(row.rects[i].img) end) then
                                            createDeleteButton(row.rects[i], row, imgWidth, imgHeight)
                                        else
                                            if(row.rects[i].img) then
                                                display.remove(row.rects[i].img)
                                            end
                                        end
                                    end
                                end
                            end ,
                            thumb_imgName,
                            system.TemporaryDirectory
                        )
                    api.insertQueue(requestId)
                end
                                
                row.rects[i].selected_menus = rowData.menu
                row.rects[i].selected_menu_date = rowData.date
                row.rects[i].selected_menu_thumbImgName = thumb_imgName
                row.rects[i].selected_menu_previewImgName = rowData.menu[i].preview_image:match("([^/]+)$")
                print(row.rects[i].selected_menu_previewImgName)
            end
            
            local menuTitle = rowData.menu[i].title
            if(utils.UFT8Len(menuTitle) > 13) then
                menuTitle = utils.UTF8Sub(menuTitle, 1, 13) .. "..."
            end
            
            local options = 
            {
                --parent = textGroup,
                text = menuTitle,
                x = 0,
                y = 0,
                height = rect_height - imgHeight - 12,
                width = imgWidth,
                font = native.systemFont,   
                fontSize = 10,
                align = "left"  --new alignment parameter
            }
            
            row.rects[i].title = display.newText(options)
            row.rects[i].title.anchorX = 0
            row.rects[i].title.anchorY = 0
            row.rects[i].title:setFillColor( 0 )
            row.rects[i].title.x = row.rects[i].x + 5
            row.rects[i].title.y = row.rects[i].y + row.rects[i].height - row.rects[i].title.height - 5
            
            row.rects[i]:addEventListener("tap", onViewDetailMenu)
            row:insert(row.rects[i].title)
        end
    end
end
        
local function reloadTable()
--    local function reloadcomplete()   
--        if (reloadspinner ~= nil) and (reloadspinner.x ~= nil) then 
--	    reloadspinner:stop()
--            reloadspinner.alpha = 0
--        end	 	   
--	transition.to( pullDown, { time=250, rotation=0, onComplete= function()	
--                if (pullDown ~= nil) and (pullDown.x ~= nil) then
--                    pullDown.alpha = 1; 
--	   	end
--                reloadInProgress = false; 
--	end } )        	 
--    end
--    mealsTable:scrollToIndex(1, 10, nil)
--    local reloadCompleteTimer = timer.performWithDelay( 3000, reloadcomplete, 1 )      	 
end

local function onRowTouch( event )
--    if event.phase == "release" then
--        local id = event.row.index
--        local rowData = event.target.params.notice_data
--        if(id ~= 1 and rowData) then
--            local options = {
--                effect = "slideLeft",
--                time = 300,
--            }
--            sceneData.addSceneData("scripts.noticeScene", "scripts.noticeViewScene", rowData)
--            storyboard.gotoScene("scripts.noticeViewScene", options)
--        end
--    end
--    return true
--    
end

local function scrollListener( event )
--    print("tableview scrollListener")
--    if (reloadInProgress == true) then
--        return true
--    end
	
    if ( event.phase == "began" ) then
--        needToReload = false
--        needToPastload = false
--        springStart = event.target.parent.parent:getContentPosition()
--        print("springStart", springStart)
--    elseif ( event.phase == "moved" ) and (event.target.parent.parent:getContentPosition( ) > springStart + REFRESH_ROW_HEIGHT) then
--        needToReload = true
--        transition.to( pullDown, { time=100, rotation=180 } )
--    elseif ( event.phase == "moved" ) and (event.target.parent.parent:getContentPosition( ) < springStart - REFRESH_ROW_HEIGHT) then
--        print("moved getContentPosition : " ..event.target.parent.parent:getContentPosition( ))
--        needToPastload = true    
--    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "down" and needToReload == true ) then
--        reloadInProgress = true  --turn this off at the end of the reload function
--        needToReload = false
--	pullDown.alpha = 0
--	reloadspinner.alpha = 1
--        reloadspinner:start()              
--        
--        pageno = 1
--        api.get_dailymenu_list(user.getActiveKidData().center_id, pageno, pagesize, getDataCallback)
--        reloadTable() 
--        
--        print("needToReload")
    elseif ( event.limitReached == true and event.phase == nil and  event.direction == "up" and loadingApi == false) then    
--        needToPastload = false
        
        if(isLastData == false) then
            pageno = pageno + 1
--            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
            loadingApi = true
            api.get_dailymenu_list(user.userData.centerid, user.userData.classId, pageno, pagesize, getDataCallback)
            print("needToPastload PageNo : "..pageno)
        end
   end    
   
--   return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        if (previous_scene == "scripts.newsScene") then
            storyboard.purgeScene(previous_scene)
            storyboard.gotoScene(previous_scene, "slideRight", 300)
        else
            storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "slideRight", 300)
        end
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        storyboard.isAction = true
        storyboard.purgeScene("scripts.mealMenuWriteScene")
        storyboard.gotoScene("scripts.mealMenuWriteScene", "slideLeft", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    previous_scene = storyboard.getPrevious()
    
    if(previous_scene == "scripts.newsScene" and event.params) then
        api.get_news_detail3(event.params.member_id, event.params.device_id, event.params.seq, user.getActiveKid_IDByAuthority(),
            utils.IS_Demo_mode(storyboard, false),
            function()  
            end
        )
    else
        func.clear_news(user.userData.id, "dailymenu")    
    end
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mealMenuListScene"]["back"],
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
        label = language["mealMenuListScene"]["write"],
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
    
    mealsTable = widget.newTableView{
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
	onRowTouch = function() print("onRowTouch") end,
	listener = scrollListener
    }
    mealsTable.x = display.contentCenterX
    group:insert(mealsTable)   
    
    local navBar
    if(authority.validAuthorityByUser(__MEAL_MENU_WRITE) == true) then
        navBar = widget.newNavigationBar({
            title = language["mealMenuListScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
            rightButton = btn_right_opt,
        })
    else
        navBar = widget.newNavigationBar({
            title = language["mealMenuListScene"]["title"],
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
    api.get_dailymenu_list(user.userData.centerid, user.userData.classId, pageno, pagesize, getDataCallback)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
--    storyboard.returnTo = __DEFAULT_HOMESCENE_NAME__
    storyboard.returnTo = previous_scene
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
    firstMealMenuDate = nil
    pageno = 1
    isLastData = false
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

