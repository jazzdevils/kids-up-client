local DEFAULT_SHOWTIME = 3000

local M = {}
local timerID
local group
local popupWidth = __appContentWidth__ - 40
local language = getLanguage()
 
--function M.createPopup(messageText, showTime)
--    if(group) then
--        if(timerID) then
--            timer.cancel(timerID)
--        end
--        group:removeSelf()
--        group = nil
--    end
--    
--    group = display.newGroup()
--    group.alpha = 0
--    
--    if(not showTime) then
--        showTime = DEFAULT_SHOWTIME
--    elseif(showTime and showTime < DEFAULT_SHOWTIME) then
--        showTime = DEFAULT_SHOWTIME
--    end
--    
--    local popupFrame = display.newRoundedRect(0, 0, popupWidth, 70, 4)
--    popupFrame:setFillColor( 1, 1, 0 )
--    popupFrame.x = display.contentCenterX
--    popupFrame.anchorY = 0
--    popupFrame.y = 30
--    group:insert(popupFrame)
--    popupFrame:addEventListener("touch", 
--        function(event)
--            if(event.phase == "ended") then
--                if(timerID) then
--                    timer.cancel(timerID)
--                end
--                group:removeSelf()
--                group = nil
--            end
--            return true    
--        end
--    )
--    
--    local icon = display.newImageRect("Icon.png", 30, 30)
--    icon.anchorX = 0
--    icon.anchorY = 0
--    icon.x = popupFrame.x - popupWidth / 2 + 5
--    icon.y = popupFrame.y + 5
--    group:insert(icon)
--    
--    local title = display.newText(language["appTitle"], 0, 0, popupWidth - 30 - 30, 20, native.systemFont, 16)
--    title.anchorX = 0
--    title.anchorY = 0
--    title.x = icon.x + icon.width + 10
--    title.y = icon.y + (icon.height - title.height) / 2 - 2
--    title:setFillColor(0, 0, 0)
--    group:insert(title)
--    
--    local alert = display.newText(messageText, 0, 0, popupWidth - 10, 30, native.systemFont, 12)
--    alert.anchorX = 0
--    alert.anchorY = 0
--    alert.x = icon.x
--    alert.y = icon.y + icon.height
--    alert:setFillColor(0, 0, 0)
--    group:insert(alert)
--    transition.to(group, { time = 200, alpha = 1, onComplete = 
--        function()
--            timerID = timer.performWithDelay( showTime, 
--                function() 
--                    transition.to(group, { time = 200, alpha = 0, onComplete = 
--                        function()
--                            if(timerID) then
--                                timer.cancel(timerID)
--                            end
--                            if(group) then
--                                group:removeSelf()
--                                group = nil
--                            end
--                        end } 
--                    )
--                end 
--            )
--        end } 
--    )
--end

function M.offMessage()
    transition.to( group, { y = -100, time = 500, transition = easing.outCubic, onComplete = 
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

function M.onMessage(_showTime)
    timerID = timer.performWithDelay( _showTime, 
        function() 
            transition.to( group, { y = -100, time = 700, transition = easing.outCubic, onComplete = M.offMessage() } )
        end 
    )
end

function M.createPopup(messageText, showTime)
    local opt = {}
    local default_width, default_height
    default_width = display.contentWidth
    default_height = display.contentHeight * 0.33
    opt.width = default_width
    opt.height = default_height
    opt.inEasing = easing.outBack
    opt.outEasing = easing.linear
    
    if(group) then
        if(timerID) then
            timer.cancel(timerID)
        end
        group:removeSelf()
        group = nil
    end
    
    group = display.newGroup()
    group.alpha = 1
    
    if(not showTime) then
        showTime = DEFAULT_SHOWTIME
    elseif(showTime and showTime < DEFAULT_SHOWTIME) then
        showTime = DEFAULT_SHOWTIME
    end
    
    local popupFrame = display.newRoundedRect(0, 0, popupWidth, 70, 4)
    popupFrame:setFillColor( 1, 1, 0 )
    popupFrame.x = display.contentCenterX
    popupFrame.anchorY = 0
    popupFrame.y = 30
    group:insert(popupFrame)
    popupFrame:addEventListener("touch", 
        function(event)
            if(event.phase == "ended") then
                M.offMessage()
            end
            return true    
        end
    )
    
    local icon = display.newImageRect("Icon.png", 30, 30)
    icon.anchorX = 0
    icon.anchorY = 0
    icon.x = popupFrame.x - popupWidth / 2 + 5
    icon.y = popupFrame.y + 5
    group:insert(icon)
    
    local title = display.newText(language["appTitle"], 0, 0, popupWidth - 30 - 30, 20, native.systemFont, 16)
    title.anchorX = 0
    title.anchorY = 0
    title.x = icon.x + icon.width + 10
    title.y = icon.y + (icon.height - title.height) / 2 - 2
    title:setFillColor(0, 0, 0)
    group:insert(title)
    
    local alert = display.newText(messageText, 0, 0, popupWidth - 10, 30, native.systemFont, 12)
    alert.anchorX = 0
    alert.anchorY = 0
    alert.x = icon.x 
    alert.y = icon.y + icon.height + 3
    alert:setFillColor(0, 0, 0)
    group:insert(alert)
    
    group.x = 0
    group.y = -100
    
    transition.to(group, { y = 0, time = 700, transition = opt.inEasing, onComplete = M.onMessage(showTime) } )
end

return M
