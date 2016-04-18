require("scripts.commonSettings")

local M = {}
local group
 
function M.createDialog(messageText)
    if(group) then
        group:removeSelf()
        group = nil
    end
    
    group = display.newGroup()
    group.alpha = 0
    
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
    overlay.anchorX = 0
    overlay.anchorY = 0
    overlay.x = (__appContentWidth__ - overlay.width) / 2
    overlay.y = (__appContentHeight__ - overlay.height) / 2
    overlay.strokeWidth = 0
    overlay:setFillColor( 0,0,0, 0.8 )
    overlay:setStrokeColor( 0, 0, 0 )
    group:insert (overlay)
    overlay:addEventListener("touch", 
        function(event)
            if(event.phase == "ended") then
                transition.to(group, { time = 200, alpha = 0, onComplete = 
                    function()
                        group:removeSelf()
                        group = nil
                    end } 
                )
            end
            return true    
        end
    )
    
    local Text = display.newText(messageText, 0, 0, txt_width, txt_height, native.systemFont, __textLabelFontSize__)
    Text.anchorY = 0
    Text.x = display.contentCenterX
    Text.y = overlay.y + 10
    group:insert(Text)
    
--    local close_icon = display.newImageRect("images/assets1/icon_cancel.png",25, 25)
--    close_icon.anchorX = 0
--    close_icon.anchorY = 0
--    close_icon.x = overlay.x + overlay.width - (close_icon.width / 2)
--    close_icon.y = overlay.y - (close_icon.height / 2)
--    group:insert(close_icon)
    
    transition.to(group, { time = 200, alpha = 1, onComplete = nil } )
end

return M
