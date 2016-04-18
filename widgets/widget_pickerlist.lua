require("scripts.commonSettings")

local _widget = require( "widget" )

local M = 
{
    _options = {},
    _widgetName = "widget.newPickerList",
}

local function initPickerList( pickerList, options )
    local opt = options
    
    
    local function onCancel(event)
        pickerList:cancel()  
        return true;
    end
    
    local function onSelect(event)
        pickerList:closeUp()  
        if pickerList._onSelect then
            pickerList._onSelect(event)
        end
        return true;
    end
    
    local function onTouch(event)
        if "began" == event.phase then
--            return true
        elseif ( "ended" == event.phase )  then
            if pickerList.cancelOnBackgroundClick then
                onCancel(event)
                
            else    
                onSelect(event)
            end
            
--            return true
        end
        
        return true;
    end
    
    local function onScroll(event)
        
        if pickerList._onScroll then
            local values = pickerList.pickerWheel:getValues();
            event.values = values
            pickerList._onScroll(event)
        end
    end
    
    local view = display:newGroup();
    pickerList._view = view;
    view.top = opt.top

    if (opt.hasBackWindow == true) then
        local rect = display.newRect( view, display.contentCenterX ,display.contentCenterY, __appContentWidth__, __appContentHeight__)
        rect:setFillColor (unpack(opt.backgroundColor))
        view:insert(rect);
        rect.isHitTestable = false;
        rect:addEventListener("touch", onTouch)   
    end
    
    pickerList.editField = opt.editField;
    if pickerList.editField then
        pickerList._initialValue = pickerList.editField:getText();
    end    
    pickerList._onSelect = opt.onSelectData;
    
    pickerList.pickerWheel = _widget.newPickerWheel
    {
        top = opt.top+opt.height - opt.pickerHeight,
        overlayFrameHeight = opt.pickerHeight,
        overlayFrameWidth = display.contentWidth,
        rowHeight = opt.pickerRowHeight,
        columns = opt.pickerData,
        columnColor = opt.pickerColumnColor,
        backgroundColor = opt.pickerColumnColor,
        font = opt.pickerFont,
        fontColor = opt.pickerFontColor,
        fontSize = opt.pickerFontSize,
        onScroll = onScroll,
        
    }
    view:insert(pickerList.pickerWheel)

    pickerList._onScroll = opt.onScroll
    pickerList._onClose = opt.onClose
    pickerList.cancelOnBackgroundClick = opt.cancelOnBackgroundClick;
--    pickerList._onOKClick = opt.onOKClick
    native.setKeyboardFocus(nil)
    
    if (opt.titleText) then
        local titleRect = display.newRect( view, display.contentCenterX ,display.contentCenterY, __appContentWidth__, 40)
        titleRect:setFillColor (0.2,0.2,0.2)
        titleRect.anchorY = 0
        titleRect.y = __appContentHeight__ - pickerList.pickerWheel.height - titleRect.height
        view:insert(titleRect);
        
        local titleText = display.newText(opt.titleText, 0, 0, native.systemFont, 12)
        titleText.anchorX = 0
        titleText.anchorY = 0
        titleText.x = 20
        titleText.y = titleRect.y + (titleRect.height - titleText.height)/2 
        titleText:setFillColor(1, 1, 1)
        view:insert(titleText)
        
        local okButtonGroup = display.newGroup()
        local okButton = display.newRoundedRect(0, 0, 50, 20, 3)
        okButton.anchorX = 0
        okButton.anchorY = 0
        okButton.x = titleRect.width - okButton.width - 10
        okButton.y = titleRect.y + (titleRect.height - okButton.height)/2
        okButton:setFillColor(0,0 , 0, 1)
        okButton.strokeWidth = 1
        okButton:setStrokeColor(1, 1, 1, 1)
        okButtonGroup:insert(okButton)

        local okButton_text = display.newText(opt.okButtonText, 0, 0, native.systemFont, 10)
        okButton_text.anchorX = 0
        okButton_text.anchorY = 0
        okButton_text.x = okButton.x + (okButton.width - okButton_text.width)/2
        okButton_text.y = okButton.y + (okButton.height - okButton_text.height)/2
        okButtonGroup:insert(okButton_text)
        view:insert(okButtonGroup)
        
        if(opt.onOKClick) then
            okButtonGroup:addEventListener("touch", opt.onOKClick)
        end    
    end
    
    function pickerList:_finalize()
        
    end
    
    
    function pickerList:closeUp()
        if self._onClose then
            local event = {}
            event.target = self
            self._onClose(event)
        end
        self._view:removeSelf();
        self:removeSelf()
    end
    
    function pickerList:cancel()
        if self.editField then
            self.editField:setText(self._initialValue);
            self.editField.id = self.initialId;
        end    
        self:closeUp()
    end;
