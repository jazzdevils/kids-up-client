require("widgets.widgetext")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local access = require("scripts.accessScene")
local api = require("scripts.api")
local json = require("json")
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")

--local navBar
local email, pw, memberType, invitationCodeInputResult
local activityIndicator

local function loginCallback(event) 
    if ( event.isError ) then
        activityIndicator:destroy()
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            local data = json.decode(event.response)
            if (data) then
                if(data.status == "OK") then
                    local loginJson = {}
                    loginJson.logined = "1"
                    local profileImage = ""
                    if(data.member.img ~= "") then
                        profileImage = data.member.img:match("([^/]+)$")
                    end
                    loginJson.member = {}
                    loginJson.member.id = data.member.id
                    loginJson.member.centerId = data.member.center_id
                    loginJson.member.centerName = data.member.center_name
                    loginJson.member.type = data.member.type
                    loginJson.member.subtype = data.member.subtype
                    loginJson.member.name = data.member.name
                    loginJson.member.phonenum = data.member.phonenum
                    loginJson.member.img = data.member.img
                    loginJson.member.profileImage = profileImage
                    loginJson.member.approvalState = data.member.approval_state
                    loginJson.member.classId = data.member.class_id
                    loginJson.member.className = data.member.class_name
                    if utils.setAppInitPropertyData(loginJson) then
                        activityIndicator:destroy()
                        if data.member.type == __PARENT__ then
                            access:getKidsInfo(data.member.id)
                        else
                            access:gotoMngHomeSceneFromLogin(data)
                        end
                    else
                        activityIndicator:destroy()
                        utils.showMessage( language["loginScene"]["login_error"] )
                    end
                else
                    activityIndicator:destroy()
                    print(language["loginScene"]["wrong_login"])    
                    utils.showMessage( language["loginScene"]["wrong_login"] )
                end
            end
        end
    end
    
    return true
end

local function gotoSceneButtonEvent( event )
    if event.phase == "ended" then
        local options = {   
            effect = "slideLeft",
            time = 300,
        }
        
        if memberType == __DIRECTOR__ then --원장일경우는 톱화면으로
            storyboard.purgeScene("scripts.top")
            storyboard.gotoScene("scripts.top", options)
        else --교사, 학부모의 경우
            if invitationCodeInputResult == "1" then --승인 OK 
                activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                api.login_api(email, pw, loginCallback) --로그인
            else --승인 not OK
                storyboard.purgeScene("scripts.top") --톱화면으로
                storyboard.gotoScene("scripts.top", options)
            end    
        end
    end
end
-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    local params = event.params
    
    email = params.email
    pw = params.pw
    memberType = params.memberType
    invitationCodeInputResult = params.invitationCodeInputResult
    
    local b = display.newRect(group, 0,0, __appContentWidth__, __appContentHeight__)
    b.anchorX, b.anchorY = 0,0
    b:setFillColor(0.9,0.9,0.9,1)
    b:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )

    local bg = display.newImageRect(group, "images/bg_set/background.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    local navBar = widget.newNavigationBar({
        title = language["joinScene"]["join_process_end"],
        width = 360,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontsize = __textTitleBarFontSize__
    })
    group:insert(navBar)
    
    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 5 / 5, 6, 3 )
    progress.anchorX = 0
    progress.anchorY = 0
    progress.x = display.contentWidth - __appContentWidth__
    progress.y = navBar.height
    progress:setFillColor( unpack(__PROGRESS_BAR_COLOR) )
    
    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height

    local progressFrame = display.newRect( group, display.contentCenterX, navBar.height + 3, __appContentWidth__, 6 )
    progressFrame.strokeWidth = 0
    progressFrame:setFillColor( 0, 0, 0 )

    local congratulationImg = display.newImageRect(group, "images/assets1/pic_join_congratulation.png", 200, 161)
    congratulationImg.x = display.contentCenterX
    congratulationImg.anchorY = 0
