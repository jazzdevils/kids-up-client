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
local display_group, 
      navBar, 
      post_notice_contents_button, 
      post_zipfile_button

local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.mainScene", "slideRight", 300 ) 
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

local function postNoticeContentsCallback(event)
    native.setActivityIndicator( false )
    post_notice_contents_button:setEnabled(true)
    
    if ( event.isError ) then
        print( "Network error!")
        local alert = native.showAlert( language["appTitle"], language["common"]["wrong_connection"], { language["common"]["alert_ok_button"]})
    else
        print(event.status)
        if(event.status == 200) then
            print(event.response)
            local data = json.decode(event.response)
            
            if (data) then
                if(data.status == "OK") then
                    local alert = native.showAlert( language["appTitle"], "notice_id:"..data.notice_id, { language["common"]["alert_ok_button"]})
                else
                    local alert = native.showAlert( language["appTitle"], data.message, { language["common"]["alert_ok_button"]})
                end
            end
        end
    end
    
    return true
end

local function postNoticeContentsButtonEvent( event )
    if event.phase == "ended" then
        post_notice_contents_button:setEnabled(false)
        
        native.setActivityIndicator( true )
        -- api.post_notice_contents("2", "4", "43", "18", "夏休みのお知らせです。", "PUSH TEST CONTENTS", postNoticeContentsCallback)
        api.post_notice_contents("2", "16", "189", "69", "ご挨拶","皆さん、おはようございます。", postNoticeContentsCallback)
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

local function postZipfileListener( event )
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

local function postZipfileButtonEvent( event )
    if event.phase == "ended" then
        local filename = "noticeimage.zip"
        if fileExists(filename, system.DocumentsDirectory) then
            native.setActivityIndicator( true )
            --[[local headers = {}
            headers["Content-Type"] = "application/zip"
            headers["center_id"] = "1"
            headers["notice_id"] = "23"

            local params = {}
            params.headers = headers
            params.body = {
                filename = "notice.zip",
                baseDirectory = system.DocumentsDirectory
            }]]--
            --api.post_notice_imagezip("4", "10", filename, system.DocumentsDirectory, postZipfileListener)
        else
            local alert = native.showAlert( language["appTitle"], filename.." not exist", { language["common"]["alert_ok_button"]} )
        end
        return true
    end
    
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

local function postReplyListener( event )
    native.setActivityIndicator( false )
    if ( event.isError ) then
        print( "Network error!")
    else
        print ( "Reply Upload complete!" )
    end
end

local function postReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.post_notice_reply("166", "71", "遠足ですか。いいですね。", commonCallback)
    end
    
    return true
end

local function postReply2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.post_notice_reply2("356", "71", "40", "太郎です。", commonCallback)
    end
    
    return true
end

local function plusGoodCntButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.plus_notice_goodcnt("13", "7", commonCallback)
    end
    
    return true
end

local function updateNoticeButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local title = "テストのお知らせ555"
        local contents = "テストのお知らせ5です&555"
        api.update_notice_contents("8", "42", title, contents, commonCallback)
        --api.update_notice_contents("8", "", title, contents, commonCallback)
    end
    
    return true
end

local function postNoticeImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            notice_id = "169",
            --filename = "amuro_txt.jpg",
            filename = "20140719_185453.jpg",
            dir = system.DocumentsDirectory
        }
        api.post_notice_image(params, commonCallback)
    end
    
    return true
end

local function deleteNoticeImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "4",
            notice_id = "26",
            filename = "de413c316077c64f1b2b4fb31dbfea901e7ed923.jpg"
        }
        api.delete_notice_image(params, commonCallback)
    end
    
    return true
end

local function deleteNoticeButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_notice("1", commonCallback)
    end
    
    return true
end

local function listNoticeButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        --api.notice_get_api("4","43","7","1","10", commonCallback)
        api.notice_get_api("4","","7","1","10", commonCallback)
    end
    
    return true
end

local function sendNoticeReadButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.send_notice_read("158","72", commonCallback)
    end
    return true
end

local function deleteNoticeReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_notice_reply("53","2", commonCallback)
    end 
    return true
end

local function noticeDetailButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_notice_detail("1", commonCallback)
    end 
    return true
end

local function deleteAlbumButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_album_data("7", "3", "1", commonCallback)
    end 
    return true
end

local function notreadListButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_memberlist_notread_notice("159", commonCallback)
    end 
    return true
end

local function pushNoticeButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.push_not_read_notice_member_list("157", commonCallback)
    end 
    return true
end

local function replyListButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.notice_reply_get_api("159","1","10", commonCallback)
    end 
    return true
end

local function replyList2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.notice_reply_get_api2("356","1","10", commonCallback)
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
        title = "Notice Test Main",
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

    post_notice_contents_button = widget.newButton
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
        onRelease = postNoticeContentsButtonEvent
    }
    group:insert(post_notice_contents_button)

    post_zipfile_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_notice_contents_button.x + 80, 
        top = post_notice_contents_button.y - 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "POST ZIP file",
        onRelease = postZipfileButtonEvent
    }
    group:insert(post_zipfile_button)

    local post_reply_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = post_zipfile_button.y  + 20, 
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
        top = post_zipfile_button.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "Plus Good Cnt",
        onRelease = plusGoodCntButtonEvent
    }
    group:insert(plus_goood_cnt)
    
    local update_notice = widget.newButton
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
        label = "update Notice",
        onRelease = updateNoticeButtonEvent
    }
    group:insert(update_notice)
    
    local post_notice_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = update_notice.x + 80,
        top = plus_goood_cnt.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "post_notice_image",
        onRelease = postNoticeImageButtonEvent
    }
    group:insert(post_notice_image)
    
    local delete_notice_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = update_notice.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete notice image",
        onRelease = deleteNoticeImageButtonEvent
    }
    group:insert(delete_notice_image)
    
    local delete_notice = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_notice_image.x + 80,
        top = post_notice_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete notice",
        onRelease = deleteNoticeButtonEvent
    }
    group:insert(delete_notice)
    
    local list_notice = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_notice_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list notice",
        onRelease = listNoticeButtonEvent
    }
    group:insert(list_notice)
    
    local send_notice_read = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = list_notice.x + 80,
        top = delete_notice.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "send notice read",
        onRelease = sendNoticeReadButtonEvent
    }
    group:insert(send_notice_read)
    
    local delete_notice_reply = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = list_notice.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete notice reply",
        onRelease = deleteNoticeReplyButtonEvent
    }
    group:insert(delete_notice_reply)
    
    local notice_detail = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_notice_reply.x + 80,
        top = send_notice_read.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "notice detail",
        onRelease = noticeDetailButtonEvent
    }
    group:insert(notice_detail)
    
    local delete_album = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_notice_reply.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete album",
        onRelease = deleteAlbumButtonEvent
    }
    group:insert(delete_album)
    
    local notreadlist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_notice_reply.x + 80,
        top = notice_detail.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "not read list",
        onRelease = notreadListButtonEvent
    }
    group:insert(notreadlist)
    
    local push_notice = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_album.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "push notice",
        onRelease = pushNoticeButtonEvent
    }
    group:insert(push_notice)
    
    local replylist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_notice_reply.x + 80,
        top = notreadlist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "replylist",
        onRelease = replyListButtonEvent
    }
    group:insert(replylist)
    
    local post_reply2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = push_notice.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "post_reply2",
        onRelease = postReply2ButtonEvent
    }
    group:insert(post_reply2)
    
    local replylist2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_reply2.x + 80,
        top = replylist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "replylist2",
        onRelease = replyList2ButtonEvent
    }
    group:insert(replylist2)
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

