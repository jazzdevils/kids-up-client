---------------------------------------------------------------------------------
-- splashScene
-- Scene notes go here
---------------------------------------------------------------------------------
local ga = require( "scripts.googleAnalytics" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local language = getLanguage()
local widget = require("widget")
local api = require("scripts.api")
local json = require("json")
require("widgets.widget_newNavBar")

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local display_group, navBar
local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.mainScene", "slideRight", 300 ) 
    end
    
    return true
end

local function callbackListener( event )
    if ( event.isError ) then
        native.setActivityIndicator( false )
        print( "Network error!")
        local alert = native.showAlert( language["appTitle"], language["common"]["wrong_connection"], { language["common"]["alert_ok_button"]}, function() return true end )
    else
        print(event.status)
        if(event.status == 200) then
            print(event.response)
            local data = json.decode(event.response)
                
            if (data) then
                if(data.status == "OK") then
                    local alert = native.showAlert( language["appTitle"], "OK", { language["common"]["alert_ok_button"]}, function() return true end )
                    native.setActivityIndicator( false )
                else
                    native.setActivityIndicator( false )
                    local alert = native.showAlert( language["appTitle"], "NG", { language["common"]["alert_ok_button"]}, function() return true end )
                    return true
                end
            end
        end
    end
end

local function listButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_schedule_list("9", "57", "201408", callbackListener)
    end
    
    return true
end

local function detailButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_schedule_detail("9", "57", "20140812", callbackListener)
    end
    
    return true
end

local function addButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.add_schedule_data_thread("16", "70", "1", "63", "20140902", "", callbackListener)
    end
    
    return true
end

local function deleteButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_schedule_data("5", callbackListener)
    end
    
    return true
end

local function addPersonalButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            date = "20140910",
            member_id = "78",
            title = "掃除",
            detail = "家の大掃除をする日です。",
            time = ""
        }
        api.add_schedule_data(params, callbackListener)
    end
    
    return true
end

local function checkAttendanceButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            date = "20150423",
            class_id = "189",
            kids_id_str = "47,54,55"
        }
        api.check_attendance(params, callbackListener)
    end
    
    return true
end

local function attendanceInfoButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_attendance_info("16", "20140910", "189", callbackListener)
    end
    
    return true
end

local function addScheduleData2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            date = "20150323",
            class_id = "193",
            member_id = "72",
            kids_id="",
            title="掃除",
            detail="掃除",
            time=""
        }
        api.add_schedule_data2(params, callbackListener)
    end
    
    return true
end

local function addThread2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.add_schedule_data_thread2("16","71","119","1","334","20150317","", callbackListener)
    end
    
    return true
end

local function list2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_schedule_list2("16","71","119","201503", callbackListener)
    end
    
    return true
end

local function detail2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_schedule_detail2("16","71","119","20150317", callbackListener)
    end
    
    return true
end
function scene:createScene( event )
    local group = self.view
    display_group = group
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    local btn_left_opt = {
        label = language["top"]["back"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onBackButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",
    }

    navBar = widget.newNavigationBar({
        title = "Schedule Test Main",
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
    })    
    group:insert(navBar)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    local list = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list",
        onRelease = listButtonEvent
    }
    list.x = 80
    list.y = navBar.height + 30
    group:insert(list)

    local detail = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "detail",
        onRelease = detailButtonEvent
    }
    detail.x = list.x + 150
    detail.y = list.y
    group:insert(detail)

    local add = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "add",
        onRelease = addButtonEvent
    }
    add.x = 80
    add.y = list.y + 50
    group:insert(add)

    local delete = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete",
        onRelease = deleteButtonEvent
    }
    delete.x = add.x + 150
    delete.y = add.y
    group:insert(delete)
    
    local addPersonal = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "add Personal",
        onRelease = addPersonalButtonEvent
    }
    addPersonal.x = 80
    addPersonal.y = add.y + 50
    group:insert(addPersonal)
    
    local checkAttendance = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "check Attendance",
        onRelease = checkAttendanceButtonEvent
    }
    checkAttendance.x = addPersonal.x + 150
    checkAttendance.y = addPersonal.y
    group:insert(checkAttendance)
    
    local attendanceInfo = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "Attendance Info",
        onRelease = attendanceInfoButtonEvent
    }
    attendanceInfo.x = 80
    attendanceInfo.y = addPersonal.y + 50
    group:insert(attendanceInfo)
    
    local addData2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "addData2",
        onRelease = addScheduleData2ButtonEvent
    }
    addData2.x = attendanceInfo.x + 150
    addData2.y = checkAttendance.y + 50
    group:insert(addData2)
    
    local addThread2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "addThread2",
        onRelease = addThread2ButtonEvent
    }
    addThread2.x = 80
    addThread2.y = attendanceInfo.y + 50
    group:insert(addThread2)
    
    local list2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list2",
        onRelease = list2ButtonEvent
    }
    list2.x = attendanceInfo.x + 150
    list2.y = addData2.y + 50
    group:insert(list2)
    
    local detail2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "detail2",
        onRelease = detail2ButtonEvent
    }
    detail2.x = 80
    detail2.y = addThread2.y + 50
    group:insert(detail2)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
--    display:remove(group)
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
    group:removeSelf()
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

