
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
--local authority = require("scripts.user_authority")
--local sceneData = require("scripts.sceneData")

local ROW_HEIGHT = 85
local ROW_HEADER_HEIGHT = 100
local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local PROFILE_IMAGE_SIZE_WIDTH = 54
local PROFILE_IMAGE_SIZE_HEIGHT = 60
local LEFT_PADDING = 5

local notReadTable
local thread_type 
local thread_title
local thread_content
local thread_total_cnt
local thread_read_cnt

local activityIndicator
local thread_type
local thread_id
local previous_scene

--------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.notReadList_data
    
    if(rowData and index == 1) then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row.rect.anchorX= 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) /2
        row.rect.y = 5
        row:insert(row.rect)
            
        local notReadCnt = tonumber(thread_total_cnt) - tonumber(thread_read_cnt)    
        local notRead_txt = language["notReadListScene"]["not_read_count"]..notReadCnt
        row.notRead_txt = display.newText(notRead_txt, 0, 0, native.systemFontBold, 12)
        row.notRead_txt.anchorX = 0
        row.notRead_txt.anchorY = 0
        row.notRead_txt.x = 10
        row.notRead_txt.y = row.rect.y + (row.rect.height - row.notRead_txt.height)/2 
        row.notRead_txt:setFillColor( 0.2 )
        row:insert(row.notRead_txt)    
        
        row.sms_button = widget.newButton{
            width = 140 ,
            height = 30 ,
            left = 0,--display.contentCenterX - (155/2)  , 
            top = 0, 
            defaultFile = "images/button/btn_red_2_normal.png",
            overFile = "images/button/btn_red_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = 12,
            label = language["notReadListScene"]["all_sms"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                    
                                local telNums = {}
                                local rowDataCnt = #rowData.member
                                for i = 1, rowDataCnt do
                                    if(rowData.member[i].phonenum ~= "") then
                                        table.insert(telNums, rowData.member[i].phonenum)
                                    end
                                end
                                
                                local options
                                if(#telNums > 0) then
                                    if(thread_type == __NOTICE_THREAD_TYPE__) then
                                        options = {
                                            to = telNums,
                                            body = "- "..user.userData.centerName.." - "..thread_title.." "..language["notReadListScene"]["notice_sms"],
                                        }
                                    elseif(thread_type == __EVENT_THREAD_TYPE__) then
                                        options = {
                                            to = telNums,
                                            body = "- "..user.userData.centerName.." - "..thread_title.." "..language["notReadListScene"]["event_sms"],
                                        }
                                    end

                                    native.showPopup("sms", options)
                                end
                            end
                        end
        }
        row.sms_button.anchorX = 0
        row.sms_button.anchorY = 0
        row.sms_button.x = row.rect.width - row.sms_button.width 
        row.sms_button.y = (row.rect.height / 2) - row.sms_button.height--row.rect.y + (row.rect.height - row.sms_button.height) /2
        row:insert(row.sms_button)
        
--        row.email_button = widget.newButton{
--            width = 140 ,
--            height = 30 ,
--            left = 0,--display.contentCenterX - (155/2)  , 
--            top = 0, 
--            defaultFile = "images/button/btn_red_2_normal.png",
--            overFile = "images/button/btn_red_2_touched.png",
--            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
--            emboss = true,
--            fontSize = 12,
--            label = language["notReadListScene"]["all_email"],
--            onRelease = function(event)
--                            if(event.phase == "ended") then
--                                local emailList = ""
--                                local rowDataCnt = #rowData.member
--                                for i = 1, rowDataCnt do
--                                    if(rowData.member[i].phonenum ~= "") then
--                                        if(i == 1) then
--                                            emailList = rowData.member[i].email
--                                        else
--                                            emailList = emailList..","..rowData.member[i].email
--                                        end
--                                    end
--                                end
--                                
--                                local options
--                                if(emailList ~= "") then
--                                    if(thread_type == __NOTICE_THREAD_TYPE__) then
--                                        options = {
--                                            to = {emailList},
----                                            subject = "- "..user.userData.centerName.." - "..thread_title.." "..language["notReadListScene"]["notice_sms"],
--                                            subject = "- "..user.userData.centerName.." - "..language["notReadListScene"]["notice_sms"],
--                                            body = thread_content
--                                        }
--                                    elseif(thread_type == __EVENT_THREAD_TYPE__) then
--                                        options = {
--                                            to = {emailList},
----                                            subject = "- "..user.userData.centerName.." - "..thread_title.." "..language["notReadListScene"]["event_sms"],
--                                            subject = "- "..user.userData.centerName.." - "..language["notReadListScene"]["event_sms"],
--                                            body = thread_content
--                                        }
--                                    end
--
--                                    native.showPopup("mail", options)
--                                end
--                            end
--                        end
--        }
--        row.email_button.anchorX = 0
--        row.email_button.anchorY = 0
--        row.email_button.x = row.rect.width - row.email_button.width 
--        row.email_button.y = (row.rect.height / 2) - row.email_button.height--row.rect.y + (row.rect.height - row.sms_button.height) /2
--        row:insert(row.email_button)
        
        row.push_button = widget.newButton{
            width = 140 ,
            height = 30 ,
            left = 0,--display.contentCenterX - (155/2)  , 
            top = 0, 
            defaultFile = "images/button/btn_blue_2_normal.png",
            overFile = "images/button/btn_blue_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = 12,
            label = language["notReadListScene"]["all_push"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["push"])
                                local function getDataCallBack(event)
                                    if(activityIndicator) then
                                        activityIndicator:destroy()
                                    end
                                    if ( event.isError ) then
                                        utils.showMessage(language["common"]["wrong_connection"])
                                    else
                                        utils.showMessage(language["notReadListScene"]["finish_push"])    
                                    end 
                                end
                                
                                if(thread_type == __NOTICE_THREAD_TYPE__) then
                                    api.push_not_read_notice_member_list(thread_id, getDataCallBack)
                                elseif(thread_type == __EVENT_THREAD_TYPE__) then
                                    api.push_not_read_event_member_list(thread_id, getDataCallBack)
                                end
                            end
                        end
        }
        row.push_button.anchorX = 0
        row.push_button.anchorY = 0
        row.push_button.x = row.sms_button.x
        row.push_button.y = row.sms_button.y + row.sms_button.height + 5
        row:insert(row.push_button)
    elseif(rowData and index > 1) then
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 5, 6)
        row.rect.anchorX= 0
        row.rect.anchorY = 0
        row.rect.x = (row.width - row.rect.width) /2
        row.rect.y = 0
        row:insert(row.rect)
        
        row.profileImageFrame = display.newImageRect(row, "images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 4, PROFILE_IMAGE_SIZE_HEIGHT + 4)
        row.profileImageFrame.anchorX = 0
        row.profileImageFrame.anchorY = 0
        row.profileImageFrame.x = row.rect.x + LEFT_PADDING
        row.profileImageFrame.y = row.rect.y + (row.rect.height - row.profileImageFrame.height) * 0.5 
        row:insert(row.profileImageFrame)
        
        local profilename = rowData.kids_img:match("([^/]+)$")  
        if(profilename) then
            if(utils.fileExist(profilename, system.TemporaryDirectory) == true) then
                row.profileImage = display.newImage(profilename, system.TemporaryDirectory)
                row.profileImage.width = PROFILE_IMAGE_SIZE_WIDTH
                row.profileImage.height = PROFILE_IMAGE_SIZE_HEIGHT
                row.profileImage.anchorX = 0
                row.profileImage.anchorY = 0
                row.profileImage.x = row.profileImageFrame.x + 2
                row.profileImage.y = row.profileImageFrame.y + 2
                row:insert(row.profileImage)
                
                if(rowData.kids_sex == __BOY_TYPE__) then
                    row.sex_icon = display.newImageRect("images/assets1/icon_boy.png", 14 , 14)
                else
                    row.sex_icon = display.newImageRect("images/assets1/icon_girl.png", 14 , 14)
                end
                row.sex_icon.anchorX = 0
                row.sex_icon.anchorY = 0 
                row.sex_icon.x = row.profileImage.x + PROFILE_IMAGE_SIZE_WIDTH - row.sex_icon.width
                row.sex_icon.y = row.profileImage.y + PROFILE_IMAGE_SIZE_HEIGHT - row.sex_icon.height 
                row:insert(row.sex_icon)    
            else
                network.download(
                    rowData.kids_img,
                    "GET",
                    function(event)
                        if (event.isError) then
                            
                        elseif ( event.phase == "ended" ) then
                            if(utils.fileExist(profilename, system.TemporaryDirectory) == true) then
                                row.profileImage = display.newImage(profilename, system.TemporaryDirectory)
                                row.profileImage.width = PROFILE_IMAGE_SIZE_WIDTH
                                row.profileImage.height = PROFILE_IMAGE_SIZE_HEIGHT
                                row.profileImage.anchorX = 0
                                row.profileImage.anchorY = 0
                                row.profileImage.x = row.profileImageFrame.x + 2
                                row.profileImage.y = row.profileImageFrame.y + 2    
                                row:insert(row.profileImage)
                                
                                if(rowData.kids_sex == __BOY_TYPE__) then
                                    row.sex_icon = display.newImageRect("images/assets1/icon_boy.png", 14 , 14)
                                else
                                    row.sex_icon = display.newImageRect("images/assets1/icon_girl.png", 14 , 14)
                                end
                                row.sex_icon.anchorX = 0
                                row.sex_icon.anchorY = 0 
                                row.sex_icon.x = row.profileImage.x + PROFILE_IMAGE_SIZE_WIDTH - row.sex_icon.width
                                row.sex_icon.y = row.profileImage.y + PROFILE_IMAGE_SIZE_HEIGHT - row.sex_icon.height 
                                row:insert(row.sex_icon)    
                            end
                        end
                    end ,
                    profilename,
                    system.TemporaryDirectory
                )
            end
        else
            row.profileImage = display.newImage("images/assets1/pic_photo_80x90.png")
            local scalePoint = PROFILE_IMAGE_SIZE_WIDTH / row.profileImage.width
            row.profileImage.width = row.profileImage.width * scalePoint
            row.profileImage.height = row.profileImage.height * scalePoint
            row.profileImage.anchorX = 0
            row.profileImage.anchorY = 0
            row.profileImage.x = row.profileImageFrame.x + 2
            row.profileImage.y = row.profileImageFrame.y + 2
            row:insert(row.profileImage)
            
            if(rowData.kids_sex == __BOY_TYPE__) then
                row.sex_icon = display.newImageRect("images/assets1/icon_boy.png", 14 , 14)
            else
                row.sex_icon = display.newImageRect("images/assets1/icon_girl.png", 14 , 14)
            end
            row.sex_icon.anchorX = 0
            row.sex_icon.anchorY = 0 
            row.sex_icon.x = row.profileImage.x + PROFILE_IMAGE_SIZE_WIDTH - row.sex_icon.width
            row.sex_icon.y = row.profileImage.y + PROFILE_IMAGE_SIZE_HEIGHT - row.sex_icon.height 
            row:insert(row.sex_icon)    
        end
        
        row.kidName = display.newText(rowData.kids_name, 0, 0, native.systemFont, __textLabelFont12Size__)
        row.kidName.anchorX = 0
        row.kidName.anchorY = 0
        row.kidName.x = row.profileImageFrame.x + row.profileImageFrame.width + 10
        row.kidName.y = row.profileImageFrame.y 
        row.kidName:setFillColor( 0.2 )
        row:insert(row.kidName)
        
        row.className = display.newText(rowData.class_name, 0, 0, native.systemFont, __textLabelFont12Size__)
        row.className.anchorX = 0
        row.className.anchorY = 0
        row.className.x = row.kidName.x
        row.className.y = row.kidName.y + row.kidName.height + 1
        row.className:setFillColor( 0.2 )
        row:insert(row.className)
        
        row.memberName = display.newText("("..rowData.member_name..")", 0, 0, native.systemFont, __textLabelFont12Size__)
        row.memberName.anchorX = 0
        row.memberName.anchorY = 0
        row.memberName.x = row.className.x
        row.memberName.y = row.className.y + row.className.height + 1
        row.memberName:setFillColor( 0.2 )
        row:insert(row.memberName)
        
        row.phoneNum = display.newText(rowData.phonenum, 0, 0, native.systemFont, __textLabelFont12Size__)
        row.phoneNum.anchorX = 0
        row.phoneNum.anchorY = 0
        row.phoneNum.x = row.memberName.x
        row.phoneNum.y = row.memberName.y + row.memberName.height + 1
        row.phoneNum:setFillColor( 0.2 )
        row:insert(row.phoneNum)
        
        row.sms_button = widget.newButton{
            width = 60 ,
            height = 30 ,
            left = 0,--display.contentCenterX - (155/2)  , 
            top = 0, 
            defaultFile = "images/button/btn_red_2_normal.png",
            overFile = "images/button/btn_red_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = 12,
            label = language["notReadListScene"]["sms"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                
                                if (rowData.phonenum ~= "") then
                                    local telNums = {}
                                    table.insert(telNums, rowData.phonenum)
                                    
                                    local options
                                    if(thread_type == __NOTICE_THREAD_TYPE__) then
                                        options = {
                                            to = telNums,
                                            body = "- "..user.userData.centerName.." - "..thread_title.." "..language["notReadListScene"]["notice_sms"],
                                        }
                                    elseif(thread_type == __EVENT_THREAD_TYPE__) then
                                        options = {
                                            to = telNums,
                                            body = "- "..user.userData.centerName.." - "..thread_title.." "..language["notReadListScene"]["event_sms"],
                                        }
                                    end

                                    native.showPopup("sms", options)
                                end
                            end
                        end
        }
        row.sms_button.anchorX = 0
        row.sms_button.anchorY = 0
        row.sms_button.x = row.rect.width - row.sms_button.width 
        row.sms_button.y = (row.rect.height / 2) - row.sms_button.height --row.sms_button.height/2
        row:insert(row.sms_button)
        
        row.tel_button = widget.newButton{
            width = 60 ,
            height = 30 ,
            left = 0,--display.contentCenterX - (155/2)  , 
            top = 0, 
            defaultFile = "images/button/btn_blue_2_normal.png",
            overFile = "images/button/btn_blue_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = 12,
            label = language["notReadListScene"]["do_phone"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                
                                native.showAlert(language["appTitle"], language["notReadListScene"]["call_question"]
                                    , { language["notReadListScene"]["yes"], language["notReadListScene"]["no"]}, 
                                    function(event)
                                        if "clicked" == event.action then
                                            local i = event.index
                                            if 1 == i then
                                                local result = system.openURL( "tel:"..rowData.phonenum )
                                                print(result)
                                            end
                                        end    
                                    end
                                )
                            end
                        end
        }
        row.tel_button.anchorX = 0
        row.tel_button.anchorY = 0
        row.tel_button.x = row.sms_button.x
        row.tel_button.y = row.sms_button.y + row.sms_button.height + 3
        row:insert(row.tel_button)
    end
end
        
local function getDataCallback(event)
    local function makeRow(json_data)
        if(notReadTable) then
            local cnt = json_data.member_cnt
            if(cnt > 0) then
                notReadTable:insertRow{
                    rowHeight = ROW_HEADER_HEIGHT,
                    rowColor = {  default = { 1, 1, 1,0 }, over = { 1, 1, 1, 0}},
                    lineColor = { 0.5, 0.5, 0.5 },
                    params = {
                        notReadList_data = json_data,
                    }
                }
                
                for i = 1, cnt do
                    notReadTable:insertRow{
                        rowHeight = ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1,0 }, over = { 1, 1, 1, 0}},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            notReadList_data = json_data.member[i],
                        }
                    }
                end
                return true
            end
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

local function onRowTouch( event )
    if event.phase == "release" then
        local id = event.row.index
        local rowData = event.target.params.notice_data
    end    
    
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene(previous_scene, "slideRight", 300)
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
--        storyboard.isAction = true
--        storyboard.gotoScene("scripts.noticeWriteScene" , "slideLeft", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    --__NOTICE_THREAD_TYPE__      = "1"
    --__MESSAGE_THREAD_TYPE__     = "2"
    --__EVENT_THREAD_TYPE__      = "3"
    thread_type = event.params.thread_type
    thread_id = event.params.thread_id
    thread_title = event.params.thread_title
    thread_content = event.params.thread_content
    thread_total_cnt = event.params.thread_total_cnt
    thread_read_cnt = event.params.thread_read_cnt
    previous_scene = event.params.previous_scene
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["notReadListScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }

    notReadTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT,
	height = __appContentHeight__ - NAVI_BAR_HEIGHT - NAME_BAR_HEIGHT - __statusBarHeight__ ,
        width = __appContentWidth__,
	maxVelocity = 1, 
        backgroundColor = { 0.9, 0.9, 0.9, 0},
	noLines = true,
        hideBackground = true,    
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
	onRowRender = onRowRender,
--	onRowTouch = nil,
	listener = nil
    }
    notReadTable.x = display.contentCenterX
    group:insert(notReadTable)   
    
    local navBar = widget.newNavigationBar({
        title = language["notReadListScene"]["title"],
--        backgroundColor = { 0.96, 0.62, 0.34 },
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
--        includeStatusBar = true
    })
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
    if(thread_type == __NOTICE_THREAD_TYPE__) then
        api.get_memberlist_notread_notice(thread_id, getDataCallback)
    elseif(thread_type == __EVENT_THREAD_TYPE__) then
        api.get_memberlist_notread_event(thread_id, getDataCallback)
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


