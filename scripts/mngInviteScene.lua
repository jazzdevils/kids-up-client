---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local user = require("scripts.user_data")
local json = require("json")
local api = require("scripts.api")
local pasteboard = require( "plugin.pasteboard" )

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30
local navBar
local nameRect
local activityIndicator
local settingTableView

local function onRowRender(event)
    local row = event.row
    local index = row.index 
        
    row.desc = display.newText(language["mngInviteScene"]["description"], 0, 0, row.width - 20, 0, native.systemFontBold, __textLabelFont14Size__)    
    row.desc.anchorY = 0
    row.desc.x = display.contentCenterX
    row.desc.y = 20
    row.desc:setFillColor(0)
    row:insert(row.desc)
    
    row.ver_rect = display.newRoundedRect(0, 0, row.width - 50, 50, 6)
    row.ver_rect.anchorY = 0
    row.ver_rect.strokeWidth = 1
    row.ver_rect:setStrokeColor( 0.7, 0.7, 0.7 )
    row.ver_rect:setFillColor( 0.9)
    row.ver_rect.x = display.contentCenterX
    row.ver_rect.y = row.desc.y + row.desc.height + 10
    row:insert(row.ver_rect)

    if __INVITATION_CODE__ == "" then
--        초대코드 없음
        row.code = display.newText(language["mngInviteScene"]["no_code"], 0, 0, native.systemFontBold, __textLabelFont14Size__)
        row.code.anchorY = 0
        row.code:setFillColor(0.4, 0.5, 0.6)
        row.code.x = display.contentCenterX
        row.code.y = row.ver_rect.y + (row.ver_rect.height - row.code.height)/2
        row:insert(row.code)
        
        row.code_button = widget.newButton
        {
            width = row.ver_rect.width ,
            height = 50 ,
            left = 0,
            top = 0, 
            defaultFile = "images/button/btn_red_1_normal.png",
            overFile = "images/button/btn_red_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
--            labelYOffset = -2,
            fontSize = __buttonFontSize__,
            label = language["mngInviteScene"]["generate"],--"초대코드 발행",--language["settingAppInfoScene"]["new_ver"],
            onRelease = function(event)
                            if(event.phase == "ended") then
                                if utils.IS_Demo_mode(storyboard, true) == true then
                                    return true
                                end
                                
                                local inviteCode = utils.generateInviteCode()
                                row.code.text = inviteCode
                                
                                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["save"])
                                api.set_invitation_code(user.userData.centerid, inviteCode,
                                    function(event)
                                        if(activityIndicator) then
                                            activityIndicator:destroy()
                                        end

                                        if ( event.isError ) then
                                            utils.showMessage(language["common"]["wrong_connection"])
                                        else
                                            if(event.status == 200) then
                                                __INVITATION_CODE__ = inviteCode
                                                
                                                row.code_button.isVisible = false
                                            end
                                        end
                                    end
                                )
                            end
                        end
        }
        row.code_button.x = display.contentCenterX
        row.code_button.anchorY = 0
        row.code_button.y = row.ver_rect.y + row.ver_rect.height + 10
        row:insert(row.code_button)
        
        if user.userData.jobType == __DIRECTOR__ then
            row.code_button.isVisible = true
        else
            row.code_button.isVisible = false
            row.code_desc = display.newText(language["mngInviteScene"]["only_principal"], 0, 0, row.width - 20, 0, native.systemFontBold, __textLabelFont14Size__)
            row.code_desc.anchorY = 0
            row.code_desc:setFillColor(0.4, 0.5, 0.6)
            row.code_desc.x = display.contentCenterX
            row.code_desc.y = row.ver_rect.y + row.ver_rect.height + 10
            row:insert(row.code_desc)
        end
    else
