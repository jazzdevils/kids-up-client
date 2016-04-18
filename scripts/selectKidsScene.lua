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
local sceneData = require("scripts.sceneData")
local api = require("scripts.api")
local user = require("scripts.user_data")
local lanCode = require("scripts.translatorLanguageCodes")
local userSetting = require("scripts.userSetting")

local NAME_BAR_HEIGHT = 30
local TOP_PADDING = 10
local LEFT_PADDING = 5

local pickerList
local kidsData
local activityIndicator
local kidsTableView
local previous_scene
local selected_class_id
local selected_class_name
local NODATA_ROW_HEIGHT = 280
local btn_unSelectall
local btn_Selectall

local function onRowTouch(event)
    local row = event.row
    local index = event.target.index
    local rowData = row.params.kid_data    
    if(event.phase == "release") then
        if (rowData) then
            if (rowData.checked == true) then
                rowData.checked = false
                row.checkedImg.isVisible = false
            else
                rowData.checked = true
                row.checkedImg.isVisible = true
            end
        end
    end
end

local function alignImage(row, filename, dir, x, y, width, height, sex)
    if(dir) then
        row.img = display.newImage(row, filename, dir )
    else
        row.img = display.newImage(row, filename)
    end    

    if(row.img) then
        row.img.anchorX = 0
        row.img.anchorY = 0
        row.img.width = width
        row.img.height = height
        row.img.x = x
        row.img.y = y
        row:insert(row.img)
        
        if(sex == __BOY_TYPE__) then
            row.sex_icon = display.newImageRect("images/assets1/icon_boy.png", 14 , 14)
        else
            row.sex_icon = display.newImageRect("images/assets1/icon_girl.png", 14 , 14)
        end
        row.sex_icon.anchorX = 0
        row.sex_icon.anchorY = 0 
        row.sex_icon.x = row.rect.x + LEFT_PADDING + width - row.sex_icon.width
        row.sex_icon.y = row.rect.y + row.rect.height - row.sex_icon.height - TOP_PADDING
        row:insert(row.sex_icon)    
    end
    
    return true
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    local rowData = row.params.kid_data
    print(rowData)
    
    if ( not rowData ) then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
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
        
        return true
    end
    
    row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
    row.rect.anchorX = 0
    row.rect.anchorY = 0
    row.rect.x = (row.width - row.rect.width) * 0.5
    row.rect.y = (row.height - row.rect.height) * 0.5
    row:insert(row.rect )
    
    local kidImgFileName
    if(rowData.img) then
        kidImgFileName = rowData.img:match("([^/]+)$")         
    end

    local imageWidth = 40
    local imageHeight = 40
    if(kidImgFileName) then
        if(utils.fileExist(kidImgFileName, system.TemporaryDirectory) == true) then
            alignImage(row, kidImgFileName, system.TemporaryDirectory, 
                row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight, rowData.sex)
        else
            network.download(
                rowData.img,
                "GET",
                function(event) 
                    if ( event.phase == "ended" ) then
                        alignImage(row, kidImgFileName, system.TemporaryDirectory, 
                        row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight, rowData.sex) 
                    end
                end ,
                kidImgFileName,
                system.TemporaryDirectory
            )
        end
    else
    --      default image  
        kidImgFileName = "images/assets1/pic_photo_80x80.png"
        alignImage(row, kidImgFileName, nil, 
            row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight, rowData.sex)
    end
    
    row.kid_name = display.newText(rowData.name,0, 0, native.systemFontBold, 12)
    row.kid_name.anchorX = 0
    row.kid_name.anchorY = 0
    row.kid_name:setFillColor(0, 0, 0)
    row.kid_name.x = row.rect.x + LEFT_PADDING + imageWidth + LEFT_PADDING
    row.kid_name.y = row.rect.y + TOP_PADDING--(row.height - row.kid_name.height) /2
    row:insert(row.kid_name)
    
    local birthdaytext = utils.convert2LocaleDateString(string.sub(rowData.birthday, 1, 4), string.sub(rowData.birthday, 5, 6)
            , string.sub(rowData.birthday, 7, 8))
    row.birthday = display.newText(birthdaytext,0 , 0, native.systemFontBold, 12)
    row.birthday.anchorX = 0
    row.birthday.anchorY = 0
    row.birthday:setFillColor(0, 0, 0)
    row.birthday.x = row.kid_name.x--row.kid_name.x + row.kid_name.width + LEFT_PADDING
    row.birthday.y = row.kid_name.y + row.kid_name.height + LEFT_PADDING
--    row.birthday.x = row.kid_name.x + row.kid_name.width + LEFT_PADDING
--    row.birthday.y = (row.height - row.kid_name.height) /2
    row:insert(row.birthday)
    
    row.checkedImg = display.newImageRect("images/input/radio_checked.png", 22, 22)
    row.checkedImg.anchorX = 0
    row.checkedImg.anchorY = 0
    row.checkedImg.x = row.rect.width - row.checkedImg.width - 2
    row.checkedImg.y = (row.height - row.checkedImg.height) /2
    row:insert(row.checkedImg)
    if(rowData.checked == nil) then
        rowData.checked = false
        row.checkedImg.isVisible = false
    else
        if(rowData.checked == true) then
            row.checkedImg.isVisible = true
        else
            row.checkedImg.isVisible = false
        end
    end
