---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local url = require("socket.url")

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local popupWidth = __appContentWidth__ - 100
local popupName = "social"

local function closeButtonEvent( event )
    if event.phase == "ended" then
       storyboard.hideOverlay( "crossFade", 300 ) 
    end
    
    return true
end

local function onShareButtonReleased( event )
    local serviceName = event.target.id
    if serviceName == "line" then
--        local function urlencode(str)
--            if (str) then
--                str = string.gsub (str, "\n", "\r\n")
--                str = string.gsub (str, "([^%w ])",
--                function (c) return string.format ("%%%02X", string.byte(c)) end)
--                str = string.gsub (str, " ", "+")
--            end
--            return str
--        end
 
        local encodeString = "http://line.me/R/msg/text/?"..url.escape(language["socialShareScene"]["message"] .. __WEB_PAGE_SERVER_ADDR__)
        system.openURL(encodeString)
    else
        local isAvailable = native.canShowPopup( popupName, serviceName )
        
        local function socialListener( event )
            native.setKeyboardFocus(nil)
        end
        
        if isAvailable then
            native.showPopup( popupName,
            {
                service = serviceName, 
                message = language["socialShareScene"]["message"],
                listener = socialListener,
                image = 
                {
                    { filename = "share_image.png", baseDir = system.ResourceDirectory },
                },
                url = { __WEB_PAGE_SERVER_ADDR__, }
            })
        else
            utils.showMessage( string.gsub(language["socialShareScene"]["error_ios"], "_SERVICENAME_", serviceName), 3000)
        end
    end
end

function scene:createScene( event )
    local group = self.view
    local params = event.params
    
    local layerBg = display.newRect( group, display.contentCenterX, display.contentCenterY, __appContentWidth__, __appContentHeight__ )
    layerBg.strokeWidth = 0
    layerBg:setFillColor( 0, 0, 0, 0.5 )

    local popupFrame = display.newImageRect(group, "images/assets2/bg_popup.png", popupWidth + 14, 200)
    popupFrame.anchorX = 0
    popupFrame.anchorY = 0
    popupFrame.x = (__appContentWidth__ - popupFrame.width) * 0.5
    popupFrame.y = (__appContentHeight__ - popupFrame.height) * 0.5

    local popupTitleRec = display.newRect( group, popupFrame.x, popupFrame.y - popupFrame.height / 2 + 12 + 7, popupWidth, 24 )
    popupTitleRec.strokeWidth = 0
    popupTitleRec:setFillColor( unpack(__POPUP_TITLE_BG_COLOR__) )
    popupTitleRec.anchorX = 0
    popupTitleRec.anchorY = 0
    popupTitleRec.x = popupFrame.x + (popupFrame.width - popupTitleRec.width) * 0.5
    popupTitleRec.y = popupFrame.y + 5
    
    local popupTitleOptions = 
    {
        parent = group,
        text = language["socialShareScene"]["title"],
        x = popupTitleRec.x,
        y = popupTitleRec.y,
        width = popupWidth,
        font = native.systemFontBold,
        fontSize = __textLabelFontSize__,
        align = "center"
    }
    local popupTitle = display.newText(popupTitleOptions)
    popupTitle:setFillColor( unpack(__POPUP_TITLE_TXT_COLOR__) )
    popupTitle.anchorX = 0
    popupTitle.anchorY = 0
    popupTitle.x = popupTitleRec.x + (popupTitleRec.width - popupTitle.width) * 0.5
    popupTitle.y = popupTitleRec.y + (popupTitleRec.height - popupTitle.height) * 0.5
    
    local popupDescOptions = 
    {
        parent = group,
        text = language["socialShareScene"]["description"],
        x = popupTitleRec.x,
        y = popupTitleRec.y,
        width = popupWidth - 40,
        font = native.systemFontBold,
        fontSize = __textLabelFontSize__,
        align = "center"
    }
    local popupDesc = display.newText(popupDescOptions)
    popupDesc:setFillColor( 0, 0, 0)
