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
      post_contents_button

local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.mainScene", "slideRight", 300 ) 
    end
    
    return true
end

local function onTitleFocus( event )
    print(event.phase..", display_group.y:", display_group.y);
    if ( "began" == event.phase ) then
        if (display_group.y == 0) then
            --transition.to(display_group, {y = display_group.y - (navBar.height + 70 - __textFieldHeight__), time=100, onComplete=nil})
        end
    elseif ( "submitted" == event.phase ) then
        native.setKeyboardFocus(notice_title)
    end
    
    return true
end

local function onContentsFocus( event )
    if ( "began" == event.phase ) then
        if (display_group.y == 0) then
            --transition.to(display_group, {y = display_group.y - (navBar.height + 70 - __textFieldHeight__), time=100, onComplete=nil})
        end
    elseif ( "submitted" == event.phase ) then
        
    end
    
    return true
end

local function bg_OnTap( event )
    if (display_group.y < 0) then
        transition.to(display_group, {y = 0, time=100, onComplete=nil})
    end
    native.setKeyboardFocus( nil )
    
    return true
end

local function commonCallback( event )
    if ( event.isError ) then
        native.setActivityIndicator( false )
        print( "Network error!")
        local alert = native.showAlert( language["appTitle"], language["common"]["wrong_connection"], { language["common"]["alert_ok_button"]} )
    else
        print(event.status)
        if(event.status == 200) then
            print(event.response)
            local data = json.decode(event.response)
                
            if (data) then
                print(data)
                if(data.status == "OK") then
                    local alert = native.showAlert( language["appTitle"], "OK", { language["common"]["alert_ok_button"]})
                    native.setActivityIndicator( false )
                else
                    native.setActivityIndicator( false )
                    local alert = native.showAlert( language["appTitle"], "NG", { language["common"]["alert_ok_button"]})
                    return true
                end
            end
        end
    end
end

local function postContnetsButtonEvent( event )
    if event.phase == "ended" then
        post_contents_button:setEnabled(false)
        
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            class_id = "189",
            member_id = "78",
            title = "テスト",
            contents = "テストです。"
        }
        api.post_mamatalk_contents(params, commonCallback)
        return true
    end
    
    return true
end

local function postContents2ButtonEvent( event )
    if event.phase == "ended" then
        post_contents_button:setEnabled(false)
        
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            class_id = "193",
            member_id = "71",
            kids_id = "119",
            title = "香りテストです。",
            contents = "香りテストです。"
        }
        api.post_mamatalk_contents2(params, commonCallback)
        return true
    end
    
    return true
end

local function postReply2ButtonEvent( event )
    if event.phase == "ended" then
        api.post_mamatalk_reply2("107","71","40","テストでもいいじゃない？", commonCallback)
        return true
    end
    
    return true
end

local function replyList2ButtonEvent( event )
    if event.phase == "ended" then
        api.get_mamatalk_reply_list2("107","1","10", commonCallback)
        return true
    end
    
    return true
end
function fileExists(fileName, base)
  local base = base or system.ResourceDirectory
  local filePath = system.pathForFile( fileName, base )
  local exists = false
 
  if (filePath) then -- file may exist. won't know until you open it
    local fileHandle = io.open( filePath, "r" )
    if (fileHandle) then -- nil if no file found
      exists = true
      io.close(fileHandle)
    end
  end
 
  return(exists)
end

local function postReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.post_mamatalk_reply("23", "73", "いいですね。私も&買いたいです。", commonCallback)
    end
    
    return true
end

local function plusGoodCntButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.plus_mamatalk_goodcnt("2", "45", commonCallback)
    end
    
    return true
end

local function updateContentsButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local title = "テストのママトーク"
        local contents = "テストのママトークです。"
        api.update_mamatalk_contents("4", "43", title, contents, commonCallback)
    end
    
    return true
end

local function postImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "4",
            mamatalk_id = "2",
            filename = "pikacyu.jpg",
            dir = system.DocumentsDirectory
        }
        api.post_mamatalk_image(params, commonCallback)
    end
    
    return true
end

local function deleteImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            mamatalk_id = "2",
            filename = "4abb4d73717bc752ecdd0de829ff8596df88702a.jpg"
        }
        api.delete_mamatalk_image(params, commonCallback)
    end
    
    return true
end

local function deleteReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_mamatalk_reply("2", "3", commonCallback)
    end
    
    return true
end

local function deleteMamaTalkButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_mamatalk("4", commonCallback)
    end
    
    return true
end

local function listButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_mamatalk_list("4","43","1","10", commonCallback)
    end
    
    return true
end

local function replylistButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_mamatalk_reply_list("2","1","10", commonCallback)
    end
    
    return true
end

local function detailButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_mamatalk_detail("2", commonCallback)
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
        title = "MamaTalk Test Main",
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
    })    
    group:insert(navBar)

    group:addEventListener( "tap", bg_OnTap )
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    post_contents_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = navBar.height + 10, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "POST CONTENTS",
        onRelease = postContnetsButtonEvent
    }
    group:insert(post_contents_button)
    
    local delete_reply = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_contents_button.x + 80,
        top = navBar.height + 10, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete reply",
        onRelease = deleteReplyButtonEvent
    }
    group:insert(delete_reply)

    local post_reply_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = post_contents_button.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __buttonFontSize__,
        label = "POST Reply",
        onRelease = postReplyButtonEvent
    }
    group:insert(post_reply_button)

    local plus_goood_cnt = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_reply_button.x + 80,
        top = post_contents_button.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "Plus Good Cnt",
        onRelease = plusGoodCntButtonEvent
    }
    group:insert(plus_goood_cnt)
    
    local update_contents = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = plus_goood_cnt.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "update Contents",
        onRelease = updateContentsButtonEvent
    }
    group:insert(update_contents)
    
    local post_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = update_contents.x + 80,
        top = plus_goood_cnt.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "post_image",
        onRelease = postImageButtonEvent
    }
    group:insert(post_image)
    
    local delete_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = update_contents.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete image",
        onRelease = deleteImageButtonEvent
    }
    group:insert(delete_image)
    
    local delete_mamatalk = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_image.x + 80,
        top = post_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete mamatalk",
        onRelease = deleteMamaTalkButtonEvent
    }
    group:insert(delete_mamatalk)
    
    local list_mamatalk = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list",
        onRelease = listButtonEvent
    }
    group:insert(list_mamatalk)
    
    local send_notice_read = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = list_mamatalk.x + 80,
        top = delete_mamatalk.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "send notice read",
        --onRelease = sendNoticeReadButtonEvent
    }
    group:insert(send_notice_read)
    
    local replylist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = list_mamatalk.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "reply list",
        onRelease = replylistButtonEvent
    }
    group:insert(replylist)
    
    local detail = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = replylist.x + 80,
        top = send_notice_read.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "detail",
        onRelease = detailButtonEvent
    }
    group:insert(detail)
    
    local postContents2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = replylist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "postContents2",
        onRelease = postContents2ButtonEvent
    }
    group:insert(postContents2)
    
    local postReply2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = postContents2.x + 80,
        top = detail.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "postReply2",
        onRelease = postReply2ButtonEvent
    }
    group:insert(postReply2)
    
    local replyList2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = postContents2.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "replyList2",
        onRelease = replyList2ButtonEvent
    }
    group:insert(replyList2)
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

