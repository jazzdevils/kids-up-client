require("scripts.commonSettings")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local utils = require("scripts.commonUtils")
local json = require("json")
local access = require("scripts.accessScene")
local api = require("scripts.api")
local language = getLanguage()

local activityIndicator

local function tourLoginCallback(event)
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            if (data) then
                if (data.status == "OK") then
                    local loginJson = {}
                    
                    loginJson.logined = "0"
                    
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    loginJson.member = {}
                    loginJson.member.id = data.member.id
                    loginJson.member.centerId = data.member.center_id
                    loginJson.member.centerName = data.member.center_name
                    loginJson.member.type = data.member.type
                    loginJson.member.subtype = data.member.subtype
                    loginJson.member.name = data.member.name
                    loginJson.member.phonenum = data.member.phonenum
                    loginJson.member.img = data.member.img
                    loginJson.member.profileImage = profileImage
                    loginJson.member.approvalState = data.member.approval_state
                    loginJson.member.classId = data.member.class_id
                    loginJson.member.className = data.member.class_name
                    if(data.member.img ~= "") then
                        if(utils.fileExist(profileImage, system.DocumentsDirectory) ~= true) then
                            network.download(
                                data.member.img,
                                "GET",
                                function() end,
                                profileImage,
                                system.DocumentsDirectory
                            )
                        end
                    end
                    if utils.setAppInitPropertyData(loginJson) then
                        activityIndicator:destroy()
                        
                        storyboard.state.DEMO_MODE = true --체험모드 로그인
                        
                        if loginJson.member.type == __PARENT__ then
                            access:getKidsInfo(data.member.id)
                        else
                            access:gotoMngHomeSceneFromLogin(data)
                        end
                    else
                        activityIndicator:destroy()
                        utils.showMessage( language["loginScene"]["login_error"] )
                    end
                elseif (data.status == "-11") then
                    activityIndicator:destroy()
                    utils.showMessage( language["joinScene"]["email_format_error"] )
                    return true
                else
                    activityIndicator:destroy()
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage( language["loginScene"]["wrong_login"] )
                end
            end
        end
    end
    
    return true
end

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
    rect:setFillColor(0, 0, 0, 0.1)
    
    local container = display.newContainer( opt.width , opt.height )
    
    local function onRectTouch(event)
        print("onRectTouch : " .. event.phase)
        if (event.phase == "ended") then
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

function widget.newTourSharingPanel()
    local function onRowRender( event )
        local row = event.row
        local id = row.index
        local params = event.row.params
        local icon = params.image or nil

        if row.isCategory then
            row.text = display.newText(params.label, 0, 0, native.systemFont, __textSubMenuFontSize__)
            row.text:setFillColor( 0.67 )
            row.text.x = display.contentCenterX
            row.text.y = row.contentHeight * 0.5
            row:insert(row.text)
        else
            if(icon) then
                row.icon = display.newImageRect(row, icon, 24, 24)
                row.icon.anchorX = 0
                row.icon.anchorY = 0
                row.icon.x = 20
                row.icon.y = (row.contentHeight - 24) /2
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
            
            if (row) then
                local service = row.params.service
                
                if (service == "parentMode") then
                    cancelPanel(row.params.parent)
                    
                    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
                    
                    timer.performWithDelay( 500, 
                        function()
                            local email, password = utils.getTourAccount(__PARENT__)
                            api.login_api(email, password, tourLoginCallback)
                        end 
                    )
                elseif (service == "teacherMode") then
                    cancelPanel(row.params.parent)
                    
                    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
                    
                    timer.performWithDelay( 500, 
                        function() 
                            local email, password = utils.getTourAccount(__TEACHER__)
                            api.login_api(email, password, tourLoginCallback)
                        end 
                    )
                elseif (service == "principalMode") then
                    cancelPanel(row.params.parent)
                    
                    activityIndicator = ActivityIndicator:new_Shield(language["activityIndicator"]["login"])
                    
                    timer.performWithDelay( 500, 
                        function() 
                            local email, password = utils.getTourAccount(__DIRECTOR__)
                            api.login_api(email, password, tourLoginCallback)
                        end 
                    )
                elseif (service == "cancel") then
                    cancelPanel(row.params.parent)
                end
            end
        end
        
        return true
    end
    
    local panel = widget.newPanel({
        location = "bottom",
        width = __appContentWidth__,
        height = 250,
        speed = 300,
        inEasing = easing.outCubic,
	outEasing = easing.outCubic
    })
    
    local tableView = widget.newTableView({
        top = 0, 
        left = 0,
        width = __appContentWidth__, 
        height = panel.height, 
        rowTouchDelay = __tableRowTouchDelay__,
        isLocked = true,
        onRowRender = onRowRender,
        listener = tableViewListener,
    })
    tableView.x = 0
    tableView.y = 0
    panel:insert( tableView )
    
    tableView:insertRow{
        rowHeight = 50,
        isCategory = true,
        rowColor = { 0, 1, 1 },
        params = {
            parent = panel,
            service = "description",
            label = language["tourScene"]["description"],
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "parentMode",
            label = language["tourScene"]["parent"],
            image = "images/assets1/icon_setting_parent.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "teacherMode",
            label = language["tourScene"]["teacher"],
            image = "images/assets1/icon_setting_teacher.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "principalMode",
            label = language["tourScene"]["principal"],
            image = "images/assets1/icon_setting_principal.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "cancel",
            label = language["tourScene"]["cancel"],
            image = "images/assets1/icon_cancel.png"
        }
    }
    return panel

end



--[[
local function hideIt()
	sharePanel:hide()
end
timer.performWithDelay( 2000, hideIt )
]]


