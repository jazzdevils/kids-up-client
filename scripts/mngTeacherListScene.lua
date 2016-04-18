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

local NAME_BAR_HEIGHT = 30
local TOP_PADDING = 10
local LEFT_PADDING = 5
local NODATA_ROW_HEIGHT = 280

local pickerList

local activityIndicator
local teacherTableView
local previous_scene

local function clearScreen()
    if(pickerList and pickerList.isShowing == true) then
        pickerList:removeSelf()
        pickerList = nil
        
        return true
    end
end

local function viewClass(row)
    local startIndexClass = 1 --default
    local classes = {}
    local class_label = {}
    local class_cnt = #user.classList
    for i = 1, class_cnt do
        local class = {}
        class.id = user.classList[i].id
        class.name = user.classList[i].name
        classes[i] = class
        class_label[i] = user.classList[i].name
        
        if(row.params.teacher_data.class_id  == class.id) then
            startIndexClass = i
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
            pickerData = columnData,
            titleText = language["mngTeacherListScene"]["select_class"],
            okButtonText = language["mngTeacherListScene"]["ok"],
            onOKClick = function(event)
                            if(event.phase == "ended") then
                                local value = pickerList.pickerWheel:getValues()
                                local rowIndex = row.index
                                local teacher_id = row.params.teacher_data.id 
                                local classData = classes[value[1].index]
                                
                                if(row.params.teacher_data.class_id ~= classData.id) then
                                    native.showAlert(language["appTitle"], language["mngTeacherListScene"]["change_class"]
                                        , { language["mngTeacherListScene"]["yes"], language["mngTeacherListScene"]["no"]}, 
                                        function(event)
                                            if "clicked" == event.action then
                                                local i = event.index
                                                if 1 == i then
                                                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                                                    api.change_teacher_class(teacher_id, classData.id, 
                                                        function(e)
                                                            activityIndicator:destroy()
                                                            if(e.isError) then
                                                                utils.showMessage(language["common"]["wrong_connection"])
                                                            else
                                                                if(row.className) then
                                                                    row.className.text = classData.name
                                                                    row.params.teacher_data.class_id = classData.id
                                                                end
                                                            end
                                                        end
                                                    )
                                                end
                                            end    
                                        end
                                    )
                                else
                                    utils.showMessage(language["mngTeacherListScene"]["same_class"])
                                end
                            end
                        end,
        }
    )
    pickerList.isShowing = true
       
    return true
end

local function alignImage(row, filename, dir, x, y, width, height)
    local img
    if(dir) then
        img = display.newImage(row, filename, dir )
    else
        img = display.newImage(row, filename)
    end    

    if(img) then
--        img.alpha = 0
        img.anchorX = 0
        img.anchorY = 0
        img.width = width
        img.height = height
        img.x = x
        img.y = y
        
--        transition.to(img, { alpha = 1.0 } )
        row:insert(img)
    end
    
    return true
end

