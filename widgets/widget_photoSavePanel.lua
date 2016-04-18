require("scripts.commonSettings")
require("widgets.activityIndicator")

local widget = require( "widget" )
local sceneData = require("scripts.sceneData")
local api = require("scripts.api")
local json = require("json")
local language = getLanguage()
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")

local activityIndicator

function widget.newPanel( options )
    local customOptions = options or {}
    local opt = {}
    opt.location = customOptions.location or "top"
    local default_width, default_height
	 
    if ( opt.location == "top" or opt.location == "bottom" ) then
        default_width = display.contentWidth
        default_height = display.contentHeight * 0.33
    else
        default_width = display.contentWidth * 0.33
        default_height = display.contentHeight
    end
    opt.width = customOptions.width or default_width
    opt.height = customOptions.height or default_height
    opt.speed = customOptions.speed or 500
    opt.inEasing = customOptions.inEasing or easing.linear
    opt.outEasing = customOptions.outEasing or easing.linear
	 
    if ( customOptions.onComplete and type(customOptions.onComplete) == "function" ) then
        opt.listener = customOptions.onComplete
    else 
        opt.listener = nil
    end
    
    local rect = display.newRect( display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__)
    rect:setFillColor(0, 0, 0, 0.5)
--    
    local container = display.newContainer( opt.width , opt.height )
--    
    local function onRectTouch(event)
        print("onRectTouch : " .. event.phase)
        if(event.phase == "began") then
        
        elseif (event.phase == "ended") then
            container.isShowing = false
            container:hide()
        end
        
        return true
    end
    rect:addEventListener("touch", onRectTouch)
    
    if ( opt.location == "left" ) then
        container.anchorX = 1.0
        container.x = display.screenOriginX
        container.anchorY = 0.5
        container.y = display.contentCenterY
    elseif ( opt.location == "right" ) then
        container.anchorX = 0.0
        container.x = display.actualContentWidth
        container.anchorY = 0.5
        container.y = display.contentCenterY
    elseif ( opt.location == "top" ) then
        container.anchorX = 0.5
        container.x = display.contentCenterX
        container.anchorY = 1.0
        container.y = display.screenOriginY
    else
        container.anchorX = 0.5
        container.x = display.contentCenterX
        container.anchorY = 0.0
        container.y = display.actualContentHeight
    end
    
    function container:show()
        local options = {
            time = opt.speed,
            transition = opt.inEasing
        }
        if ( opt.listener ) then
            options.onComplete = opt.listener
            self.completeState = "shown"
        end
        if ( opt.location == "top" ) then
            options.y = display.screenOriginY + opt.height
        elseif ( opt.location == "bottom" ) then
            options.y = display.actualContentHeight - opt.height
        elseif ( opt.location == "left" ) then
            options.x = display.screenOriginX + opt.width
        else
            options.x = display.actualContentWidth - opt.width
        end 
        transition.to( self, options )
        
        rect.isVisible = true
        rect.isHitTestable = true
    end
	 
    function container:hide()
        local options = {
            time = opt.speed,
            transition = opt.outEasing
        }
        if ( opt.listener ) then
            options.onComplete = opt.listener
            self.completeState = "hidden"
        end
        if ( opt.location == "top" ) then
            options.y = display.screenOriginY
        elseif ( opt.location == "bottom" ) then
            options.y = display.actualContentHeight
        elseif ( opt.location == "left" ) then
            options.x = display.screenOriginX
        else
            options.x = display.actualContentWidth
        end 
        transition.to( self, options )
        
        timer.performWithDelay(opt.speed, function() rect.isVisible = false rect.isHitTestable = false end)
    end
	 
    return container
end

