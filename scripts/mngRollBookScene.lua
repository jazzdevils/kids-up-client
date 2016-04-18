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
local api = require("scripts.api")
local user = require("scripts.user_data")

local NAME_BAR_HEIGHT = 30
local TOP_PADDING = 10
local LEFT_PADDING = 5
local NODATA_ROW_HEIGHT = 280

--local navBar
--local nameRect
local kidsData
local pickerListSelect
local activityIndicator
local kidsTableView
local previous_scene
local selected_class_id
local selected_class_name

local strDate
local btn_selectall
local btn_unSelectall

local function onRowTouch(event)
    local row = event.row
    local index = event.target.index
    local rowData = row.params.kid_data    
    if(event.phase == "release") then
        if ( rowData ) then
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
--        img.alpha = 0
        row.img.anchorX = 0
        row.img.anchorY = 0
        row.img.width = width
        row.img.height = height
        row.img.x = x
        row.img.y = y
        row:insert(row.img)
--        transition.to(img, { alpha = 1.0 } )
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
    
    if ( not rowData ) then
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
                    if (event.isError) then
                        alignImage(row, "images/assets1/pic_photo_80x80.png", nil, 
                            row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight, rowData.sex)
                    elseif ( event.phase == "ended" ) then
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
    row.birthday = display.newText(birthdaytext, 0, 0, native.systemFontBold, 12)
    row.birthday.anchorX = 0
    row.birthday.anchorY = 0
    row.birthday:setFillColor(0, 0, 0)
    row.birthday.x = row.kid_name.x--row.kid_name.x + row.kid_name.width + LEFT_PADDING
    row.birthday.y = row.kid_name.y + row.kid_name.height + LEFT_PADDING--(row.height - row.kid_name.height) /2
    row:insert(row.birthday)
    
    row.checkedImg = display.newImageRect("images/input/radio_checked.png", 22, 22)
    row.checkedImg.anchorX = 0
    row.checkedImg.anchorY = 0
    row.checkedImg.x = row.rect.width - row.checkedImg.width - 2
    row.checkedImg.y = (row.height - row.checkedImg.height) /2
    row:insert(row.checkedImg)
    
    row.checkedImg.isVisible = rowData.checked
    
--    if(rowData.sex == __BOY_TYPE__) then
--        row.sex_icon = display.newImageRect("images/assets1/icon_boy.png", 14 , 14)
--    else
--        row.sex_icon = display.newImageRect("images/assets1/icon_girl.png", 14 , 14)
--    end
--    row.sex_icon.anchorX = 0
--    row.sex_icon.anchorY = 0 
--    row.sex_icon.x = row.rect.x + LEFT_PADDING + imageWidth - row.sex_icon.width
--    row.sex_icon.y = row.rect.y + row.rect.height - row.sex_icon.height - TOP_PADDING
--    row.sex_icon:toFront()
--    row:insert(row.sex_icon)
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
        local cnt = json_data.kids_cnt
        kidsTableView:deleteAllRows()
        
        if(cnt > 0) then
            if btn_selectall and btn_unSelectall then
                btn_selectall.isVisible = true
                btn_unSelectall.isVisible = true
            end
            for i = 1, cnt do
                if json_data.kids[i].attendance == "1" then
                    json_data.kids[i].checked = true
                else
                    json_data.kids[i].checked = false
                end
                
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
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        local selectedKidsList = {}
        selectedKidsList.names, selectedKidsList.ids, selectedKidsList.firstname, selectedKidsList.count = getCheckedList()
        if(selectedKidsList.ids == "" and selectedKidsList.count == 0) then
            utils.showMessage(language["mngRollBookScene"]["check_message"])
        else
            local p = {}
            p.center_id = user.userData.centerid
            p.date = utils.getTodayYYYYMMDD()
            p.class_id = selected_class_id
            p.kids_id_str = selectedKidsList.ids
            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
            api.check_attendance(p, 
                function()
                    activityIndicator:destroy()
                    storyboard.gotoScene(previous_scene, "slideRight", 300)
                end
            )
        end
    end
    
    return true
end

