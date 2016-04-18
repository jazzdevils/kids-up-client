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
local func = require("scripts.commonFunc")
local sceneData = require("scripts.sceneData")

local ROW_HEIGHT = 110
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local NODATA_ROW_HEIGHT = 280

local albumTable
local pageno = 1 --페이징 번호
local pagesize = 15 --리스트 갯수
local THUMBNAIL_IMAGE_WIDTH = 80
local THUMBNAIL_IMAGE_HEIGHT = 100
local firstAlbumID
local isLastData = false
local previous_scene

local imageList4Slide
local activityIndicator
local pressDeleteButton = false
local loadingApi

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onContensImageTap( event )
    if(pressDeleteButton == true) then
        pressDeleteButton = false
        
        return true
    end
    
    if(#imageList4Slide > 0 and event.target.selected_album_idx) then
        local options =
        {
            effect = "fade",
            time = 300,
            isModal = true,
            params =
                {
                    imageList4Slide = imageList4Slide,
                    selected_album_member_id = event.target.selected_album_member_id,
                    selected_album_kids_id = event.target.selected_album_kids_id,
                    selected_album_idx = event.target.selected_album_idx,
                }
        }

        storyboard.showOverlay("scripts.slideImageViewer4Album", options)
    end
end

local function getDataCallback(event)
    local function makeRow(json_data)
        if(albumTable) then
            local imgCnt = json_data.album_cnt
            
            if imgCnt < pagesize then
                isLastData = true
            end
            
            if(imgCnt > 0) then
                local rowCnt = imgCnt / 3
                if(imgCnt%3 ~= 0) then
                    rowCnt = rowCnt + 1
                end
                
                if (firstAlbumID) then
                    local newAlbumID = tonumber(json_data.album[1].idx)
                    print(newAlbumID)
                    if(firstAlbumID > newAlbumID) then
                        --과거 데이터 가져옴
                        for j = 1, imgCnt, 3 do
                            albumTable:insertRow{
                                rowHeight = ROW_HEIGHT,
                                rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                                lineColor = { 0.5, 0.5, 0.5 },
                                params = {
                                    album_col1 = json_data.album[j],
                                    album_col2 = json_data.album[j+1],
                                    album_col3 = json_data.album[j+2],
                                }
                            }
                            if(json_data.album[j]) then    
                                table.insert(imageList4Slide, json_data.album[j])
                            end
                            if(json_data.album[j+1]) then
                                table.insert(imageList4Slide, json_data.album[j+1])    
                            end
                            if(json_data.album[j+2]) then
                                table.insert(imageList4Slide, json_data.album[j+2])
                            end
                        end
                        
                        return true
                    end
                end
                --새로운 내용이 있어 데이터 가져옴
                albumTable:deleteAllRows()
                
                firstAlbumID = tonumber(json_data.album[1].idx)
                for j = 1, imgCnt, 3 do
                    albumTable:insertRow{
                        rowHeight = ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            album_col1 = json_data.album[j],
                            album_col2 = json_data.album[j+1],
                            album_col3 = json_data.album[j+2],
                        }
                    }
                    if(json_data.album[j]) then    
                        table.insert(imageList4Slide, json_data.album[j])
                    end
                    if(json_data.album[j+1]) then
                        table.insert(imageList4Slide, json_data.album[j+1])    
                    end
                    if(json_data.album[j+2]) then
                        table.insert(imageList4Slide, json_data.album[j+2])
                    end
                end
            else
                if(firstAlbumID == nil) then
                    albumTable:deleteAllRows()
                    
                    albumTable:insertRow{
                         rowHeight = NODATA_ROW_HEIGHT,
                         rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                         lineColor = { 0.5, 0.5, 0.5 },
                         params = {
                            params = {
                                album_col1 = nil,
                                album_col2 = nil,
                                album_col3 = nil,
                            }
                        }
                    }--아직 엘범이 없다는 내용을 표시하기위한 로row
                end
            end    
        end
        
        return
    end
    
    loadingApi = false
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
    if ( event.isError ) then
        print( "Network error!")
        utils.showMessage(language["common"]["wrong_connection"])
    else    
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

