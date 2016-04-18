require("scripts.commonSettings")

local storyboard = require( "storyboard" )
local widget = require("widget")

ActivityIndicator = {}

function ActivityIndicator:new(message)
    local self = {}
    storyboard.isAction = true
    
    self._rect = display.newRect( display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__)
    self._rect:setFillColor(0, 0, 0, 0.5)
    self._rect:addEventListener("touch", function(event) return true end )

    local options = {
        width = 108,
        height = 20,
        numFrames = 7,
        sheetContentWidth = 756,
        sheetContentHeight = 20
    }
    self._spinnerMultiSheet = graphics.newImageSheet( "images/sheets/progress.png", options )

    self._spinner = widget.newSpinner{
        width = 108,
        height = 20,
        sheet = self._spinnerMultiSheet,
        startFrame = 1,
        count = 7,
        time = 1000,
        x=display.contentCenterX, 
        y=display.contentCenterY,
    }
    self._spinner:start()    
    
    local tmpText = display.newText(message, display.contentCenterX, display.contentCenterY + self._spinner.height, native.systemFontBold, 12)
    local tmpText_width = tmpText.width
    local tmpText_height = tmpText.height
    
    tmpText:removeSelf()
    tmpText = nil
    
    self._text_rect = display.newRoundedRect(display.contentCenterX, display.contentCenterY + self._spinner.height + 3, tmpText_width + 20, tmpText_height + 10, 6)
    self._text_rect.fill = {0, 0, 0}
    
    self._textField = display.newText(message, display.contentCenterX, display.contentCenterY + self._spinner.height + 3, native.systemFontBold, 12)
    self._textField.fill = {1, 1, 1}
    
    function self:destroy()
        if(self._rect) then
            self._rect:removeSelf()
            self._rect = nil
        end
          
        if(self._spinner) then 
            self._spinner:removeSelf()
            self._spinner = nil
        end

        if(self._text_rect) then
            self._text_rect:removeSelf()
            self._text_rect = nil
        end
      
        if(self._textField) then 
            self._textField:removeSelf()
            self._textField = nil
        end
      
        if(self._logoImg) then
            self._logoImg:removeSelf()
            self._logoImg = nil
        end
        
        storyboard.isAction = false
    end

    function self:touch(event)
      return true
    end

    return self
end

function ActivityIndicator:new_Shield(message)
    local self = {}
    storyboard.isAction = true
    
    self._rect = display.newRect( display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__)
    self._rect:setFillColor(0, 0, 0, 0.5)
    self._rect:addEventListener("touch", function(event) return true end )

    local options = {
        width = 55,
        height = 55,
        numFrames = 6,
        sheetContentWidth = 330,
        sheetContentHeight = 55
    }
    self._spinnerMultiSheet = graphics.newImageSheet( "images/sheets/progress_security.png", options )

    self._spinner = widget.newSpinner{
        width = 55,
        height = 55,
        sheet = self._spinnerMultiSheet,
        startFrame = 1,
        count = 6,
        time = 1000,
        x=display.contentCenterX, 
        y=display.contentCenterY,
    }
        
    self._spinner:start()    
    
    local tmpText = display.newText(message, display.contentCenterX, display.contentCenterY + self._spinner.height, native.systemFontBold, 12)
    local tmpText_width = tmpText.width
    local tmpText_height = tmpText.height
    
    tmpText:removeSelf()
    tmpText = nil
    
    self._text_rect = display.newRoundedRect(display.contentCenterX, display.contentCenterY + self._spinner.height - 10, tmpText_width + 20, tmpText_height + 10, 6)
    self._text_rect.fill = {0, 0, 0}
    
    self._textField = display.newText(message, display.contentCenterX, display.contentCenterY + self._spinner.height - 10, native.systemFontBold, 12)
    self._textField.fill = {1, 1, 1}
    
    function self:destroy()
        if(self._rect) then
            self._rect:removeSelf()
            self._rect = nil
        end
          
        if(self._spinner) then 
            self._spinner:removeSelf()
            self._spinner = nil
        end

        if(self._text_rect) then
            self._text_rect:removeSelf()
            self._text_rect = nil
        end
      
        if(self._textField) then 
            self._textField:removeSelf()
            self._textField = nil
        end
      
        if(self._logoImg) then
            self._logoImg:removeSelf()
            self._logoImg = nil
        end
        
        storyboard.isAction = false
    end

    function self:touch(event)
      return true
    end

    return self
end

function ActivityIndicator:new_small(x, y)
    local self = {}
    
    storyboard.isAction = true
    
    local options = {
        width = 26,
        height = 26,
        numFrames = 12,
        sheetContentWidth = 312,
        sheetContentHeight = 26
    }
    self._spinnerMultiSheet = graphics.newImageSheet( "images/sheets/top_spinnerSheet.png", options )

    self._spinner = widget.newSpinner{
        width = 26,
        height = 26,
        sheet = self._spinnerMultiSheet,
        startFrame = 1,
        count = 12,
        time = 1000,
        x = x, 
        y = y,
    }
    self._spinner:start()
    
    function self:destroy()
        if(self._spinner) then 
            self._spinner:removeSelf()
            self._spinner = nil
        end
    
        storyboard.isAction = false
    end

    function self:touch(event)
      return true
    end

    return self
end
