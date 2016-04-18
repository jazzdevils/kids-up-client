require("scripts.commonSettings")
local widget = require( "widget" )
local api = require("scripts.api")
local json = require("json")
local utils = require("scripts.commonUtils")
local language = getLanguage()
require("widgets.activityIndicator")
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
    
    local container = display.newContainer( opt.width , opt.height )
    
    local function onRectTouch(event)
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

function widget.newSharingPanelForApproval()
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
    local function onRowTouch( event )
        if(event.phase == "release") then
            local function cancelPanel(parent)
                local myPanel = parent
                myPanel:hide() 
                myPanel.isShowing = false

                return true
            end
            
            local function doApprovalMember(panel)
                local targetTable = panel.targetTable
                local data = panel.targetRow.params.approval_data
                local memberName = data.member_type == "2" and data.member_name or data.kids_name
                
                local function apiCallback(event)
                    activityIndicator:destroy()
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
                                    targetTable:deleteRow(panel.targetRow.index)
                                    if targetTable:getNumRows() == 1 then
                                        local function listener( event )
                                            panel.initFunc()
                                        end
                                        timer.performWithDelay( 500,  listener)
                                    end
                                    cancelPanel(panel)
                                else
                                    utils.showMessage(data.message)
                                end
                            end
                        end
                    end
                end
                
                local alert = native.showAlert( language["appTitle"], string.gsub(language["askApprovalScene"]["approval_confirm"], "__NAME__", memberName), { language["askApprovalScene"]["confirm"], language["askApprovalScene"]["cancel"] }, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                                api.do_askapprove(data.member_id, data.member_type, data.kids_id, apiCallback)
                            elseif 2 == i then
                            end
                        end
                    end )
            end
            
            local function deleteApprovalMember(panel)
                local targetTable = panel.targetTable
                local data = panel.targetRow.params.approval_data
                local memberName = data.member_type == "2" and data.member_name or data.kids_name
                
                local function apiCallback(event)
                    activityIndicator:destroy()
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
                                    targetTable:deleteRow(panel.targetRow.index)
                                    if targetTable:getNumRows() == 1 then
                                        local function listener( event )
                                            panel.initFunc()
                                        end
                                        timer.performWithDelay( 500,  listener)
                                    end
                                    cancelPanel(panel)
                                else
                                    utils.showMessage(data.message)
                                end
                            end
                        end
                    end
                end
                
                local alert = native.showAlert( language["appTitle"], string.gsub(language["askApprovalScene"]["delete_confirm"], "__NAME__", memberName), { language["askApprovalScene"]["confirm"], language["askApprovalScene"]["cancel"] }, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                                api.delete_askapprove(data.member_id, data.member_type, data.kids_id, apiCallback)
                            elseif 2 == i then
                            end
                        end
                    end )
            end
            
            if (event.row and event.row.params.parent.targetRow) then
                local service = event.row.params.service
                if (service == "approveMember") then
                    doApprovalMember(event.row.params.parent)
                elseif (service == "deleteMember") then
                    deleteApprovalMember(event.row.params.parent)
                elseif (service == "cancel") then
                    cancelPanel(event.row.params.parent)
                end
            end
        end
        
        return true
    end
    
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
        rowTouchDelay = __tableRowTouchDelay__,
        isLocked = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch 
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
            service = "approveMember",
            label = language["askApprovalScene"]["approve"],
            image = "images/assets1/icon_ok.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "deleteMember",
            label = language["askApprovalScene"]["delete"],
            image = "images/assets1/icon_delete.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "cancel",
            label = language["askApprovalScene"]["cancel"],
            image = "images/assets1/icon_cancel.png"
        }
    }
    return panel
end