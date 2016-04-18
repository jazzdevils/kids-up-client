require("scripts.commonSettings")
local DEFAULT_SHOWTIME = 2200

local M = {}
local timerID
local group
 
function M.createDialog(messageText, showTime)
    if(group) then
        print("remove group")
        if(timerID) then
            timer.cancel(timerID)
        end
        group:removeSelf()
        group = nil
    end
    
    group = display.newGroup()
    group.alpha = 0
    
    if(not showTime) then
        showTime = DEFAULT_SHOWTIME
    elseif(showTime and showTime < DEFAULT_SHOWTIME) then
        showTime = DEFAULT_SHOWTIME
    end
    
    local limitWidth = __appContentWidth__ - 60
    local tmpText = display.newText(messageText, 0, 0, native.systemFont, __textLabelFontSize__)
    local txt_width = tmpText.width
    local txt_height = tmpText.height
    tmpText:removeSelf()
    tmpText = nil
    
    if(txt_width > limitWidth) then
        txt_width = limitWidth
        
        local tmpText = display.newText(messageText, 0, 0, txt_width, 0, native.systemFont, __textLabelFontSize__)
        txt_height = tmpText.height
        tmpText:removeSelf()
        tmpText = nil
    end
    
    local overlay = display.newRoundedRect(0, 0, txt_width + 20 , txt_height + 20, 6)
    overlay.x = display.contentCenterX
    overlay.y = display.contentCenterY
    overlay.strokeWidth = 0
--    overlay:setFillColor( 0.2 )
    overlay:setFillColor( 0,0,0, 0.8 )
    overlay:setStrokeColor( 0, 0, 0 )
--    overlay.alpha = 0.8
    group:insert (overlay)
    overlay:addEventListener("touch", 
        function(event)
            if(event.phase == "ended") then
                if(timerID) then
                    timer.cancel(timerID)
                end
                group:removeSelf()
                group = nil
            end
            return true    
        end
    )
    
    local Text = display.newText(messageText, 0, 0, txt_width, txt_height, native.systemFont, __textLabelFontSize__)
    Text.x = display.contentCenterX
    Text.y = display.contentCenterY
    group:insert(Text)
    transition.to(group, { time = 200, alpha = 1, onComplete = 
        function()
            timerID = timer.performWithDelay( showTime, 
                function() 
                    transition.to(group, { time = 200, alpha = 0, onComplete = 
                        function()
                            if(timerID) then
                                timer.cancel(timerID)
                            end
                            if(group) then
                                group:removeSelf()
                                group = nil
                            end
                        end } 
                    )
                end 
            )
        end } 
    )
end

return M
