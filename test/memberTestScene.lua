---------------------------------------------------------------------------------
-- splashScene
-- Scene notes go here
---------------------------------------------------------------------------------
local ga = require( "scripts.googleAnalytics" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local language = getLanguage()
local widget = require("widget")
local api = require("scripts.api")
local json = require("json")
require("widgets.widget_newNavBar")

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local notice_title, 
      display_group, 
      navBar, 
      notice_contents, 
      post_notice_contents_button, 
      post_zipfile_button,
      notice_reply_contents

local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.mainScene", "slideRight", 300 ) 
    end
    
    return true
end

local function callbackListener( event )
    if ( event.isError ) then
        native.setActivityIndicator( false )
        print( "Network error!")
        local alert = native.showAlert( language["appTitle"], language["common"]["wrong_connection"], { language["common"]["alert_ok_button"]}, function() return true end )
    else
        print(event.status)
        if(event.status == 200) then
            print(event.response)
            local data = json.decode(event.response)
                
            if (data) then
                if(data.status == "OK") then
                    local alert = native.showAlert( language["appTitle"], "OK", { language["common"]["alert_ok_button"]}, function() return true end )
                    native.setActivityIndicator( false )
                else
                    native.setActivityIndicator( false )
                    local alert = native.showAlert( language["appTitle"], "NG", { language["common"]["alert_ok_button"]}, function() return true end )
                    return true
                end
            end
        end
    end
end

local function memberType1ButtonEvent( event )
    if event.phase == "ended" then
        local params = {
            member_type = "1",
            center_type = "1",
            country_id = "1",
            state_id = "12",--千葉県
            city_id = "12",--松戸市
            center_name = "胡録台保育園",
            member_name = "黒畑　ひろみ",
            email = "encho5@test.com",
            pw = "1234",
            phonenum = "111-0987-1234",
            --filename = "amuro_txt.jpg",
            filename = "notice_test2.jpg",
            dir = system.DocumentsDirectory
        }
        api.post_membertype1_info(params, callbackListener)
    end
    
    return true
end

local function memberType2ButtonEvent( event )
    if event.phase == "ended" then
        local params = {
            member_type = "2",
            center_type = "1",
            country_id = "1",
            state_id = "12",--千葉県
            city_id = "12",--松戸市
            member_name = "テスト先生９",
            email = "teacher11@test.com",
            pw = "1234",
            phonenum = "111-2222-3333",
            --filename = "amuro_txt.jpg",
            filename = "notice_test2.jpg",
            dir = system.DocumentsDirectory,
            center_id = "3",
            class_id = "39"
        }
        api.post_membertype2_info(params, callbackListener)
    end
    
    return true
end

local function memberType3ButtonEvent( event )
    if event.phase == "ended" then
        local params = {
            member_type = "3",
            center_type = "2",
            country_id = "1",
            state_id = "12",--千葉県
            city_id = "12",--松戸市
            member_name = "北澤　健一",
            email = "mother1272@test.com",
            pw = "1234",
            phonenum = "111-2222-2222",
            --filename = "amuro_txt.jpg",
            filename = "",
            dir = system.DocumentsDirectory,
            center_id = "16",
            class_id = "190",
            kid_name = "北澤 新",
            kid_birth = "20120214",
            kid_sex = "2",
            invitationCodeInputResult = "0"
        }
        api.post_membertype3_info(params, callbackListener)
    end
    
    return true
end

local function addKidsButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            member_id = 7,
            center_id = 4,
            class_id = 44,
            kids_name = "桃　武",
            kids_birthday = "20120927",
            kids_sex = "1",
            kids_active = "0",
            --filename = "amuro_txt.jpg",
            --filename = "child_profile.jpg",
            filename = "",
            dir = system.DocumentsDirectory
        }
        api.add_kids_info(params, callbackListener)
    end
    
    return true
end

local function updateKidsButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            member_id = 7,
            center_id = 1,
            class_id = 44,
            kids_id = 22,
            kids_name = "桃　健二",
            kids_birthday = "20120827",
            kids_sex = "1",
            kids_active = "1",
            --filename = "amuro_txt.jpg",
            filename = "child_profile.jpg",
            --filename = "",
            dir = system.DocumentsDirectory
        }
        api.update_kids_info(params, callbackListener)
    end
    
    return true
end

local function updateMember2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            member_id = 65,
            member_name = "北沢 恵理子",
            phonenum = "090-1111-2222",
            center_id = 9,
            class_id = 62,
            --class_id = 0,
            --filename = "amuro_txt.jpg",
            filename = "member_type2.jpg",
            --filename = "",
            dir = system.DocumentsDirectory
        }
        api.update_member2_info(params, callbackListener)
    end
    
    return true
end

local function updateMember1ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            member_id = 40,
            member_name = "町田　金子",
            phonenum = "090-3333-4444",
            --filename = "amuro_txt.jpg",
            filename = "member_type2.jpg",
            --filename = "",
            dir = system.DocumentsDirectory
        }
        api.update_member1_info(params, callbackListener)
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    display_group = group
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    local btn_left_opt = {
        label = language["top"]["back"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onBackButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",
    }

    navBar = widget.newNavigationBar({
        title = "Member Test Main",
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
    })    
    group:insert(navBar)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    local memberType1 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "add memberType1",
        onRelease = memberType1ButtonEvent
    }
    memberType1.x = display.contentCenterX
    memberType1.y = navBar.height + 30
    group:insert(memberType1)

    local memberType2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "add memberType2",
        onRelease = memberType2ButtonEvent
    }
    memberType2.x = display.contentCenterX
    memberType2.y = memberType1.y + 50
    group:insert(memberType2)
    
    local memberType3 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "add memberType3",
        onRelease = memberType3ButtonEvent
    }
    memberType3.x = display.contentCenterX
    memberType3.y = memberType2.y + 50
    group:insert(memberType3)
    
    local addKids = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "add Kids",
        onRelease = addKidsButtonEvent
    }
    addKids.x = display.contentCenterX
    addKids.y = memberType3.y + 50
    group:insert(addKids)
    
    local updateKids = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "update Kids",
        onRelease = updateKidsButtonEvent
    }
    updateKids.x = display.contentCenterX
    updateKids.y = addKids.y + 50
    group:insert(updateKids)
    
    local updateMemberType2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "update Member2",
        onRelease = updateMember2ButtonEvent
    }
    updateMemberType2.x = display.contentCenterX
    updateMemberType2.y = updateKids.y + 50
    group:insert(updateMemberType2)
    
    local updateMemberType1 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "update Member1",
        onRelease = updateMember1ButtonEvent
    }
    updateMemberType1.x = display.contentCenterX
    updateMemberType1.y = updateMemberType2.y + 50
    group:insert(updateMemberType1)

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
--    display:remove(group)
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
    group:removeSelf()
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