local function onRowRender(event)
    local row = event.row
    local index = row.index 
    local rowData = row.params.teacher_data
    
    if(rowData) then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 10, row.height - 6, 6)
        row.rect.anchorX = 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) * 0.5
        row.rect.y = (row.height - row.rect.height) * 0.5
        row:insert(row.rect )

        local imgFileName
        if(rowData.img) then
            imgFileName = rowData.img:match("([^/]+)$")         
        end

        local imageWidth = 40
        local imageHeight = 40
        if(imgFileName) then
            if(utils.fileExist(imgFileName, system.TemporaryDirectory) == true) then
                alignImage(row, imgFileName, system.TemporaryDirectory, 
                    row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight)
            else
                network.download(
                    rowData.img,
                    "GET",
                    function(event)
                        if (event.isError) then
                            alignImage(row, "images/assets1/pic_photo_80x80.png", nil, row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight)
                        elseif ( event.phase == "ended" ) then
                            alignImage(row, imgFileName, system.TemporaryDirectory, 
                            row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight) 
                        end
                    end ,
                    imgFileName,
                    system.TemporaryDirectory
                )
            end
        else
        --      default image  
            imgFileName = "images/assets1/pic_photo_80x80.png"
            alignImage(row, imgFileName, nil, row.rect.x + LEFT_PADDING, TOP_PADDING, imageWidth, imageHeight)
        end

        row.teacher_name = display.newText(rowData.name,0, 0, native.systemFontBold, 12)
        row.teacher_name.anchorX = 0
        row.teacher_name.anchorY = 0
        row.teacher_name:setFillColor(0, 0, 0)
        row.teacher_name.x = row.rect.x + LEFT_PADDING + imageWidth + LEFT_PADDING
        row.teacher_name.y = row.rect.y + TOP_PADDING--(row.height - row.kid_name.height) /2
        row:insert(row.teacher_name)
        
        local className = utils.getDisplayClassName4Teacher(rowData.class)
        row.className = display.newText(className, 0, 0, native.systemFontBold, 12)
        row.className.anchorX = 0
        row.className.anchorY = 0
        row.className:setFillColor(0, 0, 0)
        row.className.x = row.teacher_name.x--row.kid_name.x + row.kid_name.width + LEFT_PADDING
        row.className.y = row.teacher_name.y + row.teacher_name.height + LEFT_PADDING--(row.height - row.kid_name.height) /2
        row:insert(row.className)

        row.btn_changeClass = widget.newButton{
            width = 70 ,
            height = 25 ,
            left = 0,
            top = 0, 
            defaultFile = "images/button/btn_red_2_normal.png",
            overFile = "images/button/btn_red_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = 12,
            label = language["mngTeacherListScene"]["class"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                
                                local options = {
                                    effect = "fade",
                                    time = 300,
                                    params = {
                                        _row = row
                                    },
                                    isModal = true
                                }
                                storyboard.showOverlay( "scripts.classList4TeacherByDirectorScene", options ) 
                                
--                                viewClass(row)
                            end
                        end
        }
        row.btn_changeClass.anchorX = 0
        row.btn_changeClass.anchorY = 0
        row.btn_changeClass.x = row.rect.width -  (row.btn_changeClass.width * 2) --- LEFT_PADDING
        row.btn_changeClass.y = (row.height - row.btn_changeClass.height) /2
        row:insert(row.btn_changeClass)

        row.btn_off = widget.newButton{
            width = 70 ,
            height = 25 ,
            left = 0,
            top = 0, 
            defaultFile = "images/button/btn_blue_2_normal.png",
            overFile = "images/button/btn_blue_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = 12,
            label = language["mngTeacherListScene"]["off"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                
                                native.showAlert(language["appTitle"], language["mngTeacherListScene"]["change_unapproved"]
                                    , { language["mngTeacherListScene"]["yes"], language["mngTeacherListScene"]["no"]}, 
                                    function(event)
                                        if "clicked" == event.action then
                                            local i = event.index
                                            if 1 == i then
                                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                                                api.void_teacher_approval(rowData.id, 
                                                    function(e)
                                                        activityIndicator:destroy()
                                                        if(e.isError) then
                                                            utils.showMessage(language["common"]["wrong_connection"])
                                                        else
                                                            teacherTableView._view._velocity = 0
                                                            teacherTableView:deleteRow(index)
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
        row.btn_off.anchorX = 0
        row.btn_off.anchorY = 0
        row.btn_off.x = row.rect.width -  row.btn_off.width
        row.btn_off.y = row.btn_changeClass.y
        row:insert(row.btn_off)
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

local function getDataCallback(event)
    local function makeRow(json_data)
        local cnt = json_data.teacher_cnt
        if(cnt > 0) then
            for i = 1, cnt do
                teacherTableView:insertRow{
                    rowHeight = 60,
                    rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                    lineColor = { 0.5, 0.5, 0.5, 0 },
                    params = {
                        teacher_data = json_data.teachers[i],
                    }
                }
            end
        else
            teacherTableView:insertRow{
                 rowHeight = NODATA_ROW_HEIGHT,
                 rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0.5}},
                 lineColor = { 0.5, 0.5, 0.5 },
                 params = {
                    teacher_data = nil
                }
            }--아직 내용이 없다는 내용을 표시하기위한 로row
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

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(previous_scene, "slideRight", 300)
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
    
    previous_scene = storyboard.getPrevious()
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    bg:addEventListener("touch", 
        function(event)
            if(event.phase == "ended") then
                if (clearScreen() == true) then
                    return 
                end
            end
        end
    )
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mngTeacherListScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png", 
    }
--    local btn_right_opt = {
--        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
--        label = "OK",
--        onEvent = onRightButton,
--        width = 100,
--        height = 50,
--        font = native.systemFont,
--        fontSize = __buttonFontSize__,
--        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
--        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
--    }

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
        title = language["mngTeacherListScene"]["title"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
--        rightButton = btn_right_opt,
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    
    teacherTableView = widget.newTableView{
        top = navBar.height + nameRect.height + 5,
        height = __appContentHeight__ - navBar.height - nameRect.height - 5,
        width = display.contentWidth,
        maxVelocity = 1, 
        rowTouchDelay = __tableRowTouchDelay__,
        hideBackground = true,
        onRowRender = onRowRender,
--        onRowTouch = nil,--onRowTouch,
--        noLine = true,
--        listener = nil,
    }
    teacherTableView.x = display.contentWidth / 2
    group:insert(teacherTableView)   
        
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])    
    api.get_teacher_list(user.userData.centerid, getDataCallback)
--    api.get_teacher_list("16", getDataCallback)
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