local function viewClassSelect()
    local startIndexClass = 1
    local classes = {}
    local class_label = {}
    
    if user.userData.jobType == __DIRECTOR__ then
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
        {
            align = "center",
            width = __appContentWidth__- 50,
            startIndex = startIndexClass,
            labels = class_label
        },
    }  
        
    pickerListSelect = widget.newPickerList(
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
                            pickerListSelect.isShowing = false
                        end,
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                local value = pickerListSelect.pickerWheel:getValues()
                                print(value[1].value)
                                print(value[1].index)
                                local classData = classes[value[1].index]
                                
                                if(selected_class_id and selected_class_id ~= "") then
                                    if(selected_class_id ~= classData.id) then
                                        selected_class_id = classData.id
                                        selected_class_name.text = language["mngClassKidsScene"]["short_select_class"]..classData.name 

                                        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                                        api.get_attendance_info(user.userData.centerid, strDate, selected_class_id, getDataCallback)
                                    end
                                end
                            end
                        end,
        }
    )
    pickerListSelect.isShowing = true
       
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
        label = language["mngRollBookScene"]["cancel"],
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
        label = language["mngRollBookScene"]["save"],
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
        title = language["mngRollBookScene"]["title"],
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
    
    local selectClassGroup = display.newGroup()
    local class_rect = display.newRect(group, display.contentCenterX, 0, __appContentWidth__, NAME_BAR_HEIGHT )
    class_rect.anchorX = 0
    class_rect.anchorY = 0
    class_rect.x = 0
    class_rect.y = nameRect.y + nameRect.height - 15
    selectClassGroup:insert(class_rect)
    
    if user.userData.jobType == __DIRECTOR__ then
        selectClassGroup:addEventListener("touch", 
            function(event)
                if event.phase == "ended" then
                    if(pickerListSelect and pickerListSelect.isShowing == true) then
                        pickerListSelect:closeUp()
                        pickerListSelect.isShowing = false

                        return true
                    end

                    viewClassSelect()
                end
            end 
        )
    elseif user.userData.jobType == __TEACHER__ then
        if #user.userData.ClassListOfTeacher > 1 then
            selectClassGroup:addEventListener("touch", 
                function(event)
                    if event.phase == "ended" then
                        if(pickerListSelect and pickerListSelect.isShowing == true) then
                            pickerListSelect:closeUp()
                            pickerListSelect.isShowing = false

                            return true
                        end

                        viewClassSelect()
                    end
                end 
            )
        else
            class_rect:setFillColor( 0.8, 0.8, 0.8 )
        end
    end
    selected_class_id = user.userData.classId    
    selected_class_name = display.newText(language["mngClassKidsScene"]["short_select_class"]..user.userData.className, 10, 0, native.systemFontBold, 12)
    selected_class_name.anchorX = 0
    selected_class_name.anchorY = 0
    selected_class_name.x = 10
    selected_class_name.y = class_rect.y + (class_rect.height - selected_class_name.height) *0.5
    selected_class_name:setFillColor(0)
    selectClassGroup:insert(selected_class_name)
    group:insert(selectClassGroup)
    
    local menuRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65 + nameRect.height, __appContentWidth__, NAME_BAR_HEIGHT )
    menuRect.strokeWidth = 0
--    menuRect.anchorX = 0
    menuRect.anchorY = 0
    menuRect.y = class_rect.y + class_rect.height + 4
    menuRect:setFillColor( 1, 1, 1 )
    
    local date = os.date( "*t" );
    local strYear = string.format("%04d",date.year)
    local strMonth = string.format("%02d",date.month)
    local strDay = string.format("%02d",date.day)
    local dateTag_Opt = {
        parent = group,
        text = utils.convert2LocaleDateString(strYear, strMonth, strDay).." ( "..utils.getDayOfWeek(date.year, date.month, date.day).." )",
        font = native.systemFontBold,
        fontSize = __buttonFontSize__,
        align = "left"
    }
    
    local dateLabel = display.newText(dateTag_Opt)
    dateLabel:setFillColor( 0 )
    dateLabel.anchorX = 0
    dateLabel.anchorY = 0
    dateLabel.x = 10
    dateLabel.y = menuRect.y + (menuRect.height - dateLabel.height) /2 
    
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
        label = language["mngRollBookScene"]["select_all"],
        onRelease = function(event)
                        if(event.phase == "ended") then
                            AllSelect()
                        end
                    end
    }
    btn_selectall.anchorX = 0
    btn_selectall.anchorY = 0
    btn_selectall.x = menuRect.width - (btn_selectall.width * 2) - 10
    btn_selectall.y = menuRect.y + (menuRect.height - btn_selectall.height) /2 
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
        label = language["mngRollBookScene"]["unselect_all"],
        onRelease = function(event)
                        if(event.phase == "ended") then
                            AllunSelect(true)
                        end
                    end
    }
    btn_unSelectall.anchorX = 0
    btn_unSelectall.anchorY = 0
    btn_unSelectall.x = menuRect.width - btn_unSelectall.width - 5
    btn_unSelectall.y = menuRect.y + (menuRect.height - btn_unSelectall.height) /2 
    group:insert(btn_unSelectall)
    
    kidsTableView = widget.newTableView{
        top = navBar.height + nameRect.height + menuRect.height + class_rect.height + 5,
        height = __appContentHeight__ - navBar.height - nameRect.height - menuRect.height - class_rect.height - 5,
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
    strDate = strYear..strMonth..strDay
    api.get_attendance_info(user.userData.centerid, strDate, selected_class_id, getDataCallback)
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