end

local function AllSelect()
    if(kidsData) then
        kidsTableView:deleteAllRows()
        for i = 1, kidsData.kids_cnt do
            kidsData.kids[i].checked = true
            
            kidsTableView:insertRow{
                rowHeight = 60,
                rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                lineColor = { 0.5, 0.5, 0.5, 0 },
                params = {
                    kid_data = kidsData.kids[i],
                }
            }
        end
    end
end

local function AllunSelect(needView)
    if(kidsData) then
        if (needView and needView == true) then
            kidsTableView:deleteAllRows()
            for i = 1, kidsData.kids_cnt do
                kidsData.kids[i].checked = false

                kidsTableView:insertRow{
                    rowHeight = 60,
                    rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                    lineColor = { 0.5, 0.5, 0.5, 0 },
                    params = {
                        kid_data = kidsData.kids[i],
                    }
                }
            end
        else
            for i = 1, kidsData.kids_cnt do
                kidsData.kids[i].checked = false
            end    
        end
    end
end

local function getCheckedList()
    local names = ""
    local ids = ""
    local firstname = ""
    local count = 0
    if(kidsData) then
        for i = 1, kidsData.kids_cnt do
            if(kidsData.kids[i].checked == true) then
                if(names == "" and ids == "") then
                    names = kidsData.kids[i].name
                    ids = kidsData.kids[i].id
                    firstname = kidsData.kids[i].name
                else
                    names = names..","..kidsData.kids[i].name
                    ids = ids..","..kidsData.kids[i].id
                end
                
                count = count + 1
            end
        end
    end
    
    return names, ids, firstname, count
end

local function getDataCallback(event)
    local function makeRow(json_data)
        kidsTableView:deleteAllRows()
        
        local cnt = json_data.kids_cnt
        if(cnt > 0) then
            if btn_selectall and btn_unSelectall then
                btn_selectall.isVisible = true
                btn_unSelectall.isVisible = true
            end
            for i = 1, cnt do
                kidsTableView:insertRow{
                    rowHeight = 60,
                    rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                    lineColor = { 0.5, 0.5, 0.5, 0 },
                    params = {
                        kid_data = json_data.kids[i],
                    }
                }
            end
        else
            if btn_selectall and btn_unSelectall then
                btn_selectall.isVisible = false
                btn_unSelectall.isVisible = false
            end
            kidsTableView:insertRow{
                rowHeight = NODATA_ROW_HEIGHT,
                rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                lineColor = { 0.5, 0.5, 0.5, 0 },
                params = {
                    kid_data = nil,
                }
            }
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
                    kidsData = data
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
        AllunSelect()
--        kidsTableView:reloadData()
        
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        local selectedKidsList = {}
        selectedKidsList.names, selectedKidsList.ids, selectedKidsList.firstname, selectedKidsList.count = getCheckedList()
        sceneData.addSceneDataWithUID("selectedKidsList", selectedKidsList)
        storyboard.purgeScene(previous_scene)
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end
    
    return true
end