local function createDeleteButton(container, row, container_width, container_height)
    local deleteButton = widget.newButton
    {
        width = 30,
        height = 30,
        defaultFile = "images/assets1/icon_delete_photo.png",
        overFile = "images/assets1/icon_delete_photo.png",
        onRelease = function(event) 
            if(event.phase == "ended") then
                print(event.phase)  
                local obj = event.target.object
                pressDeleteButton = true
                
                if utils.IS_Demo_mode(storyboard, true) == true then
                    return true
                end
                
                native.showAlert(language["appTitle"], language["albumListScene"]["delete_question"]
                    , { language["albumListScene"]["yes"], language["albumListScene"]["no"]}, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["delete"])
                                loadingApi = true
                                api.delete_album_data(obj.selected_album_member_id, 
                                    obj.selected_album_kids_id, obj.selected_album_idx, 
                                    function(e)
--                                        activityIndicator:destroy()
                                        firstAlbumID = nil
                                        pageno = 1
                                        api.get_album_list2(user.userData.id, user.getActiveKidData().id, pageno, pagesize, getDataCallback)
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
    deleteButton.x = container.x + (container_width - deleteButton.width) - 2
    deleteButton.y = container.y + (container_height - deleteButton.height) - 2
    deleteButton.object = container
    row:insert(deleteButton)
end

local function onRowRender( event )
    local row = event.row
    local album_col1 = row.params.album_col1
    local album_col2 = row.params.album_col2
    local album_col3 = row.params.album_col3
    
    
    row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width, row.height - 2, 0)
    row:insert(row.rect )
    
    local rectWidth = row.rect.width
    local cellWidth = (rectWidth - 8) / 3
    local cellheight = row.rect.height
    
    if(album_col1 == nil and album_col2 == nil and album_col3 == nil) then
        --Row 데이타가 없음..따라서 데이타 없다고 표시
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row:insert(row.rect )

        row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
        row.noDataimg.anchorY = 0
        row.noDataimg.x = display.contentCenterX
        row.noDataimg.y = 20
        row:insert(row.noDataimg)

        row.noData_txt = display.newText(language["albumListScene"]["no_data"], 12, 0, native.systemFont, 12)
        row.noData_txt.anchorY = 0
        row.noData_txt:setFillColor( 0 ,0 ,0 )
        row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
        row.noData_txt.x = display.contentCenterX
        row:insert(row.noData_txt)
        
        return true
    end
    
    if(album_col1) then
        local imgName1 = album_col1.thumbnail_image:match("([^/]+)$")  
        row.container1 = display.newContainer( cellWidth, cellheight)
        row.container1.anchorX = 0
        row.container1.anchorY = 0
        row.container1.x = 2
        row.container1.y = (row.height - row.container1.height) * 0.5
        row.container1.width = cellWidth
        row.container1.height = cellheight
        row:insert(row.container1)
        if(imgName1) then
            if(utils.fileExist(imgName1, system.TemporaryDirectory) == true) then
                row.img_col1 = display.newImage(imgName1, system.TemporaryDirectory)
                
                if pcall(function() row.container1:insert(row.img_col1, true) end) then
--                    createDeleteButton(row.container1, row, cellWidth, cellheight)
--                    삭제버튼은 없는것이 나을지도...2015.02.26
                else
                    if row.img_col1 then
                        display.remove(row.img_col1)
                    end
                end    
                
                row.container1.selected_album_member_id = album_col1.member_id
                row.container1.selected_album_kids_id = album_col1.kids_id
                row.container1.selected_album_idx = album_col1.idx
            else
                local requestId =
                    network.download(
                        album_col1.thumbnail_image,
                        "GET",
                        function(event)
                            if ( event.phase == "ended" ) then
                                if(utils.fileExist(imgName1, system.TemporaryDirectory) == true) then
                                    row.img_col1 = display.newImage(imgName1, system.TemporaryDirectory)

                                    if pcall(function() row.container1:insert(row.img_col1, true) end) then
--                                        createDeleteButton(row.container1, row, cellWidth, cellheight)
                                    else
                                        if row.img_col1 then
                                            display.remove(row.img_col1)
                                        end
                                    end
                                    
                                    row.container1.selected_album_member_id = album_col1.member_id
                                    row.container1.selected_album_kids_id = album_col1.kids_id
                                    row.container1.selected_album_idx = album_col1.idx
                                else
                                    print("nothing : "..imgName1)    
                                end
                            end
                        end ,
                        imgName1,
                        system.TemporaryDirectory
                    )
                api.insertQueue(requestId)
            end
        end
        
        row.container1:addEventListener("tap", onContensImageTap)
    end
        
    if(album_col2) then
        local imgName2 = album_col2.thumbnail_image:match("([^/]+)$")  
        row.container2 = display.newContainer( cellWidth, cellheight)
        row.container2.anchorX = 0
        row.container2.anchorY = 0
        row.container2.x = row.container1.x + row.container1.width + 2
        row.container2.y = (row.height - row.container2.height) * 0.5
        row.container2.width = cellWidth
        row.container2.height = cellheight
        row:insert(row.container2)
        if(imgName2) then
            if(utils.fileExist(imgName2, system.TemporaryDirectory) == true) then
                row.img_col2 = display.newImage(imgName2, system.TemporaryDirectory)
                
                if pcall(function() row.container2:insert(row.img_col2, true) end) then
--                    createDeleteButton(row.container2, row, cellWidth, cellheight)
                else
                    if row.img_col2 then
                        display.remove(row.img_col2)
                    end
                end
                row.container2.selected_album_member_id = album_col2.member_id
                row.container2.selected_album_kids_id = album_col2.kids_id
                row.container2.selected_album_idx = album_col2.idx
            else
                local requestId =
                    network.download(
                        album_col2.thumbnail_image,
                        "GET",
                        function(event)
                            if ( event.phase == "ended" ) then
                                if(utils.fileExist(imgName2, system.TemporaryDirectory) == true) then
                                    row.img_col2 = display.newImage(imgName2, system.TemporaryDirectory)

                                    if pcall(function() row.container2:insert(row.img_col2, true) end) then
--                                        createDeleteButton(row.container2, row, cellWidth, cellheight)
                                    else
                                        if row.img_col2 then
                                            display.remove(row.img_col2)
                                        end    
                                    end

                                    row.container2.selected_album_member_id = album_col2.member_id
                                    row.container2.selected_album_kids_id = album_col2.kids_id
                                    row.container2.selected_album_idx = album_col2.idx
                                else
                                    print("nothing : "..imgName2)    
                                end
                            end
                        end ,
                        imgName2,
                        system.TemporaryDirectory
                    )
                api.insertQueue(requestId)
            end
        end
        row.container2:addEventListener("tap", onContensImageTap)
    end
        
    if(album_col3) then
        local imgName3 = album_col3.thumbnail_image:match("([^/]+)$")    
        row.container3 = display.newContainer( cellWidth, cellheight)
        row.container3.anchorX = 0
        row.container3.anchorY = 0
        row.container3.x = row.container2.x + row.container2.width + 2
        row.container3.y = (row.height - row.container3.height) * 0.5
        row.container3.width = cellWidth
        row.container3.height = cellheight
        row:insert(row.container3)
        if(imgName3) then
            if(utils.fileExist(imgName3, system.TemporaryDirectory) == true) then
                row.img_col3 = display.newImage(imgName3, system.TemporaryDirectory)
                
                if pcall(function() row.container3:insert(row.img_col3, true) end) then
--                    createDeleteButton(row.container3, row, cellWidth, cellheight)
                else
                    if row.img_col3 then
                        display.remove(row.img_col3)
                    end    
                end
                
                row.container3.selected_album_member_id = album_col3.member_id
                row.container3.selected_album_kids_id = album_col3.kids_id
                row.container3.selected_album_idx = album_col3.idx
            else
                local requestId =
                    network.download(
                        album_col3.thumbnail_image,
                        "GET",
                        function(event) 
                            if ( event.phase == "ended" ) then
                                if(utils.fileExist(imgName3, system.TemporaryDirectory) == true) then
                                    row.img_col3 = display.newImage(imgName3, system.TemporaryDirectory)
                                    
                                    if pcall(function() row.container3:insert(row.img_col3, true) end) then
--                                        createDeleteButton(row.container3, row, cellWidth, cellheight)
                                    else
                                        if row.img_col3 then
                                            display.remove(row.img_col3)
                                        end    
                                    end        
                                    row.container3.selected_album_member_id = album_col3.member_id
                                    row.container3.selected_album_kids_id = album_col3.kids_id
                                    row.container3.selected_album_idx = album_col3.idx
                                else
                                    print("nothing : "..imgName3)
                                end
                            end
                        end ,
                        imgName3,
                        system.TemporaryDirectory
                    )
                api.insertQueue(requestId)
            end
        end
        
        row.container3:addEventListener("tap", onContensImageTap)
    end
end
	
local function onRowTouch( event )
    if event.phase == "release" then
        local id = event.row.index
        local rowData = event.target.params.notice_data
        if(id ~= 1 and rowData) then
            local options = {
                effect = "slideLeft",
                time = 300,
            }
            sceneData.addSceneData("scripts.noticeScene", "scripts.noticeViewScene", rowData)
            storyboard.gotoScene("scripts.noticeViewScene", options)
        end
    end
    return true
    
end

local function scrollListener( event )
    if ( event.phase == "began" ) then
        
    elseif ( event.limitReached == true and  event.direction == "up" and loadingApi == false) then
        if isLastData == false then
--            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
            pageno = pageno + 1
            loadingApi = true
            api.get_album_list2(user.userData.id, user.getActiveKidData().id, pageno, pagesize, getDataCallback)
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

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    previous_scene = storyboard.getPrevious()
    
    imageList4Slide = {}
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["albumListScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }
    
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
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    group:insert(labelTag)
    
    local tabButton_width = __appContentWidth__/5 - 2
    local tabButton_height = tabButton_width * 0.7
    
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
    
    local navBar = widget.newNavigationBar({
        title = language["albumListScene"]["title"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        height = NAVI_BAR_HEIGHT,
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
--        rightButton = btn_right_opt,
--        includeStatusBar = true
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    
    albumTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT + 2,
--        top = __statusBarHeight__ + navBar.height + nameRect.height,
--        height = __appContentHeight__ - navBar.height - tabButton_height - nameRect.height - __statusBarHeight__ ,
        height = __appContentHeight__ - navBar.height - tabButton_height - nameRect.height - 3,
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
    albumTable.x = display.contentWidth / 2
    group:insert(albumTable)   
    
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    print("pageno : "..pageno)
    loadingApi = true
    api.get_album_list2(user.userData.id, user.getActiveKidData().id, pageno, pagesize, getDataCallback)
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
    
    firstAlbumID = nil
    pageno = 1
    
    imageList4Slide = nil
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

