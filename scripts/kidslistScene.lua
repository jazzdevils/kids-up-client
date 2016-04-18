---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.widget_sharePanel")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
local sceneData = require("scripts.sceneData")
local api = require("scripts.api")
local userSetting = require("scripts.userSetting")

local ROW_HEIGHT = 140
local NAVI_BAR_HEIGHT = 50
local PROFILE_IMAGE_SIZE_WIDTH = 80
local PROFILE_IMAGE_SIZE_HEIGHT = 90
local kidsListTable
local sharePanel
local ACTIVE_KID_ROW_COLOR = __activeKidListColor__
local IN_ACTIVE_KID_ROW_COLOR = {0.8, 0.8, 0.8, 0}
local activityIndicator

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local function onRowTouch( event )
    if event.phase == "tap" or event.phase == "release" then
        local row = event.target
        local rowData = row.params.rowData
        
        local function onComplete( event )
            if "clicked" == event.action then
                local idx = event.index
                if 1 == idx then
                    local function activateCallback( event )
                        if ( event.isError ) then
                            activityIndicator:destroy()
                            print( "Network error!")
                            utils.showMessage( language["common"]["wrong_connection"] )
                        else
                            print(event.status)
                            if(event.status == 200) then
                                local data = json.decode(event.response)

                                if (data) then
                                    if(data.status == "OK") then
                                        user.userData.centerid = data.member_center_id
                                        user.userData.classId = data.member_class_id
                                        user.userData.profileImage = data.member_img
                                        
                                        userSetting.settings.activeKidID = rowData.id --선택한 아이 파일에 저장
                                        userSetting.saveSetting()
                                        
                                        user.setActiveKid(rowData.id)
                                        for i = 1, kidsListTable:getNumRows() do
                                            if i == row.index then
                                                kidsListTable._view._rows[i]._rowColor.default = ACTIVE_KID_ROW_COLOR
                                                kidsListTable._view._rows[i]._rowColor.over = ACTIVE_KID_ROW_COLOR
                                            else
                                                kidsListTable._view._rows[i]._rowColor.default = IN_ACTIVE_KID_ROW_COLOR
                                                kidsListTable._view._rows[i]._rowColor.over = IN_ACTIVE_KID_ROW_COLOR
                                            end;
                                        end

                                        kidsListTable:reloadData()
                                        activityIndicator:destroy()
                                    else
                                        activityIndicator:destroy()
                                        utils.showMessage( data.message )
                                        return true
                                    end
                                end
                            end
                        end
                    end
                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                    api.activate_kids(user.userData.id, rowData.id, activateCallback)
                end
            end
        end
        if rowData.approval_state == "0" then
            utils.showMessage(string.gsub(language["kidslistScene"]["reason_for_cannot_acitvate"], "__KIDS__", rowData.name))
        else
            if rowData.active == "0" then
                native.showAlert(language["appTitle"], string.gsub(language["kidslistScene"]["do_acitve_kid"], "__KIDS__", rowData.name), { language["kidslistScene"]["confirm"], language["kidslistScene"]["cancel"] }, onComplete )
            end
        end
    end    
        
    return true
end 

