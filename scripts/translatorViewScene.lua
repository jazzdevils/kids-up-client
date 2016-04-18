---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("widgets.activityIndicator")

local json = require("json")
local url = require("socket.url")
local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local language = getLanguage()
local userSetting = require("scripts.userSetting")
local utils = require("scripts.commonUtils")

local activityIndicator
local scrollView


---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local function translation(strText, from, to)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["translate"])
    
    local AUTHORIZE_URL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
    local SCOPE = "http://api.microsofttranslator.com"
    
    local TRANSLATION_URL = 'http://api.microsofttranslator.com/V2/Http.svc/Translate'
    
    local Client_id = "thekidslink_app_program"
    local Client_secret = "yO5Ppl2bNuZs2IyJBYuKPeSmrTK7dsUFM/z0ocyqW7M="

    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local postData = "grant_type=client_credentials&client_id="..Client_id.."&client_secret="..url.escape(Client_secret).."&scope="..SCOPE
--    local postData = "grant_type=client_credentials&client_id="..Client_id.."&client_secret="..urlencode(Client_secret).."&scope="..SCOPE
    local params = {}
    params.headers = headers
    params.body = postData
    
    network.request(AUTHORIZE_URL, "POST", 
        function(event)
            if(event.isError) then
                activityIndicator:destroy()
                utils.showMessage(language["common"]["wrong_connection"])
            elseif(event.phase == "ended") then
                local data = json.decode(event.response)
                if(data) then
                    local access_token = data.access_token
                    
                    local headers = {}
                    headers["Authorization"] = "Bearer".." "..access_token
                    
                    local params = {}
                    params.headers = headers    
                    
                    local sUrl = TRANSLATION_URL.."?contentType=text/plain&appId=".."&from="..from.."&to="..to.."&text="..url.escape(strText)
                    
                    network.request(sUrl, "GET", 
                        function(e)
                            if(e.isError) then
                                activityIndicator:destroy()
                                utils.showMessage(language["common"]["wrong_connection"])
                            elseif(e.phase == "ended") then
                                local strTmp = string.gsub(e.response, "(<string[^>]*>)", "")
                                local data = string.gsub(strTmp, "(</string[^>]*>)", "")
                                local data = string.gsub(data, __STRING_DELIMITER__, "\n")
                                local options = 
                                {
                                    --parent = textGroup,
                                    text = data,     
                                    x = 0,
                                    y = 0,
                                    width = scrollView.width - 10,
                                    font = native.systemFontBold,   
                                    fontSize = __VIEW_SCENE_TEXT_SIZE__,
                                    align = "left"  --new alignment parameter
                                }
                                scrollView.desc_txt = display.newText(options)
                                scrollView.desc_txt.anchorX = 0
                                scrollView.desc_txt.anchorY = 0
                                scrollView.desc_txt.x = 5
                                scrollView.desc_txt.y = 10
                                scrollView.desc_txt:setFillColor(0, 0, 0)
                                scrollView:insert(scrollView.desc_txt)
                                
                                scrollView.footer_txt = display.newText("", 0, 0, native.systemFont, 12)
                                scrollView.footer_txt.anchorX = 0
                                scrollView.footer_txt.anchorY = 0
                                scrollView.footer_txt.x = 5
                                scrollView.footer_txt.y = scrollView.desc_txt.y + scrollView.desc_txt.height + 5
                                scrollView.footer_txt:setFillColor(0, 0, 0)
                                scrollView:insert(scrollView.footer_txt)
                                
                                activityIndicator:destroy()
                            end
                        end
                    , params)
                end
            end
        end
        , params)
end

local function translationWithDetection(strText, to)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["translate"])
    
    local AUTHORIZE_URL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
    local SCOPE = "http://api.microsofttranslator.com"
    
    local TRANSLATION_URL = 'http://api.microsofttranslator.com/V2/Http.svc/Translate'
    local DETECT_LANGUAGE_URL = 'http://api.microsofttranslator.com/V2/Http.svc/Detect'
    
    local Client_id = "thekidslink_app_program"
    local Client_secret = "yO5Ppl2bNuZs2IyJBYuKPeSmrTK7dsUFM/z0ocyqW7M="

    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Accept-Language"] = "utf-8"

    local postData = "grant_type=client_credentials&client_id="..Client_id.."&client_secret="..url.escape(Client_secret).."&scope="..SCOPE
