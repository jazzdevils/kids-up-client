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
local event_title, 
      display_group, 
      navBar, 
      event_contents, 
      post_event_contents_button, 
      notice_reply_contents

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
        native.setKeyboardFocus(event_title)
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

local function postEventContnetsButtonEvent( event )
    if event.phase == "ended" then
        post_event_contents_button:setEnabled(false)
        
        native.setActivityIndicator( true )
        local params = {
            type = "2",
            center_id = "16",
            class_id = "189",
            member_id = "69",
            title = "遠足",
            contents = "上野動物公園に遠足です。",
            address = "東京都渋谷区恵比寿１－１－１",
            date = "20150425",
            --date = ""
        }
        api.post_event_contents(params, commonCallback)
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
        api.post_event_reply("19", "78", "テスト回答１です。", commonCallback)
    end
    
    return true
end

local function plusGoodCntButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local reply = notice_reply_contents.text
        api.plus_event_goodcnt("1", "7", commonCallback)
    end
    
    return true
end

local function updateEventButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            event_id = "4",
            class_id = "",
            title = "テストイベント",
            contents = "テストイベントです&555",
            address = "東京都渋谷区恵比寿２－２－２",
            date = "20140805"
        }
        api.update_event_contents(params, commonCallback)
    end
    
    return true
end

local function postEventImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "9",
            event_id = "4",
            --filename = "amuro_txt.jpg",
            filename = "20140719_153644.jpg",
            dir = system.DocumentsDirectory
        }
        api.post_event_image(params, commonCallback)
    end
    
    return true
end

local function deleteEventImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "9",
            event_id = "4",
            filename = "ee2a2ee7ac0a286233ac06cc47439be32737b7a8.jpg"
        }
        api.delete_event_image(params, commonCallback)
    end
    
    return true
end

local function deleteEventButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_event("4", commonCallback)
    end
    
    return true
end

local function listEventButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        --api.notice_get_api("4","43","7","1","10", commonCallback)
        api.get_event_list("9","59","7","1","10", commonCallback)
    end
    
    return true
end

local function replyListEventButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_event_reply_list("1", "1", "10", commonCallback)
    end
    
    return true
end

local function sendEventReadButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.send_event_read("19", "78", commonCallback)
    end
    return true
end

local function deleteEventReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_event_reply("1", "3", commonCallback)
    end
    return true
end

local function eventDetailButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_event_detail("1", commonCallback)
    end
    return true
end

local function notreadListButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_memberlist_notread_event("12", commonCallback)
    end
    return true
end

local function pushEventButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.push_not_read_event_member_list("19", commonCallback)
    end
    return true
end

local function replyList2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_event_reply_list2("84", "1", "10", commonCallback)
    end
    return true
end

local function postReply2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.post_event_reply2("84", "71", "40", "太郎行きます。",  commonCallback)
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
        title = "Event Test Main",
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
    
    post_event_contents_button = widget.newButton
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
        label = "POST EVENT",
        onRelease = postEventContnetsButtonEvent
    }
    group:insert(post_event_contents_button)
    
    local plus_goood_cnt = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_event_contents_button.x + 80,
        top = navBar.height + 10, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "Plus Good Cnt",
        onRelease = plusGoodCntButtonEvent
    }
    group:insert(plus_goood_cnt)

    local post_reply_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = post_event_contents_button.y  + 20, 
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
    
    local update_event = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_reply_button.x + 80,
        top = plus_goood_cnt.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "update Event",
        onRelease = updateEventButtonEvent
    }
    group:insert(update_event)
    
    local post_event_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = post_reply_button.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "post event image",
        onRelease = postEventImageButtonEvent
    }
    group:insert(post_event_image)
    
    local delete_event_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_event_image.x + 80,
        top = update_event.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete event image",
        onRelease = deleteEventImageButtonEvent
    }
    group:insert(delete_event_image)
    
    local delete_event = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = post_event_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete event",
        onRelease = deleteEventButtonEvent
    }
    group:insert(delete_event)
    
    local list_event = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_event.x + 80,
        top = delete_event_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list event",
        onRelease = listEventButtonEvent
    }
    group:insert(list_event)
    
    local reply_list_event = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_event.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list event",
        onRelease = replyListEventButtonEvent
    }
    group:insert(reply_list_event)
    
    local send_event_read = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = reply_list_event.x + 80,
        top = delete_event.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "send event read",
        onRelease = sendEventReadButtonEvent
    }
    group:insert(send_event_read)
    
    local delete_event_reply = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = reply_list_event.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete event reply",
        onRelease = deleteEventReplyButtonEvent
    }
    group:insert(delete_event_reply)
        
    local event_detail = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_event_reply.x + 80,
        top = send_event_read.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "event detail",
        onRelease = eventDetailButtonEvent
    }
    group:insert(event_detail)
    
    local notreadlist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_event_reply.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "not read list",
        onRelease = notreadListButtonEvent
    }
    group:insert(notreadlist)
    
    local push_event = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = notreadlist.x + 80,
        top = event_detail.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "push event",
        onRelease = pushEventButtonEvent
    }
    group:insert(push_event)
    
    local replylist2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = notreadlist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "replylist2",
        onRelease = replyList2ButtonEvent
    }
    group:insert(replylist2)
    
    local post_reply2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = replylist2.x + 80,
        top = push_event.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "post_reply2",
        onRelease = postReply2ButtonEvent
    }
    group:insert(post_reply2)
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