local function doRowRender(row, filename, dir, animationEffect, rowData, onlyProfileImage)
    if(row.profileImage) then
        row.profileImage:removeSelf()
        row.profileImage = nil
    end
    
    if dir then
        row.profileImage = display.newImageRect( filename, dir, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    else
        row.profileImage = display.newImageRect( filename, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    end
    if animationEffect then
        transition.to( row.profileImg, { alpha = 1.0 } )
    end
    
    row.profileImage.anchorX = 0
    row.profileImage.anchorY = 0
    row.profileImage.x = 20
    row.profileImage.y = (row.height - PROFILE_IMAGE_SIZE_HEIGHT )/2
    row.profileImage.kidData = rowData
    row:insert(row.profileImage)
    
    if onlyProfileImage == true then
        return true
    end
    
    row.profileImageFrame = display.newImageRect(row, "images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 4, PROFILE_IMAGE_SIZE_HEIGHT + 4)
    row.profileImageFrame.anchorX = 0
    row.profileImageFrame.anchorY = 0
    row.profileImageFrame.x = row.profileImage.x - 2
    row.profileImageFrame.y = row.profileImage.y - 2
    row:insert(row.profileImageFrame)
    
    if(rowData.sex == __BOY_TYPE__) then
        row.icon_sex = display.newImageRect("images/assets1/icon_boy.png", 18 , 18)
    else
        row.icon_sex = display.newImageRect("images/assets1/icon_girl.png", 18 , 18)
    end
    row.icon_sex.anchorX = 0
    row.icon_sex.anchorY = 0
    row.icon_sex.x = row.profileImage.x + row.profileImage.width - row.icon_sex.width - 2
    row.icon_sex.y = row.profileImage.y + row.profileImage.height - row.icon_sex.height - 2
    row.icon_sex:toFront()
    row:insert(row.icon_sex)
    
    row.kidName = display.newText(rowData.name, 0, 0, native.systemFontBold, __textLabelFontSize__)
    row.kidName.anchorX = 0
    row.kidName.anchorY = 0
    row.kidName.x = row.profileImage.x + row.profileImage.contentWidth + 10
    row.kidName.y = row.profileImage.y --+ 10
    row.kidName:setFillColor( 0.2 )
    row:insert(row.kidName)
    
    local tmpBirthdayTxt = utils.convert2LocaleDateString(string.sub(rowData.birthday, 1, 4), string.sub(rowData.birthday, 5, 6)
            , string.sub(rowData.birthday, 7, 8))
    row.kidBirthday = display.newText(tmpBirthdayTxt, 0, 0, native.systemFontBold, __textLabelFont12Size__)
    row.kidBirthday.anchorX = 0
    row.kidBirthday.anchorY = 0
    row.kidBirthday.x = row.kidName.x
    row.kidBirthday.y = row.kidName.y + row.kidName.contentHeight + 4
    row.kidBirthday:setFillColor( 0 )
    row:insert(row.kidBirthday)
    
    local centerClassName_text 
    if(rowData.center_id and rowData.center_id ~= "") then
        if rowData.class_name and rowData.class_name ~= "" then
            centerClassName_text  = rowData.center_name.." ( "..rowData.class_name.." )"
        else
            centerClassName_text  = rowData.center_name.." ( )"
        end
        
        row.kidCenterName = display.newText(centerClassName_text, 0, 0, native.systemFontBold, __textLabelFont12Size__)
        row.kidCenterName:setFillColor( 0 )
    else
        centerClassName_text = language["kidslistScene"]["not_existed_in_facility"]
        row.kidCenterName = display.newText(centerClassName_text, 0, 0, native.systemFontBold, __textLabelFont12Size__)
        row.kidCenterName:setFillColor( 1, 0, 0 )
    end
    row.kidCenterName.anchorX = 0
    row.kidCenterName.anchorY = 0
    row.kidCenterName.x = row.kidName.x
    row.kidCenterName.y = row.kidBirthday.y + row.kidBirthday.contentHeight + 4
    row:insert(row.kidCenterName)
    
    if(rowData.active == "1") then
        row.activeKidIcon = display.newImageRect(row, "images/input/radio_checked.png", 30, 30)
        row.activeKidIcon.anchorX = 0
        row.activeKidIcon.anchorY = 0
        row.activeKidIcon.x = row.width - row.activeKidIcon.width - 10
        row.activeKidIcon.y = row.kidName.y
        row:insert(row.activeKidIcon)
    end
    
    local function onProfileEditButton(event)
        if (sharePanel and sharePanel.isShowing == true) then
            sharePanel:hide()
            sharePanel.isShowing = false
            
            return true
        else
            sceneData.addSceneData("scripts.kidslistScene", "scripts.kidInfoScene", rowData)
            storyboard.purgeScene("scripts.kidInfoScene")
            storyboard.gotoScene("scripts.kidInfoScene", { effect="crossFade", time=300})
        end
        
        return
    end
    
    row.profileEditButton = widget.newButton
    {
        left = 15,
        top = display.contentHeight - 70,
        width = 130,
        height = 30,
        font = native.systemFont,
        fontSize = 12,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        label = language["kidslistScene"]["kid_info_update"],
        onRelease = onProfileEditButton,
    }
    row.profileEditButton.anchorX = 0
    row.profileEditButton.anchorY = 0
    row.profileEditButton.x = row.kidName.x
    row.profileEditButton.y = row.kidCenterName.y + row.kidCenterName.height + 5
        
    row:insert(row.profileEditButton)
end

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    local rowData = row.params.rowData
    if(rowData.profileImage ~= "") then
        if(utils.fileExist(rowData.profileImage, system.DocumentsDirectory) == true) then
            doRowRender(row, rowData.profileImage, system.DocumentsDirectory, false, rowData)
        else
            doRowRender(row, "images/main_menu_icons/pic_photo_80x80.png", nil, false, rowData, false)
            
            local function imageDownloadListener( event )
                if ( event.isError ) then
                    --print( "Network error - download failed" )
                    doRowRender(row, "images/main_menu_icons/pic_photo_80x80.png", nil, false, rowData, true)
                elseif ( event.phase == "began" ) then
                    --print( "Progress Phase: began" )
                elseif ( event.phase == "ended" ) then
                    if(event.response.filename and event.response.baseDirectory) then
                        doRowRender(row, event.response.filename, event.response.baseDirectory, false, rowData, true)
                    end
                end
            end
            network.download(
                rowData.img,
                "GET",
                imageDownloadListener,
                rowData.profileImage,
                system.DocumentsDirectory
            )
        end
    else
        doRowRender(row, "images/main_menu_icons/pic_photo_80x80.png", nil, false, rowData)
    end
end

local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene(__DEFAULT_HOMESCENE_NAME__)
        storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "slideRight", 300)
    end
    
    return true
end

local function onAddButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene("scripts.kidAddScene")
        storyboard.gotoScene("scripts.kidAddScene", "slideLeft", 300)
    end
    
    return true
end

local function scrollListener( event )
--    if ( event.phase == "began" ) then
--        print("scroll began")
--    elseif ( event.phase == "moved" ) then -- and (event.target.parent.parent:getContentPosition( ) > springStart + REFRESH_ROW_HEIGHT) then
--        print("scroll moved")
--    end    
--   
--   return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["kidInfoScene"]["button_return"],
        onEvent = onBackButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }

    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["kidInfoScene"]["button_add"],
        onEvent = onAddButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",    
    }

    kidsListTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT,
	height = __appContentHeight__ - NAVI_BAR_HEIGHT - __statusBarHeight__ ,
        width = __appContentWidth__,
	maxVelocity = 1, 