--    local postData = "grant_type=client_credentials&client_id="..Client_id.."&client_secret="..urlencode(Client_secret).."&scope="..SCOPE
    local params = {}
    params.headers = headers
    params.body = postData
    
    network.request(AUTHORIZE_URL, "POST", 
        function(event)
            if(event.isError) then
                activityIndicator:destroy()
                utils.showMessage(language["common"]["wrong_connection"])
            elseif(event.phase == "ended") then
                local data = json.decode(event.response)
                if(data) then
                    local access_token = data.access_token
                    
                    local headers = {}
                    headers["Authorization"] = "Bearer".." "..access_token
                    
                    local params = {}
                    params.headers = headers 
                    params.timeout = 20
                    
                    local sUrl = DETECT_LANGUAGE_URL.."?appId=".."&text="..url.escape(strText)
                    
                    network.request(sUrl, "GET", 
                        function(e)
                            if(e.isError) then
                                activityIndicator:destroy()
                                utils.showMessage(language["common"]["wrong_connection"])
                            else
                                
                                local tmp_from = e.response 
                                local from = tmp_from:gsub("%b<>","")
                                if (string.len(from) == 2 ) then
                                    print(from)
                                    
                                    local sUrl = TRANSLATION_URL.."?contentType1=text/plain&appId=".."&from="..from.."&to="..to.."&text="..url.escape(strText)

                                    network.request(sUrl, "GET", 
                                        function(e)
                                            if(e.isError) then
                                                activityIndicator:destroy()
                                                utils.showMessage(language["common"]["wrong_connection"])
                                            else
                                                local strTmp = string.gsub(e.response, "(<string[^>]*>)", "")
                                                local data = string.gsub(strTmp, "(</string[^>]*>)", "")
                                                local data = string.gsub(data, __STRING_DELIMITER__, "\n")
                                                local options = 
                                                {
                                                    --parent = textGroup,
                                                    text = data,     
                                                    x = 0,
                                                    y = 0,
                                                    width = scrollView.width - 10,
                                                    font = native.systemFontBold,   
                                                    fontSize = __VIEW_SCENE_TEXT_SIZE__,
                                                    align = "left"  --new alignment parameter
                                                }
                                                scrollView.desc_txt = display.newText(options)
                                                scrollView.desc_txt.anchorX = 0
                                                scrollView.desc_txt.anchorY = 0
                                                scrollView.desc_txt.x = 5
                                                scrollView.desc_txt.y = 10
                                                scrollView.desc_txt:setFillColor(0, 0, 0)
                                                scrollView:insert(scrollView.desc_txt)

                                                scrollView.footer_txt = display.newText("", 0, 0, native.systemFont, 12)
                                                scrollView.footer_txt.anchorX = 0
                                                scrollView.footer_txt.anchorY = 0
                                                scrollView.footer_txt.x = 5
                                                scrollView.footer_txt.y = scrollView.desc_txt.y + scrollView.desc_txt.height + 5
                                                scrollView.footer_txt:setFillColor(0, 0, 0)
                                                scrollView:insert(scrollView.footer_txt)
                                                
                                                activityIndicator:destroy()
                                            end
                                        end
                                    , params)
                                end
                            end
                        end
                    , params)
                    
                                    
                end
            end
        end
        , params)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/assets2/bg_popup.png", __appContentWidth__ - 60, __appContentHeight__- 200)
--    local bg = display.newRect(group, 0, 0, __appContentWidth__ - 60, __appContentHeight__- 200)
    bg.anchorX = 0
    bg.anchorY = 0
    bg.x = (__appContentWidth__ - bg.width)/2
    bg.y = (__appContentHeight__ - bg.height)/2
    group:insert(bg)
    
    scrollView = widget.newScrollView
    {
        top = 100,
        left = 10,
        width = bg.width - 10,
        height = bg.height - 50,
        scrollWidth = bg.width - 10,
        scrollHeight = 800,
--        backgroundColor = { 0.9, 0.9, 0.9 },
        backgroundColor = { 1, 1, 1 },
        horizontalScrollDisabled = true,
--        listener = scrollListener
    }
    scrollView.anchorX = 0
    scrollView.anchorY = 0
    scrollView.x = bg.x + (bg.width - scrollView.width)/2
    scrollView.y = bg.y + 5
    group:insert(scrollView)
    
    local close_button = widget.newButton
    {
        width = 150 ,
        height = 30 ,
        left = 0,
        top = 0, 
        defaultFile = "images/button/btn_blue_2_normal.png",
        overFile = "images/button/btn_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["translatorViewScene"]["close"],
        onRelease = 
            function(event)
                if(event.phase == "ended")then
                    storyboard.hideOverlay("fade", 300 )
                end    
                return true
            end
    }
    close_button.anchorX = 0
    close_button.anchorY = 0
    close_button.x = bg.x + (bg.width - 150)/2
    close_button.y = bg.y + bg.height - 40
    group:insert(close_button)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    local srcTitle = ""
    if(event.params.srcTitle) then
        srcTitle = event.params.srcTitle
    end
    
    local srcContents = event.params.srcContents
    
    translationWithDetection(srcTitle..__STRING_DELIMITER__..__STRING_DELIMITER__..srcContents, userSetting.settings.toTranslatorLanguageCode)
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
    
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    
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