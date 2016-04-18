---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("scripts.askApprovalMenu")
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
local PROFILE_IMAGE_SIZE_WIDTH = 60
local PROFILE_IMAGE_SIZE_HEIGHT = 68
local ROW_HEIGHT = 120
local REFRESH_ROW_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local NAVI_BAR_HEIGHT = 50
local springStart = 0
local needToReload = false
local needToPastload = false
local pullDown = nil
local reloadspinner
local reloadInProgress = false
local mngTable
local pageno = 1
local pagesize = 10
local NODATA_ROW_HEIGHT = 280
local menu
local tablespinnerImageSheet = graphics.newImageSheet( "images/etc/tablespinner.png", tablespinner:getSheet() )	
local activityIndicator
local previous_scene

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function doRowRender(row, filename, dir, animationEffect, rowData)
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    row.bg = display.newImageRect("images/bg_set/bg_frame_320x110.png", rowWidth - 10, rowHeight - 10)
    row.bg.x = rowWidth * 0.5
    row.bg.y = rowHeight * 0.5
    row:insert(row.bg)
    
    row.memberTypeRect = display.newRoundedRect(0, 0, 60, 20, 3)
    if rowData.member_type == __TEACHER__ then
        row.memberTypeRect:setFillColor( 252/255, 211/255, 135/255 )
        row.memberTypeNameLabel = display.newText( {text=language["askApprovalScene"]["member_type2"], fontSize=__textLabelFont12Size__} )
    elseif rowData.member_type == __PARENT__ then
        row.memberTypeRect:setFillColor( 255/255, 229/255, 127/255 )
        row.memberTypeNameLabel = display.newText( {text=language["askApprovalScene"]["member_type3"], fontSize=__textLabelFont12Size__} )
    end
    row.memberTypeRect.anchorX = 0
    row.memberTypeRect.x = 10
    row.memberTypeRect.anchorY = 0
    row.memberTypeRect.y = 10
    row.memberTypeRect.strokeWidth = 1
    row:insert(row.memberTypeRect)
    row.memberTypeNameLabel:setFillColor( unpack(__NAVBAR_TXT_COLOR__) )
    row.memberTypeNameLabel.x = row.memberTypeRect.x + row.memberTypeRect.width * 0.5
    row.memberTypeNameLabel.y = row.memberTypeRect.y + row.memberTypeRect.height * 0.5
    row:insert(row.memberTypeNameLabel)
    
    if dir then
        row.profileImg = display.newImageRect( filename, dir, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    else
        row.profileImg = display.newImageRect( filename, PROFILE_IMAGE_SIZE_WIDTH, PROFILE_IMAGE_SIZE_HEIGHT)
    end
    row.profileImg.anchorX = 0
    row.profileImg.x = row.memberTypeRect.x
    row.profileImg.anchorY = 0
    row.profileImg.y = row.memberTypeRect.y + row.memberTypeRect.height + 5
    row.profileImgFrame  = display.newImageRect("images/assets2/photo_frame_80x90.png", PROFILE_IMAGE_SIZE_WIDTH + 2, PROFILE_IMAGE_SIZE_HEIGHT + 2)
    row.profileImgFrame.anchorX = 0
    row.profileImgFrame.x = row.profileImg.x - 1
    row.profileImgFrame.anchorY = 0
    row.profileImgFrame.y = row.profileImg.y - 1
    if animationEffect then
        transition.to( row.profileImg, { alpha = 1.0 } )
    end
    row:insert(row.profileImg)
    row:insert(row.profileImgFrame)
    
    if rowData.member_type == __TEACHER__ then
        row.memberNameLabel = display.newText( {text = language["askApprovalScene"]["membername_label"], fontSize = __textLabelFont14Size__} )
        row.memberNameLabel:setFillColor( 0,0,0,0.3 )
        row.memberNameLabel.anchorX = 0
        row.memberNameLabel.anchorY = 0
        row.memberNameLabel.x = row.memberTypeRect.x + row.memberTypeRect.width + 10
        row.memberNameLabel.y = 10
        row:insert(row.memberNameLabel)
        row.memberName = display.newText( {text = rowData.member_name, fontSize = __textLabelFontSize__} )
        row.memberName:setFillColor( 0 )
        row.memberName.anchorX = 0
        row.memberName.anchorY = 0
        row.memberName.x = row.memberNameLabel.x + row.memberNameLabel.width + 10
        row.memberName.y = 10
        row:insert(row.memberName)
    
        row.emailLabel = display.newText( {text = language["askApprovalScene"]["email_label"], fontSize = __textLabelFont14Size__} )
        row.emailLabel:setFillColor( 0,0,0,0.3 )
        row.emailLabel.anchorX = 0
        row.emailLabel.anchorY = 0
        row.emailLabel.x = row.memberNameLabel.x
        row.emailLabel.y = row.memberNameLabel.y + row.memberNameLabel.height + 2
        row:insert(row.emailLabel)
        row.email = display.newText( {text = rowData.email, fontSize = __textLabelFont14Size__} )
        row.email:setFillColor( 0 )
        row.email.anchorX = 0
        row.email.anchorY = 0
        row.email.x = row.memberName.x
        row.email.y = row.emailLabel.y
        row:insert(row.email)
        
        row.phonenumLabel = display.newText( {text = language["askApprovalScene"]["phonenum_label"], fontSize = __textLabelFont14Size__} )
        row.phonenumLabel:setFillColor( 0,0,0,0.3 )
        row.phonenumLabel.anchorX = 0
        row.phonenumLabel.anchorY = 0
        row.phonenumLabel.x = row.memberNameLabel.x
        row.phonenumLabel.y = row.emailLabel.y + row.emailLabel.height + 2
        row:insert(row.phonenumLabel)
        row.phonenum = display.newText( {text = rowData.phonenum, fontSize = __textLabelFont14Size__} )
        row.phonenum:setFillColor( 0 )
        row.phonenum.anchorX = 0
        row.phonenum.anchorY = 0
        row.phonenum.x = row.memberName.x
        row.phonenum.y = row.phonenumLabel.y
        row:insert(row.phonenum)
        
        row.classNameLabel = display.newText( {text = language["askApprovalScene"]["classname_label"], fontSize = __textLabelFont14Size__} )
        row.classNameLabel:setFillColor( 0,0,0,0.3 )
        row.classNameLabel.anchorX = 0
        row.classNameLabel.anchorY = 0
        row.classNameLabel.x = row.memberNameLabel.x
        row.classNameLabel.y = row.phonenumLabel.y + row.phonenumLabel.height + 2
        row:insert(row.classNameLabel)
        row.className = display.newText( {text = rowData.class_name, fontSize = __textLabelFont14Size__} )
        row.className:setFillColor( 0 )
        row.className.anchorX = 0
        row.className.anchorY = 0
        row.className.x = row.memberName.x
        row.className.y = row.classNameLabel.y
        row:insert(row.className)
        
        local createTime = utils.convert2LocaleDateStringFromYYYYMMDD(rowData.createtime_ymd)
        row.createtime = display.newText( {text = createTime, fontSize = __textLabelFont12Size__} )
        row.createtime:setFillColor( 0,0,0,0.5 )
        row.createtime.anchorX = 0
        row.createtime.anchorY = 0
        row.createtime.x = rowWidth - 10 - row.createtime.width
        row.createtime.y = row.bg.height - row.createtime.height
        row:insert(row.createtime)
    elseif rowData.member_type == __PARENT__ then
        row.kidsNameLabel = display.newText( {text = language["askApprovalScene"]["membername_label"], fontSize = __textLabelFont14Size__} )
        row.kidsNameLabel:setFillColor( 0,0,0,0.3 )
        row.kidsNameLabel.anchorX = 0
        row.kidsNameLabel.anchorY = 0
        row.kidsNameLabel.x = row.memberTypeRect.x + row.memberTypeRect.width + 10
        row.kidsNameLabel.y = 10
        row:insert(row.kidsNameLabel)
        row.kidsName = display.newText( {text = rowData.kids_name, fontSize = __textLabelFontSize__} )
        row.kidsName:setFillColor( 0 )
        row.kidsName.anchorX = 0
        row.kidsName.anchorY = 0
        row.kidsName.x = row.kidsNameLabel.x + row.kidsNameLabel.width + 20
        row.kidsName.y = 10
        row:insert(row.kidsName)
        
        row.sexNameLabel = display.newText( {text = language["askApprovalScene"]["sex_label"], fontSize = __textLabelFont14Size__} )
        row.sexNameLabel:setFillColor( 0,0,0,0.3 )
        row.sexNameLabel.anchorX = 0
        row.sexNameLabel.anchorY = 0
        row.sexNameLabel.x = row.kidsNameLabel.x
        row.sexNameLabel.y = row.kidsNameLabel.y + row.kidsNameLabel.height + 2
        row:insert(row.sexNameLabel)
        local sexlang = ""
        if rowData.kids_sex == "1" then
            sexlang = language["askApprovalScene"]["boy"]
        else
            sexlang = language["askApprovalScene"]["girl"]
        end
        row.sexName = display.newText( {text = sexlang, fontSize = __textLabelFont14Size__} )
        row.sexName:setFillColor( 0 )
        row.sexName.anchorX = 0
        row.sexName.anchorY = 0
        row.sexName.x = row.kidsName.x
        row.sexName.y = row.sexNameLabel.y
        row:insert(row.sexName)
        
        row.birthdayLabel = display.newText( {text = language["askApprovalScene"]["birthday_label"], fontSize = __textLabelFont14Size__} )
        row.birthdayLabel:setFillColor( 0,0,0,0.3 )
        row.birthdayLabel.anchorX = 0
        row.birthdayLabel.anchorY = 0
        row.birthdayLabel.x = row.sexNameLabel.x
        row.birthdayLabel.y = row.sexNameLabel.y + row.sexNameLabel.height + 2
        row:insert(row.birthdayLabel)
        
        local birthDay = utils.convert2LocaleDateStringFromYYYYMMDD(rowData.kids_birthday)
        row.birthday = display.newText( {text = birthDay, fontSize = __textLabelFont14Size__} )
        row.birthday:setFillColor( 0 )
        row.birthday.anchorX = 0
        row.birthday.anchorY = 0
        row.birthday.x = row.kidsName.x
        row.birthday.y = row.birthdayLabel.y
        row:insert(row.birthday)
        
        row.classNameLabel = display.newText( {text = language["askApprovalScene"]["classname_label"], fontSize = __textLabelFont14Size__} )
        row.classNameLabel:setFillColor( 0,0,0,0.3 )
        row.classNameLabel.anchorX = 0
        row.classNameLabel.anchorY = 0
        row.classNameLabel.x = row.birthdayLabel.x
        row.classNameLabel.y = row.birthdayLabel.y + row.birthdayLabel.height + 2
        row:insert(row.classNameLabel)
        row.className = display.newText( {text = rowData.class_name, fontSize = __textLabelFont14Size__} )
        row.className:setFillColor( 0 )
        row.className.anchorX = 0
        row.className.anchorY = 0
        row.className.x = row.kidsName.x
        row.className.y = row.classNameLabel.y
        row:insert(row.className)
        
        local createTime = utils.convert2LocaleDateStringFromYYYYMMDD(rowData.createtime_ymd)
        row.createtime = display.newText( {text = createTime, fontSize = __textLabelFont12Size__} )
        row.createtime:setFillColor( 0,0,0,0.5 )
        row.createtime.anchorX = 0
        row.createtime.anchorY = 0
        row.createtime.x = rowWidth - 10 - row.createtime.width
        row.createtime.y = row.bg.height - row.createtime.height
        row:insert(row.createtime)
    end
end

local function doBlankRowRender(row)
    row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
    row:insert(row.rect)

    row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
    row.noDataimg.anchorY = 0
    row.noDataimg.x = display.contentCenterX
    row.noDataimg.y = 20
    row:insert(row.noDataimg)

    row.noData_txt = display.newText(language["common"]["there_is_nodata"], 12, 0, native.systemFont, 12)
    row.noData_txt.anchorY = 0
    row.noData_txt:setFillColor( 0 ,0 ,0 )
    row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
    row.noData_txt.x = display.contentCenterX
    row:insert(row.noData_txt)

    --[[local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    row.bg = display.newImageRect("images/bg_set/bg_frame_320x110.png", rowWidth - 10, rowHeight - 10)
    row.bg.x = rowWidth * 0.5
    row.bg.y = rowHeight * 0.5
    row:insert(row.bg)
    
    row.nodataLabel = display.newText( {text = language["common"]["there_is_nodata"], fontSize = __textLabelFont14Size__} )
    row.nodataLabel:setFillColor( 0,0,0,0.3 )
    row.nodataLabel.x = rowWidth * 0.5
    row.nodataLabel.y = rowHeight * 0.5
    row:insert(row.nodataLabel)]]--
end

local function makePullDownAndSpinner(row)
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
        reloadspinner.x = __appContentWidth__ * 0.5
        reloadspinner.y = REFRESH_ROW_HEIGHT * 0.5
    end
    row:insert(reloadspinner)
end

local function onRowRender( event )
    local row = event.row
    local index = row.index 
    
    if index == 1 then
        makePullDownAndSpinner(row)
        return true
    end
    
    if index > 1 then
        local rowData = row.params.approval_data;
        if rowData then
            if(rowData.img ~= "") then
                local filename = utils.getFileNameFromFullURL(rowData.img)
                if(utils.fileExist(filename, system.TemporaryDirectory)) then
                    doRowRender(row, filename, system.TemporaryDirectory, false, rowData)
                else
                    local function imageDownloadListener( event )
                        if ( event.isError ) then
                            --print( "Network error - download failed" )
                        elseif ( event.phase == "began" ) then
                            --print( "Progress Phase: began" )
                        elseif ( event.phase == "ended" ) then
                            if(event.response.filename and event.response.baseDirectory) then
                                doRowRender(row, event.response.filename, event.response.baseDirectory, true, rowData)
                            else
                                doRowRender(row, "images/main_menu_icons/pic_photo_80x80.png", nil, false, rowData)
                            end
                        end
                    end
                    network.download(
                        rowData.img,
                        "GET",
                        imageDownloadListener,
                        filename,
                        system.TemporaryDirectory
                    )
                end
            else
                doRowRender(row, "images/main_menu_icons/pic_photo_80x80.png", nil, false, rowData)
            end
        else
            doBlankRowRender(row)
        end
    end
end

local function resetSpinner()
    local function reloadcomplete()   
        if (reloadspinner ~= nil) and (reloadspinner.x ~= nil) then 
	    reloadspinner:stop()
            reloadspinner.alpha = 0
        end	 	   
        transition.to( pullDown, { time = 30, rotation = 0, 
            onComplete = function()	
                if (pullDown ~= nil) and (pullDown.x ~= nil) then
                    pullDown.alpha = 1
                else
                    if mngTable and mngTable:getNumRows() > 0 then
                        local row = mngTable:getRowAtIndex(1)
                        if row then
                            if pullDown then
                                pullDown = nil
                            end
                            if reloadspinner then
                                reloadspinner = nil
                            end
                            makePullDownAndSpinner(row)
                        end
                    end
                end
                reloadInProgress = false
            end
        } )
    end
    local reloadCompleteTimer = timer.performWithDelay( 1, reloadcomplete, 1 )
end

local function getDataCallback(event)
    local currArr = {}
    if mngTable:getNumRows() > 0 then
        for k = 1, mngTable:getNumRows() do
            if k > 1 then
                local r = mngTable:getRowAtIndex(k)
                if r then
                    local d = r.params.approval_data
                    if d then
                        local key = ""
                        if d.member_type == __TEACHER__ then
                            key = d.member_type.."_"..d.member_id
                            table.insert(currArr, key)
                        elseif(d.member_type == __PARENT__) then
                            key = d.member_type.."_"..d.member_id.."_"..d.kids_id
                            table.insert(currArr, key)
                        end
                    end
                end
            end
        end
    end
    local function makeRow(json_data)
        if(mngTable) then
            local cnt = json_data.approval_cnt
            if(cnt > 0) then
                if pageno == 1 then
                    mngTable:deleteAllRows()
                    mngTable:insertRow{
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } }
                    }
                    for i = 1, cnt do
                        mngTable:insertRow{
                            rowHeight = ROW_HEIGHT,
                            rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } },
                            lineColor = { 0.5, 0.5, 0.5 },
                            params = {
                                approval_data = json_data.approval[i]
                            }
                        }
                    end
                elseif pageno > 1 then
                    if mngTable:getNumRows() == 0 then
                        mngTable:insertRow{
                            rowHeight = REFRESH_ROW_HEIGHT,
                            rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } }
                        }
                    end
                    local key = ""
                    for i = 1, cnt do
                        local d = json_data.approval[i]
                        if d.member_type == __TEACHER__ then
                            key = d.member_type.."_"..d.member_id
                        elseif(d.member_type == __PARENT__) then
                            key = d.member_type.."_"..d.member_id.."_"..d.kids_id
                        end
                        local isNewFlag = true
                        for j = 1, #currArr do
                            if key == currArr[j] then
                                isNewFlag = false
                                break                            
                            end
                        end

                        if isNewFlag then
                            mngTable:insertRow{
                                rowHeight = ROW_HEIGHT,
                                rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } },
                                lineColor = { 0.5, 0.5, 0.5 },
                                params = {
                                    approval_data = d
                                }
                            }
                        end
                    end
                end
            else
                if pageno == 1 then
                    mngTable:deleteAllRows()
                    mngTable:insertRow{
                        rowHeight = REFRESH_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } }
                    }
                    mngTable:insertRow{
                        rowHeight = NODATA_ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            approval_data = nil
                        }
                    }
                end
            end
            resetSpinner()
        end
        
        table.remove(currArr)
    end
    
    if ( event.isError ) then
        print( "Network error!")
        activityIndicator:destroy()
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        activityIndicator:destroy()
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
                    makeRow(data)
                else
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage( data.message )
                end
            end
        end
    end
    return true