--    congratulationImg.y = navBar.height + 161 / 2 + 25
    congratulationImg.y = navBar.y + navBar.height + 10

    local txtOptions = 
    {
        text = language["joinScene"]["join_process_end_title"],     
        x = display.contentCenterX,
        y = congratulationImg.y + 161 / 2 + 25,
        width = __appContentWidth__ - 30,--bg_w.width - 10,
        font = native.systemFontBold,   
        fontSize = 18,
        align = "center"
    }
    local congratulationTitle = display.newText(txtOptions)
    congratulationTitle.anchorY = 0
    congratulationTitle.y = congratulationImg.y + congratulationImg.height
    congratulationTitle:setFillColor( 0, 0, 0 )
    group:insert(congratulationTitle)

    local txtOptions = 
    {
        text = "",     
        x = display.contentCenterX,
        y = 0,--congratulationTitle.y + 40,
        width = __appContentWidth__ - 30, --bg_w.width - 10,
--        height = 120,
        font = native.systemFontBold,   
        fontSize = 16,
        align = "left"
    }
    
    local gotoSceneButton_label
    if memberType == __DIRECTOR__ then --원장일경우는 톱화면으로
        txtOptions.text = string.gsub(language["joinScene"]["under_check_membertype1"], "_EMAIL_", email)
        gotoSceneButton_label = language["joinScene"]["gotoTop"]
    elseif memberType == __TEACHER__ then
        if invitationCodeInputResult == "1" then --승인 OK 
            txtOptions.text = language["joinScene"]["under_check_membertype2"]["with_invitation_code"]
            gotoSceneButton_label = language["joinScene"]["gotoHome"]
        else --승인 not OK
            txtOptions.text = language["joinScene"]["under_check_membertype2"]["without_invitation_code"]
            gotoSceneButton_label = language["joinScene"]["gotoTop"]
        end
    elseif memberType == __PARENT__ then
        if invitationCodeInputResult == "1" then --승인 OK 
            txtOptions.text = language["joinScene"]["under_check_membertype3"]["with_invitation_code"]
            gotoSceneButton_label = language["joinScene"]["gotoHome"]
        else --승인 not OK
            txtOptions.text = language["joinScene"]["under_check_membertype3"]["without_invitation_code"]
            gotoSceneButton_label = language["joinScene"]["gotoTop"]
        end    
    end
    
    local congratulationContents = display.newText( txtOptions )
    congratulationContents:setFillColor( 0, 0, 0 ) 
    congratulationContents.anchorY = 0
    congratulationContents.y = congratulationTitle.y
    group:insert(congratulationContents)

    local gotoSceneButton = widget.newButton
    {
        width = 135,
        height = 40,
        left = display.contentCenterX - 70,
        top = congratulationContents.y + congratulationContents.height / 2 + 10,
        defaultFile = "images/button_inframe/btn_inframe_blue_2_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __textSubMenuFontSize__,
        label = gotoSceneButton_label,
        onRelease = gotoSceneButtonEvent,
    }
    group:insert(gotoSceneButton)
    
    gotoSceneButton.anchorX = 0
    gotoSceneButton.anchorY = 0
    gotoSceneButton.x = ( __appContentWidth__ * 0.5 ) - gotoSceneButton.width - 2
    gotoSceneButton.y = congratulationContents.y + congratulationContents.height + 5
    local shareButton = widget.newButton
    {
        id = "share",
        width = 135,
        height = 40,
        left = display.contentCenterX - 70,
        top = congratulationContents.y + congratulationContents.height / 2 + 10,
        defaultFile = "images/button_inframe/btn_inframe_red_2_normal.png",
        overFile = "images/button_inframe/btn_inframe_red_2_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __textSubMenuFontSize__,
        label = language["socialShareScene"]["start_button"],
        onRelease = function(event)
            if __deviceType__ == "android" then
                local serviceName = event.target.id
                local isAvailable = native.canShowPopup( "social", serviceName )
                
                local function socialListener( event )
                    native.setKeyboardFocus(nil)
                end
                
                if isAvailable then
                    native.showPopup( "social",
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
                    utils.showMessage( string.gsub(language["socialShareScene"]["error_android"], "_SERVICENAME_", serviceName), 3000)
                end
            else
                local options = {
                    effect = "fade",
                    time = 300,
                    params = {

                    },
                    isModal = true,
                }
                storyboard.showOverlay( "scripts.socialShareScene" ,options )
            end
        end,    
    }
    group:insert(shareButton)
    
    shareButton.anchorX = 0
    shareButton.anchorY = 0
    shareButton.x = ( __appContentWidth__ * 0.5 ) + 2
    shareButton.y = gotoSceneButton.y
end

function scene:willEnterScene( event )
    local group = self.view
    
    
end

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
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
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