local function viewClass()
    local startIndexClass = selected_class_id
    local classes = {}
    local class_label = {}
    
    if user.userData.jobType == __DIRECTOR__ then
        --관리자의 경우 전체 반을 대상
        local class_cnt = #user.classList 
        for i = 1, class_cnt do
            local class = {}
            class.id = user.classList[i].id
            class.name = user.classList[i].name
            classes[i] = class
            class_label[i] = user.classList[i].name

            if(class.id == selected_class_id) then
                startIndexClass = i
            end
        end
    else
        --교사의 경우 교사의 반을 대상
        local class_cnt = #user.userData.ClassListOfTeacher
        for i = 1, class_cnt do
            local class = {}
            class.id = user.userData.ClassListOfTeacher[i].id
            class.name = user.userData.ClassListOfTeacher[i].name
            classes[i] = class
            class_label[i] = user.userData.ClassListOfTeacher[i].name

            if(class.id == selected_class_id) then
                startIndexClass = i
            end
        end
    end
        
        
    local columnData = 
    {
        -- Years
        {
            align = "center",
            width = __appContentWidth__- 50,
            startIndex = startIndexClass, --1,
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
            titleText = language["selectKidsScene"]["select_class"],
--            onScroll = nil,
            okButtonText = language["selectKidsScene"]["ok"],
            onClose =   function()
                            pickerList.isShowing = false
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
--                                local obj = event.target
                                local value = pickerList.pickerWheel:getValues()
                                print(value[1].value)
                                print(value[1].index)
                                local classData = classes[value[1].index]
                                
                                selected_class_id = classData.id
                                selected_class_name.text = "> "..classData.name 
                                
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                                api.get_kids_list(user.userData.centerid, selected_class_id, getDataCallback)
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
    
    previous_scene = storyboard.getPrevious()
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["selectKidsScene"]["cancel"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_cancel_normal.png",
        overFile = "images/top_with_texts/btn_top_text_cancel_touched.png", 
    }
    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["selectKidsScene"]["ok"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
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
        font = native.systemFontBold,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    
    local navBar = widget.newNavigationBar({
        title = language["selectKidsScene"]["title"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    
    local menuRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65 + nameRect.height, __appContentWidth__, NAME_BAR_HEIGHT )
    menuRect.strokeWidth = 0
    menuRect:setFillColor( 1, 1, 1 )
    
    btn_selectall = widget.newButton{
        width = 70 ,
        height = 25 ,
        left = 0,
        top = 0, 
        defaultFile = "images/button/btn_red_2_normal.png",
        overFile = "images/button/btn_red_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = 12,
        label = language["selectKidsScene"]["select_all"],
        onRelease = function(event)
                        if(event.phase == "ended") then
                            AllSelect()
--                            kidsTableView:reloadData()
                        end
                    end
    }
    btn_selectall.anchorX = 0
    btn_selectall.anchorY = 0
    btn_selectall.x = menuRect.width - (btn_selectall.width * 2) - 10
    btn_selectall.y = navBar.height + nameRect.height + (menuRect.height - btn_selectall.height) *0.5
    group:insert(btn_selectall)
    
    btn_unSelectall = widget.newButton{
        width = 70 ,
        height = 25 ,
        left = 0,
        top = 0, 
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = 12,
        label = language["selectKidsScene"]["unselect_all"],
        onRelease = function(event)
                        if(event.phase == "ended") then
                            AllunSelect(true)
                        end
                    end
    }
    btn_unSelectall.anchorX = 0
    btn_unSelectall.anchorY = 0
    btn_unSelectall.x = menuRect.width - btn_unSelectall.width - 5
    btn_unSelectall.y = navBar.height + nameRect.height + (menuRect.height - btn_unSelectall.height) *0.5
    group:insert(btn_unSelectall)
    
    kidsTableView = widget.newTableView{
        top = navBar.height + nameRect.height + menuRect.height + 5,
        height = __appContentHeight__ - navBar.height - nameRect.height - menuRect.height - __statusBarHeight__,
        width = display.contentWidth,
        maxVelocity = 1, 
        rowTouchDelay = __tableRowTouchDelay__,
--        isLocked = true,
        hideBackground = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
--        noLine = true,
        listener = nil,
    }
    kidsTableView.x = display.contentWidth / 2
    group:insert(kidsTableView)   
        
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])    
    if (user.userData.jobType == __DIRECTOR__) then
--        원장의 경우 첫번째 클라스를 호출
        local selectClassGroup = display.newGroup()
        local class_rect = display.newRect(0, menuRect.y, btn_selectall.x, NAME_BAR_HEIGHT )
        class_rect.anchorX = 0
        class_rect.x = 0
        selectClassGroup:insert(class_rect)
        selectClassGroup:addEventListener("touch", 
            function(event)
                if event.phase == "ended" then
                    if(pickerList and pickerList.isShowing == true) then
                        pickerList:closeUp()
                        pickerList.isShowing = false

                        return true
                    end

                    viewClass()
                end
            end 
        )
        
        selected_class_id = user.classList[1].id
        selected_class_name = display.newText("> "..user.classList[1].name, 10, 0, native.systemFontBold, 12)
        selected_class_name.anchorX = 0
        selected_class_name.anchorY = 0
        selected_class_name.x = 10
        selected_class_name.y = navBar.height + nameRect.height + (menuRect.height - selected_class_name.height) *0.5
        selected_class_name:setFillColor(0)
        selectClassGroup:insert(selected_class_name)
        group:insert(selectClassGroup)
        
        api.get_kids_list(user.userData.centerid, selected_class_id, getDataCallback)
    elseif (user.userData.jobType == __TEACHER__) then
--        교사
        if #user.userData.ClassListOfTeacher > 1 then
            local selectClassGroup = display.newGroup()
            local class_rect = display.newRect(0, menuRect.y, btn_selectall.x, NAME_BAR_HEIGHT )
            class_rect.anchorX = 0
            class_rect.x = 0
            selectClassGroup:insert(class_rect)
            selectClassGroup:addEventListener("touch", 
                function(event)
                    if event.phase == "ended" then
                        if(pickerList and pickerList.isShowing == true) then
                            pickerList:closeUp()
                            pickerList.isShowing = false

                            return true
                        end

                        viewClass()
                    end
                end 
            )
            selected_class_name = display.newText("> "..user.userData.ClassListOfTeacher[1].name, 10, 0, native.systemFontBold, 12)
            selected_class_name.anchorX = 0
            selected_class_name.anchorY = 0
            selected_class_name.x = 10
            selected_class_name.y = navBar.height + nameRect.height + (menuRect.height - selected_class_name.height) *0.5
            selected_class_name:setFillColor(0)
            selectClassGroup:insert(selected_class_name)
            group:insert(selectClassGroup)
        end
        
        selected_class_id = user.userData.ClassListOfTeacher[1].id --첫번째 반의 아이디
        api.get_kids_list(user.userData.centerid, selected_class_id, getDataCallback)
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
    storyboard.returnTo = previous_scene
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
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