function widget.newSharingPanelForSlide()
    local function onRowRender( event )
        local row = event.row
        local id = row.index
        local params = event.row.params
        local icon = params.image or nil

        if row.isCategory then
            row.text = display.newText("", 0, 0, native.systemFont, 14)
            row.text:setFillColor( 0.67 )
            row.text.x = display.contentCenterX
            row.text.y = row.contentHeight * 0.5
            row:insert(row.text)
        else
            if(icon) then
                row.icon = display.newImageRect(row, icon, 30, 30)
                row.icon.anchorX = 0
                row.icon.anchorY = 0
                row.icon.x = 20
                row.icon.y = (row.contentHeight - 30) /2
                row:insert(row.icon)
            end
            
            row.text = display.newText(params.label, 0, 0, native.systemFont, 18)
            row.text:setFillColor( 0.5, 0.5, 1.0 )
            row.text.x = display.contentCenterX
            row.text.y = row.contentHeight/2
            row:insert(row.text)
        end

    end
    
    local function tableViewListener(event)
        local phase = event.phase
        local row   = event.target

        if phase == "began" and not row.selected then
            row.selected = true
        elseif phase == "ended" then
            row.selected = false
            
            local function cancelPanel(parent)
                local myPanel = parent
                myPanel:hide() 
                myPanel.isShowing = false

                return true
            end
                        
            local service = row.params.service
            local oData = sceneData.getSceneDataWithUID("selectedImage")
            local selectedImageName = oData[1] --source image file name
            local selectedImagePath = oData[2] --source image file path
            local selectedImageScene = oData[3] --source scene of image 
            local thread_id = oData[4] 

            if (service == "save_roll") then
                cancelPanel(row.params.parent)

                local tempImg = display.newImage(selectedImageName, selectedImagePath, 0, 0)
                tempImg.isVisible = false 
                local _width = tempImg.width
                local _height = tempImg.height

                tempImg:removeSelf()
                tempImg = nil

                local img = display.newImageRect(selectedImageName, selectedImagePath, 0, 0 )
                img:toBack()
                img.width = _width
                img.height = _height
                img.anchorX = 0
                img.anchorY = 0
                img.y = (__appContentHeight__ - img.height)/2    

                local capture = display.capture(img, { saveToPhotoLibrary=true, isFullResolution=true} )
                capture:removeSelf()
                capture = nil

                img:removeSelf()
                img = nil

                utils.showMessage(language["widget_photoSavePanel"]["saved"])
            elseif (service == "upload_album") then
                local function getDataCallback(event)
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
                                    utils.showMessage(language["widget_photoSavePanel"]["saved"])
                                elseif(data.status == "-85") then    
                                    utils.showMessage(language["widget_photoSavePanel"][data.status])
                                else
                                    utils.showMessage(language["common"]["wrong_connection"])
                                end
                            end
                        end
                    end

                    return true
                end
                cancelPanel(row.params.parent)

                local thread_type
                if(selectedImageScene == "scripts.noticeScene" or selectedImageScene == "scripts.noticeViewScene" or selectedImageScene == "scripts.noticeViewFromNewsScene") then
                    thread_type = 1 --공지사항
                elseif(selectedImageScene == "scripts.messageScene" or selectedImageScene == "scripts.messageViewScene" or selectedImageScene == "scripts.messageViewFromNewsScene") then
                    thread_type = 2 --연락장
                elseif(selectedImageScene == "scripts.mamatalkScene" or selectedImageScene == "scripts.mamatalkViewScene" or "scripts.mamatalkViewFromNewsScene") then
                    thread_type = 6 --마마토크
                end

                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                local activeKidData = user.getActiveKidData()
                local options = {
                    member_id = user.userData.id,
                    kids_id = activeKidData.id,
                    center_id = activeKidData.center_id,
                    thread_type = thread_type,
                    thread_id = thread_id,
                    filename = selectedImageName,
                }
                api.add_album_data(options, getDataCallback)
                sceneData.freeSceneDataWithUID("selectedImage")    
            elseif (service == "cancel") then
                cancelPanel(row.params.parent)
            end
        end
    end
    