end
-- Function to create a new editfield object ( widget.newEditField)
function M.new( options )	
    local customOptions = options or {}
    
    -- Create a local reference to our options table
    local opt = M._options
    -------------------------------------------------------
    -- Properties
    -------------------------------------------------------	
    -- Positioning & properties
    opt.left = customOptions.left or 0
    opt.top = customOptions.top or 0
    opt.x = customOptions.x or nil
    opt.y = customOptions.y or nil
    if customOptions.x and customOptions.y then
        opt.left = 0
        opt.top = 0
    end    
    opt.width = customOptions.width or display.contentWidth
    opt.height = customOptions.height or display.contentHeight
    
    opt.backgroundColor =  customOptions.backgroundColor or {0,0,0,0.5}
    opt.editField = customOptions.editField
    opt.onScroll = customOptions.onScroll
    opt.onClose  = customOptions.onClose
    opt.cancelOnBackgroundClick = customOptions.cancelOnBackgroundClick 
    
    opt.toolbarWidth  = customOptions.toolbarWidth or display.contentWidth
    opt.toolbarHeight = customOptions.toolbarHeight or 50
    opt.toolbarTop = customOptions.toolbarTop or 0
    opt.toolbarColor = customOptions.toolbarColor or {1,1,1,1}
    
    opt.buttonsWidth = customOptions.buttonsWidth or 75
    opt.buttonsMargin = customOptions.buttonsMargin or 10
    opt.cancelLabel = customOptions.cancelLabel or "Cancel"
    opt.doneLabel = customOptions.doneLabel or "Done"
    
    opt.titleText = customOptions.titleText or nil
    opt.onOKClick = customOptions.onOKClick
    opt.okButtonText = customOptions.okButtonText or "OK"
    
    if(customOptions.hasBackWindow ~= nil) then
        opt.hasBackWindow = customOptions.hasBackWindow
    else
        opt.hasBackWindow = true
    end
    
    opt.pickerHeight = customOptions.pickerHeight or 222
    opt.pickerRowHeight = customOptions.pickerRowHeight or 35
    opt.pickerData = customOptions.pickerData
    opt.pickerColumnColor = customOptions.pickerColumnColor
    opt.pickerFont = customOptions.pickerFont
    opt.pickerFontColor = customOptions.pickerFontColor or {0,0,0}
    opt.pickerFontSize = customOptions.pickerFontSize
    -- Create the editField object
    local pickerList = _widget._new
    {
        left = opt.left,
        top = opt.top,
        id = opt.id or "widget_pickerList",
        baseDir = opt.baseDir,
    }
    
    
    initPickerList( pickerList, opt )
    
    -- Set the editField's position ( set the reference point to center, just to be sure )
    
    local x, y = opt.x, opt.y
    if not opt.x or not opt.y then
        x = opt.left + pickerList.contentWidth * 0.5
        y = opt.top + pickerList.contentHeight * 0.5
    end
    pickerList.x, pickerList.y = x, y
    
    return pickerList
end

return M

