require("scripts.commonSettings")
local storyboard = require( "storyboard" )
local widget = require( "widget" )
local language = getLanguage()


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

function widget.newSharingPanel()
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
            
            if (row and row.params.parent.kidData) then
                local service = row.params.service
                local fromScene = row.params.parent.fromScene 
                local imagePath = row.params.parent.imagePath
                
                if (service == "takephoto") then
                    cancelPanel(row.params.parent)

                    local options = {
                        params = {
                            kidData = row.params.parent.kidData,
                            fromScene = fromScene,
                            imagePath = imagePath
                        }    
                    }
                    timer.performWithDelay( 500, 
                        function() 
                            storyboard.purgeScene("scripts.takePhotoScene")
                            storyboard.gotoScene("scripts.takePhotoScene", options) 
                        end 
                    )
                elseif (service == "getphoto") then
                    cancelPanel(row.params.parent)

                    local options = {
                        params = {
                            kidData = row.params.parent.kidData,
                            fromScene = fromScene,
                            imagePath = imagePath
                        }    
                    }
                    timer.performWithDelay( 500, 
                        function() 
                            storyboard.purgeScene("scripts.getPhotoScene")
                            storyboard.gotoScene("scripts.getPhotoScene", options) 
                        end 
                    )
                elseif (service == "cancel") then
                    cancelPanel(row.params.parent)
                end
            end
        end
        
        return true
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
--            if (event.row and event.row.params.parent.kidData) then
--                local service = event.row.params.service
--                local fromScene = event.row.params.parent.fromScene 
--                local imagePath = event.row.params.parent.imagePath
--                
--                if (service == "takephoto") then
--                    cancelPanel(event.row.params.parent)
--
--                    local options = {
--                        params = {
--                            kidData = event.row.params.parent.kidData,
--                            fromScene = fromScene,
--                            imagePath = imagePath
--                        }    
--                    }
--                    timer.performWithDelay( 500, 
--                        function() 
--                            storyboard.purgeScene("scripts.takePhotoScene")
--                            storyboard.gotoScene("scripts.takePhotoScene", options) 
--                        end 
--                    )
--                elseif (service == "getphoto") then
--                    cancelPanel(event.row.params.parent)
--
--                    local options = {
--                        params = {
--                            kidData = event.row.params.parent.kidData,
--                            fromScene = fromScene,
--                            imagePath = imagePath
--                        }    
--                    }
--                    timer.performWithDelay( 500, 
--                        function() 
--                            storyboard.purgeScene("scripts.getPhotoScene")
--                            storyboard.gotoScene("scripts.getPhotoScene", options) 
--                        end 
--                    )
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
        rowTouchDelay = __tableRowTouchDelay__,
        isLocked = true,
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
            service = "takephoto",
            label = language["widget_sharePanel"]["take_photo"],
            image = "images/assets1/icon_photo.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "getphoto",
            label = language["widget_sharePanel"]["get_photo"],
            image = "images/assets1/icon_album.png",  
        }
    }
    tableView:insertRow{
        rowHeight = 50,
        isCategory = false,
        rowColor = { 1, 1, 1 },
        params = {
            parent = panel,
            service = "cancel",
            label = language["widget_sharePanel"]["cancel"],
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