end

local function initFunc()
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    pageno = 1
    api.ask_approval_list(user.userData.centerid, user.userData.id, user.userData.jobType, pageno, pagesize, getDataCallback)
end

local function onRowTouch( event )
    if event.phase == "release" then
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        local id = event.row.index
        local rowData = event.target.params.approval_data
        if(id ~= 1 and rowData) then
            if (menu and menu.isShowing == true) then
                menu:hide()
                menu.isShowing = false
            else
                if(menu) then
                    menu:show()
                    menu.targetTable = mngTable
                    menu.targetRow = event.row
                    menu.initFunc = initFunc
                else
                    menu = widget.newSharingPanelForApproval()
                    menu:show()
                    menu.targetTable = mngTable
                    menu.targetRow = event.row
                    menu.initFunc = initFunc
                end
                menu.isShowing = true
            end
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
        springStart = mngTable:getContentPosition()
    elseif ( event.phase == "moved" ) and (mngTable:getContentPosition() > springStart + REFRESH_ROW_HEIGHT) then
        needToReload = true
        transition.to( pullDown, { time=100, rotation=180 } )
    elseif ( event.phase == "moved" ) and (mngTable:getContentPosition() < springStart - REFRESH_ROW_HEIGHT) then
        needToPastload = true
    elseif ( event.limitReached == true and event.phase == nil and event.direction == "down" and needToReload == true ) then
        reloadInProgress = true
        needToReload = false
        pullDown.alpha = 0
        reloadspinner.alpha = 1
        reloadspinner:start()
        pageno = 1
        api.ask_approval_list(user.userData.centerid, user.userData.id, user.userData.jobType, pageno, pagesize, getDataCallback)
    elseif ( event.limitReached == true and event.phase == nil and event.direction == "up" and needToPastload == true) then            
        reloadInProgress = true
        needToPastload = false
        pageno = pageno + 1
        api.ask_approval_list(user.userData.centerid, user.userData.id, user.userData.jobType, pageno, pagesize, getDataCallback)
   end
   return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        if (menu and menu.isShowing == true) then
            menu:hide()
            menu.isShowing = false
        end
        
        if (previous_scene == "scripts.newsScene") then
            storyboard.purgeScene(previous_scene)
        end
        storyboard.gotoScene(previous_scene, "slideRight", 300)   
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    
    previous_scene = storyboard.getPrevious()
    
    if(previous_scene == "scripts.newsScene" and event.params) then
        api.get_news_detail3(event.params.member_id, event.params.device_id, event.params.seq, user.getActiveKid_IDByAuthority(), 
            utils.IS_Demo_mode(storyboard, false),
            function(e)  end
        )
    end
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["askApprovalScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }
    
    mngTable = widget.newTableView{
        top = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT - REFRESH_ROW_HEIGHT,
        height = __appContentHeight__ - (NAVI_BAR_HEIGHT - REFRESH_ROW_HEIGHT) - NAME_BAR_HEIGHT - __statusBarHeight__,
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
    mngTable.x = display.contentCenterX
    group:insert(mngTable)
    
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
        title = language["askApprovalScene"]["notapplist"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.ask_approval_list(user.userData.centerid, user.userData.id, user.userData.jobType, pageno, pagesize, getDataCallback)
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
    pageno = 1
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