--        maskFile = myMask,
        backgroundColor = { 0.9, 0.9, 0.9, 0},
	noLines = true,
        hideBackground = true,
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
	listener = nil,--scrollListener
    }
    kidsListTable.x = display.contentWidth / 2
    group:insert(kidsListTable)  
--    kidsListTable.strokeWidth = 5
--    kidsListTable.setStrokeColor(0,0,0)
    
    local kidsCount = #user.kidsList
    for i = 1, kidsCount do
        local rowColor = {  default = {1, 1, 1, 0}, over = {1, 1, 1, 0}}
        if user.kidsList[i].active == "1" then
            rowColor = {  default = ACTIVE_KID_ROW_COLOR, over = ACTIVE_KID_ROW_COLOR}
        end
        kidsListTable:insertRow{
            rowHeight = ROW_HEIGHT,
            rowColor = rowColor,
            lineColor = { 0.5, 0.5, 0.5 },
            params = {
                rowData = user.kidsList[i]
            }
        }
    end
    
    local navBar = widget.newNavigationBar({
        title = language["kidslistScene"]["title_bar"],
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
    
    if (sharePanel) then
        sharePanel.isShowing = false
        sharePanel:hide()
    end
    
--    display.remove(sharePanel)
--    sharePanel = nil
    
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
--    local rowCount = kidsListTable:getNumRows()
--    for i=1, rowCount do
--        local row = kidsListTable:getRowAtIndex(i)
--        if(row) then
--            row.profileImage:removeEventListener("touch", onKidProfileImageTap)
--        end
--    end
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