--        초대코드 있음
        row.code = display.newText(__INVITATION_CODE__, 0, 0, native.systemFontBold, __invitationCodeFontSize__)
        row.code.anchorY = 0
        row.code:setFillColor(0.4, 0.5, 0.6)
        row.code.x = display.contentCenterX
        row.code.y = row.ver_rect.y + (row.ver_rect.height - row.code.height)/2
        row:insert(row.code)
        
        row.code_button = widget.newButton
        {
            width = row.ver_rect.width ,
            height = 50 ,
            left = 0,
            top = 0, 
            defaultFile = "images/button/btn_red_1_normal.png",
            overFile = "images/button/btn_red_1_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
--            labelYOffset = -2,
            fontSize = __buttonFontSize__,
            label = language["mngInviteScene"]["to_pasteboard"],--"복사"
            onRelease = function(event)
                            if(event.phase == "ended") then
                                pasteboard.copy( "string", __INVITATION_CODE__)
                                utils.showMessage(language["mngInviteScene"]["completed_copy"])
                            end
                        end
        }
        row.code_button.x = display.contentCenterX
        row.code_button.anchorY = 0
        row.code_button.y = row.ver_rect.y + row.ver_rect.height + 10
        row:insert(row.code_button)
    end
    
    
--    row.code_button1 = widget.newButton
--        {
--            width = row.ver_rect.width ,
--            height = 50 ,
--            left = 0,
--            top = 0, 
--            defaultFile = "images/button/btn_red_1_normal.png",
--            overFile = "images/button/btn_red_1_touched.png",
--            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
--            emboss = true,
----            labelYOffset = -2,
--            fontSize = __buttonFontSize__,
--            label = "암호화 테스트",
--            onRelease = function(event)
--                            if(event.phase == "ended") then
--                                
--                            end
--                        end
--        }
--        row.code_button1.x = display.contentCenterX
--        row.code_button1.anchorY = 0
--        row.code_button1.y = row.ver_rect.y + row.ver_rect.height + 60
--        row:insert(row.code_button1)
end    

local function onLeftButton(event)
    if event.phase == "ended" then
--        storyboard.gotoScene("scripts.mngDirectorScene", "slideRight", 300)
        storyboard.gotoScene(storyboard.getPrevious(), "slideRight", 300)
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mngInviteScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }

    nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    local tag_Opt = {
        parent = group,
        text = user.getNameTagByAuthority(),
        x = display.contentCenterX,
        width = __appContentWidth__,
        y = __statusBarHeight__ + 68,
        font = native.systemFontBold,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    
    navBar = widget.newNavigationBar({
            title = language["mngInviteScene"]["title"],
    --        backgroundColor = { 0.96, 0.62, 0.34 },
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
        })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
--    native.setActivityIndicator( true )
    settingTableView = widget.newTableView{
        top = navBar.height + nameRect.height,
        height = __appContentHeight__ - navBar.height - nameRect.height, -- - __statusBarHeight__,
        width = __appContentWidth__,-- display.contentWidth,
        maxVelocity = 1, 
        rowTouchDelay = 60,
--        isLocked = true,
        hideBackground = false,
        onRowRender = onRowRender,
--        onRowTouch = onRowTouch,
--        noLine = true,
--        listener = nil,
    }
    settingTableView.x = display.contentWidth / 2
    group:insert(settingTableView)   
        
    if __INVITATION_CODE__ == "" then
        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
        api.get_invitation_code(user.userData.centerid, 
            function(event)
                if(activityIndicator) then
                    activityIndicator:destroy()
                end

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
                                __INVITATION_CODE__ = data.invitation_code
                                
                                settingTableView:insertRow{
                                    rowHeight = 250,
                                    rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0}},
                                    lineColor = { 0.5, 0.5, 0.5, 0 },
                                }
                            end
                        end
                    end
                end
            end
        )
    else
        settingTableView:insertRow{
            rowHeight = 250,
            rowColor = {  default = { 1, 1, 1,0 }, over = { 0.8, 0.8, 0.8, 0}},
            lineColor = { 0.5, 0.5, 0.5, 0 },
        }    
    end    
    
    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height
        
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.mngDirectorScene"
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
    print( "Showing overlay: " .. event.sceneName )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    print( "Overlay removed: " .. event.sceneName )
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