--    local function onRowTouch( event )
--        if(event.phase == "release") then
--            local function cancelPanel(parent)
--                local myPanel = parent
--                myPanel:hide() 
--                myPanel.isShowing = false
--
--                return true
--            end
--                        
--            if (event.row) then
--                local service = event.row.params.service
--                local oData = sceneData.getSceneDataWithUID("selectedImage")
--                local selectedImageName = oData[1] --source image file name
--                local selectedImagePath = oData[2] --source image file path
--                local selectedImageScene = oData[3] --source scene of image 
--                local thread_id = oData[4] 
--                
--                if (service == "save_roll") then
--                    cancelPanel(event.row.params.parent)
--                    
--                    local tempImg = display.newImage(selectedImageName, selectedImagePath, 0, 0)
--                    tempImg.isVisible = false 
--                    local _width = tempImg.width
--                    local _height = tempImg.height
--                    
--                    tempImg:removeSelf()
--                    tempImg = nil
--                    
--                    local img = display.newImageRect(selectedImageName, selectedImagePath, 0, 0 )
--                    img:toBack()
--                    img.width = _width
--                    img.height = _height
--                    img.anchorX = 0
--                    img.anchorY = 0
--                    img.y = (__appContentHeight__ - img.height)/2    
--                    
--                    local capture = display.capture(img, { saveToPhotoLibrary=true, isFullResolution=true} )
--                    capture:removeSelf()
--                    capture = nil
--                    
--                    img:removeSelf()
--                    img = nil
--                    
--                    utils.showMessage(language["widget_photoSavePanel"]["saved"])
--                elseif (service == "upload_album") then
--                    local function getDataCallback(event)
--                        if(activityIndicator) then
--                            activityIndicator:destroy()
--                        end
--    
--                        if ( event.isError ) then
--                            print( "Network error!")
--                            utils.showMessage(language["common"]["wrong_connection"])
--                        else
--                            print(event.status)
--                            if(event.status == 200) then
--                                print ( "RESPONSE: " .. event.response )
--                                local data = json.decode(event.response)
--
--                                if (data) then
--                                    if(data.status == "OK") then
--                                        utils.showMessage(language["widget_photoSavePanel"]["saved"])
--                                    elseif(data.status == "-85") then    
--                                        utils.showMessage(language["widget_photoSavePanel"][data.status])
--                                    else
--                                        utils.showMessage(language["common"]["wrong_connection"])
--                                    end
--                                end
--                            end
--                        end
--    
--                        return true
--                    end
--                    cancelPanel(event.row.params.parent)
--                    
--                    local thread_type
--                    if(selectedImageScene == "scripts.noticeScene" or selectedImageScene == "scripts.noticeViewScene" or selectedImageScene == "scripts.noticeViewFromNewsScene") then
--                        thread_type = 1 --공지사항
--                    elseif(selectedImageScene == "scripts.messageScene" or selectedImageScene == "scripts.messageViewScene" or selectedImageScene == "scripts.messageViewFromNewsScene") then
--                        thread_type = 2 --연락장
--                    elseif(selectedImageScene == "scripts.mamatalkScene" or selectedImageScene == "scripts.mamatalkViewScene" or "scripts.mamatalkViewFromNewsScene") then
--                        thread_type = 6 --마마토크
--                    end
--                    
--                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
--                    local activeKidData = user.getActiveKidData()
--                    local options = {
--                        member_id = user.userData.id,
--                        kids_id = activeKidData.id,
--                        center_id = activeKidData.center_id,
--                        thread_type = thread_type,
--                        thread_id = thread_id,
--                        filename = selectedImageName,
--                    }
--                    api.add_album_data(options, getDataCallback)
--                    sceneData.freeSceneDataWithUID("selectedImage")    
--                elseif (service == "cancel") then
--                    cancelPanel(event.row.params.parent)
--                end
--            end
--        end
--        
--        return true
--    end
    
    local panel = widget.newPanel({
        location = "bottom",
        width = __appContentWidth__,
        height = 150,
        speed = 300,
        inEasing = easing.outCubic,
	outEasing = easing.outCubic
    })
    
    local tableView = widget.newTableView({
        top = 0, 
        left = 0,
        width = __appContentWidth__, 
        height = panel.height, 
--        backgroundColor = { 0.5 }, 
--        noLines = true,
--        backgroundColor = { 0.8, 0.8, 0.8 },
        isLocked = true,
        rowTouchDelay = __tableRowTouchDelay__,
        onRowRender = onRowRender,
--        onRowTouch = onRowTouch,
        listener = tableViewListener,
    })
    tableView.x = 0
    tableView.y = 0
    panel:insert( tableView )
    
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "save_roll",
            label = language["widget_photoSavePanel"]["save_tophone"],
            image = "images/assets1/icon_photo_to_phone.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "upload_album",
            label = language["widget_photoSavePanel"]["save_toalbum"],
            image = "images/assets1/icon_photo_to_album.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "cancel",
            label = language["widget_photoSavePanel"]["cancel"],
            image = "images/assets1/icon_cancel.png"
        }
    }
    return panel

end