--    popupDesc.anchorX = 0
    popupDesc.anchorY = 0
    popupDesc.x = display.contentCenterX--popupTitleRec.x + (popupTitleRec.width - popupTitle.width) * 0.5
    popupDesc.y = popupTitleRec.y + popupTitleRec.height + 6
    
    local close_button = widget.newButton
    {
        width = 150 ,
        height = 30 ,
        left = display.contentCenterX - 150 / 2,
        top = 280, 
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["socialShareScene"]["close"],
        onRelease = closeButtonEvent
    }
    group:insert(close_button)
    close_button.anchorX = 0
    close_button.anchorY = 0
    close_button.x = popupTitleRec.x + (popupTitleRec.width - close_button.width) * 0.5
    close_button.y = popupFrame.y + popupFrame.height - close_button.height - 5
    
    local sns_RectWidth = popupFrame.width / 3
    local facebook_label = display.newText(language["socialShareScene"]["btn_facebook"], 0, 0, native.systemFont, __buttonFontSize__)
    local facebook_button = widget.newButton
    {
        id = "facebook",
        width = 60 ,
        height = 60 ,
        left = display.contentCenterX - 150 / 2,
        top = 200, 
        defaultFile = "images/assets1/btn_facebook.png",
        overFile = "images/assets1/btn_facebook_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        onRelease = onShareButtonReleased,
    }
    group:insert(facebook_button)
    facebook_button.anchorX = 0
    facebook_button.anchorY = 0
    facebook_button.x = popupFrame.x + (sns_RectWidth - facebook_button.width) * 0.5 + 10
    facebook_button.y = close_button.y - facebook_button.height - 10 - facebook_label.height
    
    facebook_label.anchorX = 0
    facebook_label.anchorY = 0
    facebook_label.x = facebook_button.x + (facebook_button.width - facebook_label.width) * 0.5
    facebook_label.y = facebook_button.y + facebook_button.height + 2
    facebook_label:setFillColor( 0, 0, 0)
    group:insert(facebook_label)
    
    local twitter_label = display.newText(language["socialShareScene"]["btn_twitter"], 0, 0, native.systemFont, __buttonFontSize__)
    local twitter_button = widget.newButton
    {
        id = "twitter",
        width = 60 ,
        height = 60 ,
        left = display.contentCenterX + 6 ,
        top = 200, 
        defaultFile = "images/assets1/btn_twitter.png",
        overFile = "images/assets1/btn_twitter_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        onRelease = onShareButtonReleased,
    }
    group:insert(twitter_button)
    twitter_button.anchorX = 0
    twitter_button.anchorY = 0
    twitter_button.x = popupFrame.x + sns_RectWidth + (sns_RectWidth - twitter_button.width) * 0.5
    twitter_button.y = facebook_button.y
    
    twitter_label.anchorX = 0
    twitter_label.anchorY = 0
    twitter_label.x = twitter_button.x + (twitter_button.width - twitter_label.width) * 0.5
    twitter_label.y = facebook_label.y
    twitter_label:setFillColor( 0, 0, 0)
    group:insert(twitter_label)
    
    local line_label = display.newText(language["socialShareScene"]["btn_line"], 0, 0, native.systemFont, __buttonFontSize__)
    local line_button = widget.newButton
    {
        id = "line",
        width = 60 ,
        height = 60 ,
        left = display.contentCenterX + 6 ,
        top = 200, 
        defaultFile = "images/assets1/btn_line.png",
        overFile = "images/assets1/btn_line_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        onRelease = onShareButtonReleased,
    }
    group:insert(line_button)
    line_button.anchorX = 0
    line_button.anchorY = 0
    line_button.x = popupFrame.x + sns_RectWidth + sns_RectWidth + (sns_RectWidth - line_button.width) * 0.5 - 10
    line_button.y = facebook_button.y
    
    line_label.anchorX = 0
    line_label.anchorY = 0
    line_label.x = line_button.x + (line_button.width - line_label.width) * 0.5
    line_label.y = facebook_label.y
    line_label:setFillColor( 0, 0, 0)
    group:insert(line_label)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view    
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    group:removeSelf()
    group = nil
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    print( "overlayBegan: " .. event.sceneName )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    print( "overlayEnded: " .. event.sceneName )
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